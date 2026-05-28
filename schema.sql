-- ============================================================
-- LendBridge - Plataforma de Empréstimos P2P (FinTech)
-- Schema do Banco de Dados
-- ============================================================

-- ============================================================
-- TABELA: users
-- Representa todos os usuários da plataforma
-- ============================================================
CREATE TABLE "users" (
    "id" INTEGER,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "email" TEXT NOT NULL UNIQUE,
    "password_hash" TEXT NOT NULL,
    "phone" TEXT,
    "date_of_birth" NUMERIC NOT NULL,
    "national_id" TEXT NOT NULL UNIQUE,
    "user_type" TEXT NOT NULL CHECK("user_type" IN ('borrower', 'investor', 'both')),
    "kyc_status" TEXT NOT NULL DEFAULT 'pending' CHECK("kyc_status" IN ('pending', 'verified', 'rejected')),
    "registration_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "is_active" INTEGER NOT NULL DEFAULT 1 CHECK("is_active" IN (0, 1)),
    PRIMARY KEY("id")
);

-- ============================================================
-- TABELA: addresses
-- Endereços dos usuários
-- ============================================================
CREATE TABLE "addresses" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "street" TEXT NOT NULL,
    "city" TEXT NOT NULL,
    "state" TEXT NOT NULL,
    "postal_code" TEXT NOT NULL,
    "country" TEXT NOT NULL,
    "is_primary" INTEGER NOT NULL DEFAULT 1 CHECK("is_primary" IN (0, 1)),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);

-- ============================================================
-- TABELA: bank_accounts
-- Contas bancárias dos usuários (depósitos e saques)
-- ============================================================
CREATE TABLE "bank_accounts" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "bank_name" TEXT NOT NULL,
    "account_number" TEXT NOT NULL,
    "account_type" TEXT NOT NULL CHECK("account_type" IN ('checking', 'savings')),
    "is_verified" INTEGER NOT NULL DEFAULT 0 CHECK("is_verified" IN (0, 1)),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);

-- ============================================================
-- TABELA: wallets
-- Carteira digital interna de cada usuário
-- ============================================================
CREATE TABLE "wallets" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL UNIQUE,
    "balance" REAL NOT NULL DEFAULT 0.00,
    "available_balance" REAL NOT NULL DEFAULT 0.00,
    "blocked_balance" REAL NOT NULL DEFAULT 0.00,
    "last_updated" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);

-- ============================================================
-- TABELA: credit_scores
-- Histórico de scores de crédito dos tomadores
-- ============================================================
CREATE TABLE "credit_scores" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "score" INTEGER NOT NULL CHECK("score" BETWEEN 300 AND 850),
    "risk_level" TEXT NOT NULL CHECK("risk_level" IN ('low', 'medium', 'high', 'very_high')),
    "calculated_at" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id")
);

-- ============================================================
-- TABELA: loan_requests
-- Solicitações de empréstimo dos borrowers
-- ============================================================
CREATE TABLE "loan_requests" (
    "id" INTEGER,
    "borrower_id" INTEGER NOT NULL,
    "amount_requested" REAL NOT NULL CHECK("amount_requested" > 0),
    "purpose" TEXT NOT NULL,
    "term_months" INTEGER NOT NULL CHECK("term_months" BETWEEN 1 AND 60),
    "interest_rate" REAL NOT NULL CHECK("interest_rate" >= 0),
    "status" TEXT NOT NULL DEFAULT 'pending' CHECK("status" IN ('pending', 'approved', 'rejected', 'funded', 'cancelled')),
    "requested_at" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "reviewed_at" NUMERIC,
    PRIMARY KEY("id"),
    FOREIGN KEY("borrower_id") REFERENCES "users"("id")
);

-- ============================================================
-- TABELA: loans
-- Empréstimos ativos (após aprovação e financiamento)
-- ============================================================
CREATE TABLE "loans" (
    "id" INTEGER,
    "loan_request_id" INTEGER NOT NULL UNIQUE,
    "borrower_id" INTEGER NOT NULL,
    "principal_amount" REAL NOT NULL,
    "total_amount" REAL NOT NULL,
    "interest_rate" REAL NOT NULL,
    "term_months" INTEGER NOT NULL,
    "monthly_payment" REAL NOT NULL,
    "start_date" NUMERIC NOT NULL,
    "end_date" NUMERIC NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK("status" IN ('active', 'completed', 'defaulted', 'cancelled')),
    PRIMARY KEY("id"),
    FOREIGN KEY("loan_request_id") REFERENCES "loan_requests"("id"),
    FOREIGN KEY("borrower_id") REFERENCES "users"("id")
);

-- ============================================================
-- TABELA: investments
-- Investimentos dos lenders em empréstimos específicos
-- ============================================================
CREATE TABLE "investments" (
    "id" INTEGER,
    "loan_id" INTEGER NOT NULL,
    "investor_id" INTEGER NOT NULL,
    "amount_invested" REAL NOT NULL CHECK("amount_invested" > 0),
    "expected_return" REAL NOT NULL,
    "investment_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL DEFAULT 'active' CHECK("status" IN ('active', 'completed', 'defaulted')),
    PRIMARY KEY("id"),
    FOREIGN KEY("loan_id") REFERENCES "loans"("id"),
    FOREIGN KEY("investor_id") REFERENCES "users"("id")
);

-- ============================================================
-- TABELA: installments
-- Parcelas de cada empréstimo
-- ============================================================
CREATE TABLE "installments" (
    "id" INTEGER,
    "loan_id" INTEGER NOT NULL,
    "installment_number" INTEGER NOT NULL,
    "due_date" NUMERIC NOT NULL,
    "amount" REAL NOT NULL,
    "principal_portion" REAL NOT NULL,
    "interest_portion" REAL NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'pending' CHECK("status" IN ('pending', 'paid', 'overdue', 'partial')),
    "paid_at" NUMERIC,
    "paid_amount" REAL DEFAULT 0,
    PRIMARY KEY("id"),
    FOREIGN KEY("loan_id") REFERENCES "loans"("id")
);

-- ============================================================
-- TABELA: transactions
-- Histórico completo de movimentações financeiras
-- ============================================================
CREATE TABLE "transactions" (
    "id" INTEGER,
    "user_id" INTEGER NOT NULL,
    "type" TEXT NOT NULL CHECK("type" IN ('deposit', 'withdrawal', 'investment', 'loan_disbursement', 'loan_payment', 'return', 'fee')),
    "amount" REAL NOT NULL,
    "description" TEXT,
    "related_loan_id" INTEGER,
    "related_investment_id" INTEGER,
    "transaction_date" NUMERIC NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "status" TEXT NOT NULL DEFAULT 'completed' CHECK("status" IN ('pending', 'completed', 'failed', 'reversed')),
    PRIMARY KEY("id"),
    FOREIGN KEY("user_id") REFERENCES "users"("id"),
    FOREIGN KEY("related_loan_id") REFERENCES "loans"("id"),
    FOREIGN KEY("related_investment_id") REFERENCES "investments"("id")
);

-- ============================================================
-- ÍNDICES para otimizar queries frequentes
-- ============================================================

CREATE INDEX "idx_users_email" ON "users"("email");
CREATE INDEX "idx_transactions_user" ON "transactions"("user_id");
CREATE INDEX "idx_transactions_date" ON "transactions"("transaction_date");
CREATE INDEX "idx_loans_borrower" ON "loans"("borrower_id");
CREATE INDEX "idx_loans_status" ON "loans"("status");
CREATE INDEX "idx_investments_investor" ON "investments"("investor_id");
CREATE INDEX "idx_installments_loan" ON "installments"("loan_id");
CREATE INDEX "idx_installments_due_status" ON "installments"("due_date", "status");
CREATE INDEX "idx_credit_scores_user" ON "credit_scores"("user_id");

-- ============================================================
-- VIEWS para análises e dashboards
-- ============================================================

-- View: Empréstimos ativos com informações do borrower
CREATE VIEW "active_loans_view" AS
SELECT
    l.id AS loan_id,
    l.principal_amount,
    l.total_amount,
    l.interest_rate,
    l.monthly_payment,
    l.start_date,
    l.end_date,
    u.first_name || ' ' || u.last_name AS borrower_name,
    u.email AS borrower_email,
    cs.score AS credit_score,
    cs.risk_level
FROM loans l
JOIN users u ON l.borrower_id = u.id
LEFT JOIN credit_scores cs ON cs.user_id = u.id
WHERE l.status = 'active';

-- View: Performance dos investidores
CREATE VIEW "investor_performance" AS
SELECT
    u.id AS investor_id,
    u.first_name || ' ' || u.last_name AS investor_name,
    COUNT(i.id) AS total_investments,
    SUM(i.amount_invested) AS total_invested,
    SUM(i.expected_return) AS total_expected_return,
    SUM(CASE WHEN i.status = 'completed' THEN i.expected_return ELSE 0 END) AS realized_returns
FROM users u
JOIN investments i ON u.id = i.investor_id
GROUP BY u.id;

-- View: Parcelas vencidas
CREATE VIEW "overdue_installments" AS
SELECT
    i.id AS installment_id,
    i.loan_id,
    i.installment_number,
    i.due_date,
    i.amount,
    u.first_name || ' ' || u.last_name AS borrower_name,
    u.email AS borrower_email,
    julianday('now') - julianday(i.due_date) AS days_overdue
FROM installments i
JOIN loans l ON i.loan_id = l.id
JOIN users u ON l.borrower_id = u.id
WHERE i.status IN ('pending', 'overdue')
AND i.due_date < date('now');

-- View: Resumo financeiro por usuário
CREATE VIEW "user_financial_summary" AS
SELECT
    u.id AS user_id,
    u.first_name || ' ' || u.last_name AS full_name,
    u.user_type,
    w.balance AS wallet_balance,
    COALESCE((SELECT SUM(amount_invested) FROM investments WHERE investor_id = u.id), 0) AS total_invested,
    COALESCE((SELECT SUM(principal_amount) FROM loans WHERE borrower_id = u.id AND status = 'active'), 0) AS total_borrowed
FROM users u
LEFT JOIN wallets w ON u.id = w.user_id;