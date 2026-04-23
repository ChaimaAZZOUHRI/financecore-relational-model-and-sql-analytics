import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# 1. Load environment variables
# =====================================================
load_dotenv()

DB_USER = os.getenv("DB_USER", "postgres")
DB_PASSWORD = os.getenv("DB_PASSWORD", "postgres")
DB_HOST = os.getenv("DB_HOST", "localhost")
DB_PORT = os.getenv("DB_PORT", "5432")
DB_NAME = os.getenv("DB_NAME", "financecore_db")
CSV_FILE = os.getenv("CSV_FILE", "financecore_clean.csv")


# 2. Create SQLAlchemy engine
# =====================================================
engine = create_engine(
    f"postgresql+psycopg2://{DB_USER}:{DB_PASSWORD}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
)


# 3. Read CSV
# =====================================================
df = pd.read_csv(CSV_FILE)
df.columns = [c.strip().lower() for c in df.columns]


# 4. Basic cleaning
# =====================================================
# Dates
df["date_transaction"] = pd.to_datetime(df["date_transaction"], errors="coerce")

# Text columns
text_cols = [
    "transaction_id",
    "client_id",
    "devise",
    "categorie",
    "produit",
    "agence",
    "type_operation",
    "statut",
    "segment_client",
    "categorie_risque",
]
for col in text_cols:
    df[col] = df[col].astype(str).str.strip()

# Normalize currency code
df["devise"] = df["devise"].str.upper()

# Numeric columns
numeric_cols = [
    "montant",
    "taux_change_eur",
    "montant_eur",
    "score_credit_client",
    "solde_avant",
]
for col in numeric_cols:
    df[col] = pd.to_numeric(df[col], errors="coerce")

# Boolean columns
def to_bool(x):
    if pd.isna(x):
        return False
    if isinstance(x, bool):
        return x
    x = str(x).strip().lower()
    return x in ["1", "true", "t", "yes", "y"]

bool_cols = [
    "amount_iqr_outlier",
    "amount_rule_outlier",
    "score_invalid",
    "is_anomaly",
]
for col in bool_cols:
    df[col] = df[col].apply(to_bool)

# Remove rows with essential missing values
required_cols = [
    "transaction_id",
    "client_id",
    "date_transaction",
    "montant",
    "montant_eur",
    "devise",
    "produit",
    "agence",
    "categorie",
    "type_operation",
    "statut",
    "segment_client",
    "categorie_risque",
    "score_credit_client",
    "solde_avant",
]
df = df.dropna(subset=required_cols)


# 5. Create technical account reference
# =====================================================
df["compte_reference"] = (
    df["client_id"].astype(str)
    + "_"
    + df["produit"].astype(str)
    + "_"
    + df["devise"].astype(str)
)


# 6. Create staging table
# =====================================================
with engine.begin() as conn:
    conn.execute(text("DROP TABLE IF EXISTS stg_financecore;"))

df.to_sql("stg_financecore", engine, if_exists="replace", index=False)


# 7. Insert into normalized tables
# =====================================================
sql_statements = [

    # 7.1 devises
    """
    INSERT INTO devises (devise_code, taux_change_eur)
    SELECT devise, MAX(taux_change_eur) AS taux_change_eur
    FROM stg_financecore
    WHERE devise IS NOT NULL
    GROUP BY devise
    ON CONFLICT (devise_code) DO NOTHING;
    """,

    # 7.2 agences
    """
    INSERT INTO agences (agence_nom)
    SELECT DISTINCT agence
    FROM stg_financecore
    WHERE agence IS NOT NULL
    ON CONFLICT (agence_nom) DO NOTHING;
    """,

    # 7.3 produits
    """
    INSERT INTO produits (produit_nom)
    SELECT DISTINCT produit
    FROM stg_financecore
    WHERE produit IS NOT NULL
    ON CONFLICT (produit_nom) DO NOTHING;
    """,

    # 7.4 categories_transaction
    """
    INSERT INTO categories_transaction (categorie_nom)
    SELECT DISTINCT categorie
    FROM stg_financecore
    WHERE categorie IS NOT NULL
    ON CONFLICT (categorie_nom) DO NOTHING;
    """,

    # 7.5 types_operation
    """
    INSERT INTO types_operation (type_operation_nom)
    SELECT DISTINCT type_operation
    FROM stg_financecore
    WHERE type_operation IS NOT NULL
    ON CONFLICT (type_operation_nom) DO NOTHING;
    """,

    # 7.6 statuts_transaction
    """
    INSERT INTO statuts_transaction (statut_nom)
    SELECT DISTINCT statut
    FROM stg_financecore
    WHERE statut IS NOT NULL
    ON CONFLICT (statut_nom) DO NOTHING;
    """,

    # 7.7 segments_client
    """
    INSERT INTO segments_client (segment_nom)
    SELECT DISTINCT segment_client
    FROM stg_financecore
    WHERE segment_client IS NOT NULL
    ON CONFLICT (segment_nom) DO NOTHING;
    """,

    # 7.8 categories_risque
    """
    INSERT INTO categories_risque (risque_nom)
    SELECT DISTINCT categorie_risque
    FROM stg_financecore
    WHERE categorie_risque IS NOT NULL
    ON CONFLICT (risque_nom) DO NOTHING;
    """,

    # 7.9 clients
    """
    INSERT INTO clients (client_id)
    SELECT DISTINCT client_id
    FROM stg_financecore
    WHERE client_id IS NOT NULL
    ON CONFLICT (client_id) DO NOTHING;
    """,

    # 7.10 comptes
    """
    INSERT INTO comptes (compte_reference, client_id, produit_id, devise_code)
    SELECT DISTINCT
        s.compte_reference,
        s.client_id,
        p.produit_id,
        s.devise
    FROM stg_financecore s
    JOIN produits p
      ON s.produit = p.produit_nom
    WHERE s.compte_reference IS NOT NULL
      AND s.client_id IS NOT NULL
      AND s.devise IS NOT NULL
    ON CONFLICT (compte_reference) DO NOTHING;
    """,

    # 7.11 transactions
    """
    INSERT INTO transactions (
        transaction_id,
        compte_id,
        agence_id,
        categorie_id,
        type_operation_id,
        statut_id,
        segment_id,
        risque_id,
        date_transaction,
        montant,
        montant_eur,
        solde_avant,
        score_credit_client,
        amount_iqr_outlier,
        amount_rule_outlier,
        score_invalid,
        is_anomaly
    )
    SELECT
        s.transaction_id,
        cp.compte_id,
        a.agence_id,
        ct.categorie_id,
        ty.type_operation_id,
        st.statut_id,
        sg.segment_id,
        rs.risque_id,
        s.date_transaction,
        s.montant,
        s.montant_eur,
        s.solde_avant,
        s.score_credit_client,
        s.amount_iqr_outlier,
        s.amount_rule_outlier,
        s.score_invalid,
        s.is_anomaly
    FROM stg_financecore s
    JOIN comptes cp
      ON s.compte_reference = cp.compte_reference
    JOIN agences a
      ON s.agence = a.agence_nom
    JOIN categories_transaction ct
      ON s.categorie = ct.categorie_nom
    JOIN types_operation ty
      ON s.type_operation = ty.type_operation_nom
    JOIN statuts_transaction st
      ON s.statut = st.statut_nom
    JOIN segments_client sg
      ON s.segment_client = sg.segment_nom
    JOIN categories_risque rs
      ON s.categorie_risque = rs.risque_nom
    WHERE s.transaction_id IS NOT NULL
    ON CONFLICT (transaction_id) DO NOTHING;
    """
]


# 8. Execute inserts
# =====================================================
with engine.begin() as conn:
    for stmt in sql_statements:
        conn.execute(text(stmt))

print("Chargement terminé avec succès.")

print("CSV file:", CSV_FILE)
with engine.connect() as conn:
    print("Database connection successful")