CREATE TABLE "devises" (
  "devise_code" varchar(3) PRIMARY KEY,
  "taux_change_eur" numeric NOT NULL
);

CREATE TABLE "agences" (
  "agence_id" serial PRIMARY KEY,
  "agence_nom" varchar UNIQUE NOT NULL
);

CREATE TABLE "produits" (
  "produit_id" serial PRIMARY KEY,
  "produit_nom" varchar UNIQUE NOT NULL
);

CREATE TABLE "categories_transaction" (
  "categorie_id" serial PRIMARY KEY,
  "categorie_nom" varchar UNIQUE NOT NULL
);

CREATE TABLE "types_operation" (
  "type_operation_id" serial PRIMARY KEY,
  "type_operation_nom" varchar UNIQUE NOT NULL
);

CREATE TABLE "statuts_transaction" (
  "statut_id" serial PRIMARY KEY,
  "statut_nom" varchar UNIQUE NOT NULL
);

CREATE TABLE "segments_client" (
  "segment_id" serial PRIMARY KEY,
  "segment_nom" varchar UNIQUE NOT NULL
);

CREATE TABLE "categories_risque" (
  "risque_id" serial PRIMARY KEY,
  "risque_nom" varchar UNIQUE NOT NULL
);

CREATE TABLE "clients" (
  "client_id" varchar PRIMARY KEY
);

CREATE TABLE "comptes" (
  "compte_id" serial PRIMARY KEY,
  "compte_reference" varchar UNIQUE NOT NULL,
  "client_id" varchar NOT NULL,
  "produit_id" int NOT NULL,
  "devise_code" varchar(3) NOT NULL
);

CREATE TABLE "transactions" (
  "transaction_id" varchar PRIMARY KEY,
  "compte_id" int NOT NULL,
  "agence_id" int NOT NULL,
  "categorie_id" int NOT NULL,
  "type_operation_id" int NOT NULL,
  "statut_id" int NOT NULL,
  "segment_id" int NOT NULL,
  "risque_id" int NOT NULL,
  "date_transaction" timestamp NOT NULL,
  "montant" numeric NOT NULL,
  "montant_eur" numeric NOT NULL,
  "solde_avant" numeric NOT NULL,
  "score_credit_client" numeric NOT NULL,
  "amount_iqr_outlier" boolean NOT NULL,
  "amount_rule_outlier" boolean NOT NULL,
  "score_invalid" boolean NOT NULL,
  "is_anomaly" boolean NOT NULL
);

ALTER TABLE "comptes" ADD FOREIGN KEY ("client_id") REFERENCES "clients" ("client_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comptes" ADD FOREIGN KEY ("produit_id") REFERENCES "produits" ("produit_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "comptes" ADD FOREIGN KEY ("devise_code") REFERENCES "devises" ("devise_code") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("compte_id") REFERENCES "comptes" ("compte_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("agence_id") REFERENCES "agences" ("agence_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("categorie_id") REFERENCES "categories_transaction" ("categorie_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("type_operation_id") REFERENCES "types_operation" ("type_operation_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("statut_id") REFERENCES "statuts_transaction" ("statut_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("segment_id") REFERENCES "segments_client" ("segment_id") DEFERRABLE INITIALLY IMMEDIATE;

ALTER TABLE "transactions" ADD FOREIGN KEY ("risque_id") REFERENCES "categories_risque" ("risque_id") DEFERRABLE INITIALLY IMMEDIATE;
