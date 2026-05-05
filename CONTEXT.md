# Hyperswitch Control Center

The dashboard for [Hyperswitch](https://github.com/juspay/hyperswitch) — an open-source payments switch. The Control Center is the operator-facing UI for managing payment flows, processor integrations, routing, analytics, and reconciliation.

## Language

### Core domain

**Merchant**:
The business entity using Hyperswitch to accept payments. Owns one or more **Profiles** and configures **Connectors**.
_Avoid_: Customer, account, tenant, organization (all overloaded — pick "Merchant" when referring to the Hyperswitch tenant).

**Profile**:
A logical grouping under a **Merchant** representing a business unit, brand, or product line. Connectors and routing rules are scoped to a Profile.
_Avoid_: Sub-merchant, business profile.

**Connector**:
An adapter to an external payment processor (Stripe, Adyen, Braintree, etc.). The unit of integration.
_Avoid_: Processor, gateway, PSP, provider — use "Connector" when referring to the configured adapter inside Hyperswitch; "processor" only when speaking generically about the external system.

**Payment**:
A single payment attempt initiated by a **Merchant** on behalf of an end-customer. May proceed through several statuses (requires_payment_method, processing, succeeded, failed, etc.) and may produce a **Refund** or a **Dispute**.
_Avoid_: Transaction, charge, order — these collide with processor-specific terminology.

**Refund**:
A reversal of all or part of a captured **Payment**.
_Avoid_: Reversal (reserved for auth-only reversals), credit.

**Dispute**:
A chargeback or pre-arbitration raised by the cardholder against a **Payment**. Has its own lifecycle (challenged, won, lost).
_Avoid_: Chargeback (use "Dispute" — covers chargebacks plus pre-arbitration and inquiries).

**Payout**:
A disbursement of funds from the **Merchant** to a third party (refund-to-card, vendor payout, marketplace split).
_Avoid_: Withdrawal, transfer.

### Routing & decisioning

**Routing Rule**:
A configured policy that decides which **Connector** handles a given **Payment**. Two flavours: **Volume-based** (split by percentages) and **Rule-based** (conditional on payment fields).
_Avoid_: Decision tree, route.

**Surcharge**:
An additional amount added to a **Payment** based on payment-method or other conditions.

**FRM**:
Fraud and Risk Management — pre-authorisation screening of a **Payment** through providers like Riskified or Signifyd.
_Avoid_: Fraud check, risk check.

### Operations

**Recon**:
Reconciliation — matching processor-reported settlements against the **Merchant**'s ledger and Hyperswitch's record of **Payments**.
_Avoid_: Reconciliation (the long form is fine in prose; in code/UI use "Recon").

**Audit Trail**:
The append-only history of state changes on a **Payment**, **Refund**, or **Dispute**.

**Test mode / Live mode**:
The environment a session is operating in. Test-mode traffic uses sandbox **Connectors** and never moves real funds.

### Platform / UI shell

**Dashboard**:
The Control Center UI as a whole.
_Avoid_: App, console, portal.

**Screen**:
A top-level route in the **Dashboard** (e.g. Payments screen, Connectors screen). Lives under `src/screens/`.
_Avoid_: Page, view (page implies static content; view is overloaded).

**Embeddable**:
A version of a Hyperswitch UI surface designed to be embedded inside a host application (e.g. inside a partner's own dashboard).

**Vault**:
The PCI-scoped surface that handles sensitive payment-method data (card numbers, etc.). Distinct from the rest of the **Dashboard** because of compliance requirements.

## Relationships

- A **Merchant** owns one or more **Profiles**
- A **Profile** owns one or more **Connectors** and zero or more **Routing Rules**
- A **Routing Rule** chooses which **Connector** processes a **Payment**
- A **Payment** belongs to a **Profile** and is processed by exactly one **Connector** at a time (retries can change this)
- A **Payment** may produce zero or more **Refunds** and zero or more **Disputes**
- An **FRM** decision precedes the **Connector** call for a **Payment**
- **Recon** reconciles **Connector**-reported settlements with **Payment** records

## Example dialogue

> **Dev:** "When the user lands on the Payments screen, how do we know which **Profile** they're scoped to?"
> **Domain expert:** "The session carries the active **Profile** id. The Payments **Screen** filters by that **Profile** before calling the list endpoint — a **Merchant** with three **Profiles** sees three separate Payments screens, not a merged one."

> **Dev:** "If a **Routing Rule** sends a **Payment** to a Connector that's down, do we automatically retry on a different **Connector**?"
> **Domain expert:** "Only if the rule has a fallback chain configured. Otherwise the **Payment** fails and surfaces in the Audit Trail."

## Flagged ambiguities

- **"Customer"** is heavily overloaded. In this codebase: the **Merchant** is the Hyperswitch tenant; their customers (end-shoppers) are usually called "the customer" in prose but should not be a top-level domain term in CONTEXT.md unless we're modelling them explicitly.
- **"Connector" vs "Processor"**: a Connector is the configured adapter inside Hyperswitch; a processor is the external system. Stripe is a processor; the Stripe Connector is what Hyperswitch holds.
- **"Profile" vs "Merchant"**: Routing, Connectors, and most operational data are Profile-scoped, not Merchant-scoped. New code should default to the Profile boundary.
