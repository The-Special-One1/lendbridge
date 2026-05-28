-- ============================================================
-- LendBridge - Queries Comuns
-- ============================================================

-- ============================================================
-- INSERTS - Cadastros típicos
-- ============================================================

-- Cadastrar novo usuário (borrower)
INSERT INTO "users" ("first_name", "last_name", "email", "password_hash", "phone", "date_of_birth", "national_id", "user_type")
VALUES ('John', 'Silva', 'john@example.com', 'hash_aqui', '+258840000001', '1990-05-15', '123456789', 'borrower');

-- Cadastrar novo investidor
INSERT INTO "users" ("first_name", "last_name", "email", "password_hash", "phone", "date_of_birth", "national_id", "user_type")
VALUES ('Maria', 'Costa', 'maria@example.com', 'hash_aqui', '+258840000002', '1985-08-20', '987654321', 'investor');

-- Criar wallet para o usuário
INSERT INTO "wallets" ("user_id", "balance", "available_balance")
VALUES (1, 0.00, 0.00);

-- Adicionar endereço
INSERT INTO "addresses" ("user_id", "street", "city", "state", "postal_code", "country")
VALUES (1, 'Av. Julius Nyerere, 123', 'Maputo', 'Maputo', '1100', 'Mozambique');

-- Adicionar conta bancária
INSERT INTO "bank_accounts" ("user_id", "bank_name", "account_number", "account_type", "is_verified")
VALUES (1, 'Banco BCI', '12345-6789-0', 'checking', 1);

-- Solicitar empréstimo
INSERT INTO "loan_requests" ("borrower_id", "amount_requested", "purpose", "term_months", "interest_rate")
VALUES (1, 50000.00, 'Capital de giro para pequeno negócio', 12, 12.5);

-- 