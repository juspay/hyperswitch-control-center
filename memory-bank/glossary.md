# Payments Glossary — Hyperswitch Control Center

> Extended payments domain glossary. Keep under 300 lines.
> Canonical reference: https://hyperswitch.io/docs

---

## Core Payment Terms

| Term | Definition |
|------|-----------|
| **connector** | A payment processor integration within Hyperswitch (e.g., Stripe connector, Adyen connector). Connectors adapt the Hyperswitch API to each PSP's specific protocol. |
| **processor / PSP** | Payment Service Provider — the underlying payment company (Stripe, Adyen, Braintree, Checkout.com, PayPal, Razorpay, etc.) |
| **acquirer** | The bank that processes card payments on behalf of the merchant. Funds flow: cardholder → issuer → card network → acquirer → merchant. |
| **issuer** | The bank that issued the customer's payment card (e.g., Chase for a Chase Visa card). |
| **BIN / IIN** | Bank Identification Number / Issuer Identification Number — the first 6–8 digits of a card number identifying the issuer and card type. |
| **payment intent** | A Hyperswitch object representing a customer's intent to pay. Tracks the full payment lifecycle from creation through completion or failure. |
| **payment attempt** | A single try to fulfill a payment intent. An intent may have multiple attempts if retries occur. |

---

## Transaction Types

| Term | Definition |
|------|-----------|
| **CIT** | Customer-Initiated Transaction — a charge triggered by a customer action in real time (e.g., clicking "Pay"). |
| **MIT** | Merchant-Initiated Transaction — a charge triggered by the merchant without the customer present (e.g., subscription renewal). |
| **mandate** | A customer-granted authorization to charge them repeatedly at future dates (subscriptions, recurring payments). |
| **EMI** | Equated Monthly Instalment — splitting a large payment amount into fixed monthly payments, often interest-free. |

---

## Authentication & Security

| Term | Definition |
|------|-----------|
| **3DS / 3D Secure** | Authentication protocol (e.g., Verified by Visa, Mastercard SecureCode) adding a second identity verification step for card payments, reducing fraud liability. |
| **PCI-DSS** | Payment Card Industry Data Security Standard — a set of security requirements for any system that stores, processes, or transmits cardholder data. |
| **tokenization** | Replacing sensitive card data (PAN) with a non-sensitive token. The token can be stored and reused; the actual card data is held by a vault. |

---

## Risk & Fraud

| Term | Definition |
|------|-----------|
| **FRM** | Fraud & Risk Management — rules, ML models, and third-party services used to detect and block fraudulent transactions before they are processed. |
| **dispute** | A merchant-initiated challenge against a chargeback, arguing the transaction was legitimate and the reversal should be overturned. |
| **chargeback** | A forced reversal of a payment initiated by the cardholder through their issuing bank, typically due to fraud or non-delivery of goods/services. |

---

## Routing & Optimization

| Term | Definition |
|------|-----------|
| **routing rule** | Logic that selects which connector/PSP to use for a given payment. Can be volume-based (send X% to Stripe, Y% to Adyen), rule-based (condition on currency/amount/country), or ML-based. |
| **surcharge** | An extra fee added on top of a payment amount, typically to cover payment processing costs. Requires explicit feature flag and regulatory compliance. |
| **smart retry** | Automatically retrying a failed payment attempt on a different connector, increasing authorization rates. Also called revenue recovery. |

---

## Operations & Finance

| Term | Definition |
|------|-----------|
| **payout** | A disbursement — sending money from a merchant's balance to a recipient (vendor, contractor, marketplace seller, user). |
| **recon** | Reconciliation — the process of matching payment records across different systems (Hyperswitch, PSP statements, accounting ledger) to detect discrepancies. |
| **audit trail** | A chronological log of all significant events and changes within the system, used for compliance and investigation. |
| **idempotency key** | A unique string sent with an API request ensuring it is not processed more than once, even if the request is retried due to network issues. |
| **webhook** | An HTTP callback that a PSP or Hyperswitch sends to the merchant's server to notify of payment events asynchronously (e.g., payment succeeded, refund processed). |

---

## Indian Payment Methods

| Term | Definition |
|------|-----------|
| **UPI** | Unified Payments Interface — India's real-time payment system enabling instant bank-to-bank transfers via mobile apps. |
| **NEFT** | National Electronic Funds Transfer — India's batch-based bank transfer system (settled in hourly batches). |
| **IMPS** | Immediate Payment Service — India's instant 24/7 interbank transfer system. |
| **RTGS** | Real-Time Gross Settlement — India's system for high-value (≥₹2 lakh) real-time bank transfers. |

---

## Module Locations in Codebase

| Domain area | Source path |
|-------------|-------------|
| Routing rules | `src/IntelligentRouting/` |
| Reconciliation | `src/Recon/`, `src/ReconEngine/` |
| Revenue Recovery / Smart Retry | `src/RevenueRecovery/` |
| FRM | Feature-flagged; search `frm` in `src/screens/` |
| Payouts | Feature-flagged; search `payout` in `src/screens/` |
| Vault / Tokenization | `src/Vault/` |
| Analytics / Hypersense | `src/Hypersense/` |
| Connector management | `src/screens/` connector screens |

---

*For canonical definitions see: https://hyperswitch.io/docs*
