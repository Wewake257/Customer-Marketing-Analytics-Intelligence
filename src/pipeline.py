"""
pipeline.py
-----------
End-to-end data pipeline for Customer & Marketing Analytics:
Ingests transaction, RFM, CLV, and marketing campaign response datasets into
an analytical SQLite Data Warehouse (customer_analytics_dw.db) and verifies
analytical queries.
"""

import sqlite3
import pandas as pd
import numpy as np
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
RAW_DIR = ROOT / "data" / "raw"
PROCESSED_DIR = ROOT / "data" / "processed"
DB_PATH = PROCESSED_DIR / "customer_analytics_dw.db"
SCHEMA_PATH = ROOT / "sql" / "01_schema_sqlite.sql"

def get_connection():
    PROCESSED_DIR.mkdir(parents=True, exist_ok=True)
    return sqlite3.connect(DB_PATH)

def init_database():
    print(f"[Pipeline] Initializing Database at: {DB_PATH}")
    conn = get_connection()
    with open(SCHEMA_PATH, "r", encoding="utf-8") as f:
        schema_sql = f.read()
    conn.executescript(schema_sql)
    conn.commit()
    conn.close()
    print("[Pipeline] Schema initialized.")

def ingest_rfm_clv_data(conn):
    rfm_path = RAW_DIR / "customer_rfm_clv.csv"
    if not rfm_path.exists():
        print(f"[Warning] {rfm_path} not found.")
        return
    
    print("[Pipeline] Ingesting RFM & CLV analytical dataset...")
    df = pd.read_csv(rfm_path)
    df.columns = [c.lower() for c in df.columns]
    
    # Map to fact_customer_rfm
    mapping = {
        "customerid": "customer_id",
        "recency": "recency_days",
        "frequency": "frequency_orders",
        "monetary": "monetary_total",
        "r_score": "r_score",
        "f_score": "f_score",
        "m_score": "m_score",
        "rfm_group": "rfm_composite",
        "segment": "rfm_segment",
        "churned": "is_churned_90d"
    }
    rfm_df = df[[c for c in mapping.keys() if c in df.columns]].rename(columns=mapping)
    rfm_df.to_sql("fact_customer_rfm", conn, if_exists="append", index=False)
    print(f"           -> {len(rfm_df)} customer RFM records loaded.")

    # Also save full CLV dataset to a dedicated table
    df.to_sql("fact_customer_lifetime_value", conn, if_exists="replace", index=False)
    print(f"           -> {len(df)} CLV projections loaded.")

def ingest_sample_transactions(conn):
    retail_path = RAW_DIR / "online_retail.csv"
    if not retail_path.exists():
        print(f"[Warning] {retail_path} not found.")
        return
        
    print("[Pipeline] Ingesting sample transactions (100,000 line items)...")
    # Read first 100k rows for fast DW analytics
    df = pd.read_csv(retail_path, nrows=100000)
    df = df.rename(columns={
        "InvoiceNo": "invoice", "Invoice": "invoice",
        "StockCode": "stock_code",
        "Description": "description",
        "Quantity": "quantity",
        "InvoiceDate": "invoice_date",
        "UnitPrice": "price", "Price": "price",
        "CustomerID": "customer_id", "Customer ID": "customer_id",
        "Country": "country"
    })
    
    df["customer_id"] = pd.to_numeric(df["customer_id"], errors="coerce")
    df = df.dropna(subset=["customer_id"])
    df["customer_id"] = df["customer_id"].astype(int)
    df["quantity"] = pd.to_numeric(df["quantity"], errors="coerce").fillna(0)
    df["price"] = pd.to_numeric(df["price"], errors="coerce").fillna(0)
    df["line_total"] = (df["quantity"] * df["price"]).round(2)
    df["invoice_date"] = pd.to_datetime(df["invoice_date"]).dt.strftime("%Y-%m-%d %H:%M:%S")
    
    cols = ["invoice", "stock_code", "description", "quantity", "invoice_date", "price", "customer_id", "country", "line_total"]
    df = df[cols]
    df.to_sql("fact_retail_transactions", conn, if_exists="append", index=False)
    print(f"           -> {len(df)} transaction line items loaded.")

def run_pipeline():
    init_database()
    conn = get_connection()
    ingest_rfm_clv_data(conn)
    ingest_sample_transactions(conn)
    
    print("\n[Pipeline Verification] Summary of RFM Segments:")
    res = pd.read_sql_query("""
        SELECT rfm_segment, COUNT(*) as customers, ROUND(SUM(monetary_total), 2) as revenue,
               ROUND(AVG(recency_days), 1) as avg_recency, ROUND(AVG(frequency_orders), 1) as avg_frequency
        FROM fact_customer_rfm
        GROUP BY rfm_segment
        ORDER BY revenue DESC
    """, conn)
    print(res.to_string(index=False))
    
    conn.close()
    print("\n[Pipeline Complete] Customer & Marketing Analytics DW is ready.")

if __name__ == "__main__":
    run_pipeline()

