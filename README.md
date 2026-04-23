# FinanceCore SA — Relational modeling, PostgreSQL storage, and SQL analytics

  
The objective of this project is to design a **normalized relational database model (3NF)** from the cleaned file `financecore_clean.csv`, implement it in **PostgreSQL**, load the data with **Python and SQLAlchemy**, and produce the first **analytical SQL queries and views** needed for business reporting.

## Project objectives

- Design a coherent **3NF relational model**
- Separate the main entities: clients, accounts, transactions, products, agencies, currencies, segments, and risk categories
- Create the PostgreSQL tables with:
  - primary keys
  - foreign keys
  - uniqueness constraints
  - integrity rules
- Load cleaned CSV data into the normalized schema using **Python + SQLAlchemy**
- Create SQL queries with:
  - `SELECT`
  - `WHERE`
  - `GROUP BY`
  - `ORDER BY`
  - `JOIN`
  - `CASE WHEN`
  - subqueries
- Verify data integrity after insertion
- Prepare analytical views for the next dashboard exercise

## Project structure

```text
financecore-relational-model-and-sql-analytics/
│
├── 01_create_table.sql
├── 02_create_indexes.sql
├── 03_load_views.sql
├── 04_analytics_queries.sql
├── 05_integrity_checks.sql
├── load_financecore.py
├── DBML_financecore.sql
├── DBML_financecore.pdf
└── README.md
