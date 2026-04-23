-- =====================================================
-- 03_load_views.sql
-- FinanceCore 
-- Views to simplify joins and prepare dashboards
-- =====================================================


CREATE OR REPLACE VIEW vw_transactions_detail AS
SELECT
    t.transaction_id,
    c.client_id,
    cp.compte_reference,
    a.agence_nom,
    p.produit_nom,
    d.devise_code,
    d.taux_change_eur,
    ct.categorie_nom,
    ty.type_operation_nom,
    st.statut_nom,
    sg.segment_nom,
    rs.risque_nom,
    t.date_transaction,
    t.montant,
    t.montant_eur,
    t.solde_avant,
    t.score_credit_client,
    t.amount_iqr_outlier,
    t.amount_rule_outlier,
    t.score_invalid,
    t.is_anomaly
FROM transactions t
JOIN comptes cp ON t.compte_id = cp.compte_id
JOIN clients c ON cp.client_id = c.client_id
JOIN agences a ON t.agence_id = a.agence_id
JOIN produits p ON cp.produit_id = p.produit_id
JOIN devises d ON cp.devise_code = d.devise_code
JOIN categories_transaction ct ON t.categorie_id = ct.categorie_id
JOIN types_operation ty ON t.type_operation_id = ty.type_operation_id
JOIN statuts_transaction st ON t.statut_id = st.statut_id
JOIN segments_client sg ON t.segment_id = sg.segment_id
JOIN categories_risque rs ON t.risque_id = rs.risque_id;

CREATE OR REPLACE VIEW vw_dashboard_base AS
SELECT
    t.transaction_id,
    c.client_id,
    a.agence_nom,
    p.produit_nom,
    sg.segment_nom,
    rs.risque_nom,
    ct.categorie_nom,
    ty.type_operation_nom,
    st.statut_nom,
    d.devise_code,
    t.date_transaction,
    EXTRACT(YEAR FROM t.date_transaction) AS annee,
    EXTRACT(MONTH FROM t.date_transaction) AS mois,
    EXTRACT(QUARTER FROM t.date_transaction) AS trimestre,
    t.montant,
    t.montant_eur,
    t.solde_avant,
    t.score_credit_client,
    t.amount_iqr_outlier,
    t.amount_rule_outlier,
    t.score_invalid,
    t.is_anomaly,
    CASE
        WHEN LOWER(ty.type_operation_nom) = 'credit' THEN t.montant_eur
        ELSE 0
    END AS credit_amount_eur,
    CASE
        WHEN LOWER(ty.type_operation_nom) = 'debit' THEN ABS(t.montant_eur)
        ELSE 0
    END AS debit_amount_eur,
    CASE
        WHEN LOWER(st.statut_nom) IN ('rejete', 'rejeté', 'rejected') THEN 1
        ELSE 0
    END AS is_rejected
FROM transactions t
JOIN comptes cp ON t.compte_id = cp.compte_id
JOIN clients c ON cp.client_id = c.client_id
JOIN agences a ON t.agence_id = a.agence_id
JOIN produits p ON cp.produit_id = p.produit_id
JOIN devises d ON cp.devise_code = d.devise_code
JOIN categories_transaction ct ON t.categorie_id = ct.categorie_id
JOIN types_operation ty ON t.type_operation_id = ty.type_operation_id
JOIN statuts_transaction st ON t.statut_id = st.statut_id
JOIN segments_client sg ON t.segment_id = sg.segment_id
JOIN categories_risque rs ON t.risque_id = rs.risque_id;