-- =====================================================
-- 01_create_tables.sql
-- FinanceCore
-- =====================================================

CREATE TABLE devises (
    devise_code VARCHAR(3) PRIMARY KEY,
    taux_change_eur NUMERIC(12,6) NOT NULL,
    CONSTRAINT chk_devise_upper CHECK (devise_code = UPPER(devise_code))
);

CREATE TABLE agences (
    agence_id SERIAL PRIMARY KEY,
    agence_nom VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE produits (
    produit_id SERIAL PRIMARY KEY,
    produit_nom VARCHAR(150) NOT NULL UNIQUE
);

CREATE TABLE categories_transaction (
    categorie_id SERIAL PRIMARY KEY,
    categorie_nom VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE types_operation (
    type_operation_id SERIAL PRIMARY KEY,
    type_operation_nom VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE statuts_transaction (
    statut_id SERIAL PRIMARY KEY,
    statut_nom VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE segments_client (
    segment_id SERIAL PRIMARY KEY,
    segment_nom VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE categories_risque (
    risque_id SERIAL PRIMARY KEY,
    risque_nom VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE clients (
    client_id VARCHAR(50) PRIMARY KEY
);

CREATE TABLE comptes (
    compte_id SERIAL PRIMARY KEY,
    compte_reference VARCHAR(200) NOT NULL UNIQUE,
    client_id VARCHAR(50) NOT NULL,
    produit_id INT NOT NULL,
    devise_code VARCHAR(3) NOT NULL,
    CONSTRAINT fk_compte_client
        FOREIGN KEY (client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_compte_produit
        FOREIGN KEY (produit_id) REFERENCES produits(produit_id),
    CONSTRAINT fk_compte_devise
        FOREIGN KEY (devise_code) REFERENCES devises(devise_code)
);

CREATE TABLE transactions (
    transaction_id VARCHAR(100) PRIMARY KEY,
    compte_id INT NOT NULL,
    agence_id INT NOT NULL,
    categorie_id INT NOT NULL,
    type_operation_id INT NOT NULL,
    statut_id INT NOT NULL,
    segment_id INT NOT NULL,
    risque_id INT NOT NULL,

    date_transaction TIMESTAMP NOT NULL,
    montant NUMERIC(18,2) NOT NULL,
    montant_eur NUMERIC(18,2) NOT NULL,
    solde_avant NUMERIC(18,2) NOT NULL,
    score_credit_client NUMERIC(10,2) NOT NULL,

    amount_iqr_outlier BOOLEAN NOT NULL DEFAULT FALSE,
    amount_rule_outlier BOOLEAN NOT NULL DEFAULT FALSE,
    score_invalid BOOLEAN NOT NULL DEFAULT FALSE,
    is_anomaly BOOLEAN NOT NULL DEFAULT FALSE,

    CONSTRAINT fk_transaction_compte
        FOREIGN KEY (compte_id) REFERENCES comptes(compte_id),
    CONSTRAINT fk_transaction_agence
        FOREIGN KEY (agence_id) REFERENCES agences(agence_id),
    CONSTRAINT fk_transaction_categorie
        FOREIGN KEY (categorie_id) REFERENCES categories_transaction(categorie_id),
    CONSTRAINT fk_transaction_type
        FOREIGN KEY (type_operation_id) REFERENCES types_operation(type_operation_id),
    CONSTRAINT fk_transaction_statut
        FOREIGN KEY (statut_id) REFERENCES statuts_transaction(statut_id),
    CONSTRAINT fk_transaction_segment
        FOREIGN KEY (segment_id) REFERENCES segments_client(segment_id),
    CONSTRAINT fk_transaction_risque
        FOREIGN KEY (risque_id) REFERENCES categories_risque(risque_id)
);