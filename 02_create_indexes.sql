-- =====================================================
-- 02_create_indexes.sql
-- FinanceCore 
-- =====================================================

CREATE INDEX idx_comptes_client_id ON comptes(client_id);

CREATE INDEX idx_transactions_date ON transactions(date_transaction);
CREATE INDEX idx_transactions_agence_id ON transactions(agence_id);
CREATE INDEX idx_transactions_compte_id ON transactions(compte_id);
CREATE INDEX idx_transactions_categorie_id ON transactions(categorie_id);
CREATE INDEX idx_transactions_type_operation_id ON transactions(type_operation_id);
CREATE INDEX idx_transactions_statut_id ON transactions(statut_id);
CREATE INDEX idx_transactions_segment_id ON transactions(segment_id);
CREATE INDEX idx_transactions_risque_id ON transactions(risque_id);
CREATE INDEX idx_transactions_agence_date ON transactions(agence_id, date_transaction);