-- =====================================================
-- 05_integrity_checks.sql
-- FinanceCore 
-- Data load validation and integrity checks
-- =====================================================

-- 1. Row counts by table
SELECT 'devises' AS table_name, COUNT(*) AS nb FROM devises
UNION ALL
SELECT 'agences', COUNT(*) FROM agences
UNION ALL
SELECT 'produits', COUNT(*) FROM produits
UNION ALL
SELECT 'categories_transaction', COUNT(*) FROM categories_transaction
UNION ALL
SELECT 'types_operation', COUNT(*) FROM types_operation
UNION ALL
SELECT 'statuts_transaction', COUNT(*) FROM statuts_transaction
UNION ALL
SELECT 'segments_client', COUNT(*) FROM segments_client
UNION ALL
SELECT 'categories_risque', COUNT(*) FROM categories_risque
UNION ALL
SELECT 'clients', COUNT(*) FROM clients
UNION ALL
SELECT 'comptes', COUNT(*) FROM comptes
UNION ALL
SELECT 'transactions', COUNT(*) FROM transactions;

-- 2. Direct count of transactions
SELECT COUNT(*) AS nb_transactions
FROM transactions;

-- 3. Transactions without a valid account
SELECT COUNT(*) AS transactions_sans_compte
FROM transactions t
LEFT JOIN comptes c ON t.compte_id = c.compte_id
WHERE c.compte_id IS NULL;

-- 4. Accounts without a valid client
SELECT COUNT(*) AS comptes_sans_client
FROM comptes cp
LEFT JOIN clients c ON cp.client_id = c.client_id
WHERE c.client_id IS NULL;

-- 5. Duplicate transaction IDs
SELECT
    transaction_id,
    COUNT(*) AS nb
FROM transactions
GROUP BY transaction_id
HAVING COUNT(*) > 1;