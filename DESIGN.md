# LendBridge - Plataforma de Empréstimos P2P

By Santo António Arcanjo

Video overview: <URL DO VÍDEO YOUTUBE>

## Scope

O **LendBridge** é uma plataforma de empréstimos peer-to-peer (P2P) que conecta investidores diretamente a tomadores de crédito, eliminando intermediários bancários tradicionais. O banco de dados foi projetado para suportar todas as operações fundamentais de uma FinTech moderna no segmento de microcrédito.

### O que está incluído no escopo:

* **Usuários** (borrowers, investidores, ou ambos), com informações pessoais e KYC
* **Endereços** dos usuários para verificação e cobrança
* **Contas bancárias** para depósitos e saques
* **Carteiras digitais** internas (wallets) com saldo disponível e bloqueado
* **Credit scores** e níveis de risco para avaliação de tomadores
* **Solicitações de empréstimo** com workflow de aprovação
* **Empréstimos ativos** com taxas, prazos e parcelas
* **Investimentos** dos lenders em empréstimos específicos
* **Parcelas** de pagamento com controle de vencimento
* **Transações** de todas as movimentações financeiras

### O que está fora do escopo:

* Sistema de autenticação multi-fator (MFA)
* Mensageria entre usuários
* Sistema de notificações push
* Análise antifraude em tempo real
* Integração direta com bureaus de crédito externos
* Conformidade com regulações específicas de cada país (PCI-DSS, GDPR, LGPD)

## Functional Requirements

Os usuários do banco de dados podem:

* **Criar e gerenciar contas** de usuário com diferentes papéis (borrower, investor, both)
* **Verificar identidade** através de processo KYC
* **Adicionar contas bancárias** verificadas para movimentações
* **Solicitar empréstimos** especificando valor, prazo e finalidade
* **Investir em empréstimos** parcial ou totalmente
* **Acompanhar performance** de investimentos e empréstimos
* **Visualizar histórico** completo de transações
* **Identificar parcelas vencidas** e gerenciar inadimplência
* **Calcular retornos esperados** de investimentos
* **Analisar perfil de risco** dos tomadores

Os usuários **não podem**:

* Alterar transações já completadas (apenas reversão via nova transação)
* Investir mais do que o saldo disponível em sua wallet
* Solicitar empréstimos se o KYC não estiver verificado

## Representation

As entidades são capturadas em tabelas SQL com os seguintes esquemas:

### Entities

#### Users (`users`)

A tabela `users` armazena informações fundamentais sobre todos os usuários da plataforma. Inclui:

* **`id`**: identificador único, INTEGER PRIMARY KEY com auto-increment.
* **`first_name`, `last_name`**: nomes do usuário, TEXT NOT NULL.
* **`email`**: e-mail único usado para login, TEXT NOT NULL UNIQUE.
* **`password_hash`**: hash da senha (nunca armazenamos senha em texto puro).
* **`national_id`**: documento de identificação nacional, UNIQUE.
* **`user_type`**: ENUM via CHECK ('borrower', 'investor', 'both') - permite múltiplos papéis.
* **`kyc_status`**: status de verificação ('pending', 'verified', 'rejected').

A escolha de armazenar `user_type` permite flexibilidade: muitos usuários reais participam tanto como tomadores quanto investidores em diferentes momentos.

#### Wallets (`wallets`)

Cada usuário tem **uma carteira digital** (relação 1:1):

* **`balance`**: saldo total
* **`available_balance`**: saldo disponível para uso
* **`blocked_balance`**: saldo bloqueado (em investimentos pendentes)

Esta separação é crucial em FinTech para evitar que o mesmo dinheiro seja usado em múltiplas operações simultâneas (race conditions).

#### Credit Scores (`credit_scores`)

Mantemos **histórico** de scores (não substituímos), permitindo análise de evolução:

* **`score`**: 300-850 (padrão FICO)
* **`risk_level`**: classificação derivada para queries rápidas

#### Loan Requests vs Loans

Separamos `loan_requests` (solicitações) de `loans` (empréstimos efetivados) por dois motivos:
1. **Auditoria**: mantemos histórico de TODAS as solicitações, mesmo as rejeitadas
2. **Workflow**: uma solicitação passa por estados antes de virar empréstimo

#### Investments

Um empréstimo pode ter **múltiplos investidores** (investmento fracionado). A tabela `investments` é uma junction table com atributos extras (valor investido, retorno esperado, status).

#### Installments

Cada empréstimo é dividido em **parcelas mensais** geradas no momento da criação do empréstimo. Separamos `principal_portion` de `interest_portion` para análises financeiras detalhadas.

#### Transactions

Esta é a tabela mais crítica de qualquer FinTech: registra **TODAS as movimentações financeiras**. Implementa um padrão similar ao "ledger" contábil, garantindo auditabilidade total.

### Relationships

O diagrama abaixo descreve as relações entre as entidades:

![ER Diagram](diagram.png)

* Um **usuário** pode ter 0 ou mais **endereços**, **contas bancárias**, e **transações**
* Um **usuário** tem exatamente 1 **wallet** (relação 1:1)
* Um **usuário** (borrower) pode fazer múltiplas **loan_requests**
* Cada **loan_request** aprovada vira exatamente 1 **loan**
* Um **loan** pode ter múltiplos **investments** (de diferentes investidores)
* Um **loan** tem múltiplas **installments** (parcelas)
* Um **usuário** (investor) pode fazer múltiplos **investments** em diferentes **loans**

## Optimizations

### Índices criados

* **`idx_users_email`**: usuários frequentemente buscam-se por email no login