-- =====================================================
-- 04_analytics_queries.sql
-- FinanceCore 
-- Advanced analytical SQL queries
-- =====================================================

-- 1. Total and average transactions by agency and month
SELECT
    a.agence_nom,
    DATE_TRUNC('month', t.date_transaction) AS mois,
    COUNT(*) AS nb_transactions,
    SUM(t.montant_eur) AS total_transactions_eur,
    AVG(t.montant_eur) AS moyenne_transactions_eur
FROM transactions t
JOIN agences a ON t.agence_id = a.agence_id
GROUP BY a.agence_nom, DATE_TRUNC('month', t.date_transaction)
ORDER BY a.agence_nom, mois;

-- 2. Total and average transactions by product and month
SELECT
    p.produit_nom,
    DATE_TRUNC('month', t.date_transaction) AS mois,
    COUNT(*) AS nb_transactions,
    SUM(t.montant_eur) AS total_transactions_eur,
    AVG(t.montant_eur) AS moyenne_transactions_eur
FROM transactions t
JOIN comptes cp ON t.compte_id = cp.compte_id
JOIN produits p ON cp.produit_id = p.produit_id
GROUP BY p.produit_nom, DATE_TRUNC('month', t.date_transaction)
ORDER BY p.produit_nom, mois;

-- 3. Clients with a balance below the national average
SELECT DISTINCT
    c.client_id,
    t.solde_avant
FROM transactions t
JOIN comptes cp ON t.compte_id = cp.compte_id
JOIN clients c ON cp.client_id = c.client_id
WHERE t.solde_avant < (
    SELECT AVG(solde_avant)
    FROM transactions
)
ORDER BY t.solde_avant ASC;

-- 4. Rejection rate by client segment using CASE WHEN
SELECT
    sg.segment_nom,
    COUNT(*) AS nb_transactions,
    SUM(
        CASE
            WHEN LOWER(st.statut_nom) IN ('rejete', 'rejeté', 'rejected') THEN 1
            ELSE 0
        END
    ) AS nb_rejets,
    ROUND(
        100.0 * SUM(
            CASE
                WHEN LOWER(st.statut_nom) IN ('rejete', 'rejeté', 'rejected') THEN 1
                ELSE 0
            END
        ) / COUNT(*),
        2
    ) AS taux_rejet_pct
FROM transactions t
JOIN segments_client sg ON t.segment_id = sg.segment_id
JOIN statuts_transaction st ON t.statut_id = st.statut_id
GROUP BY sg.segment_nom
ORDER BY taux_rejet_pct DESC;

-- 5. Multi-table join: full detail of transactions
SELECT
    t.transaction_id,
    c.client_id,
    a.agence_nom,
    p.produit_nom,
    d.devise_code,
    ct.categorie_nom,
    ty.type_operation_nom,
    st.statut_nom,
    sg.segment_nom,
    rs.risque_nom,
    t.date_transaction,
    t.montant,
    t.montant_eur,
    t.solde_avant,
    t.score_credit_client
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
JOIN categories_risque rs ON t.risque_id = rs.risque_id
ORDER BY t.date_transaction DESC;