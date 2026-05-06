# heepaykuaijiedocs

![HEEPAY QUICK PAY DOCS](assets/heepay-quickpay-hero.png)

`heepaykuaijiedocs` is a Codex skill and lightweight reference pack for Heepay Quick Pay integration.

Official product page:

- https://open.heepay.com/www/index.html#/product/detail?type=15&id=10002

## Purpose

Use this repository when working on Heepay Quick Pay integration, especially:

- Quick Pay binding/signing flow.
- Quick Pay order apply, confirm, resend SMS, direct pay, and order query planning.
- RSA2 signing, encrypted `biz_content`, response verification, and webhook handling.
- SSO-facing payment gateway design where WEB calls a neutral payment backend rather than Heepay directly.

This repo intentionally keeps the operational notes concise. It does not store full merchant secrets, private keys, JWTs, card numbers, ID-card numbers, SMS codes, or raw sensitive callbacks.

## Skill Name

Use the skill by name:

```text
$heepaykuaijiedocs
```

Recommended prompt shape:

```text
Use $heepaykuaijiedocs to check the Heepay Quick Pay method matrix, signing/encryption rules, and smoke-test checklist before changing the Morepay backend.
```

## Local Installation

Copy or symlink `skills/heepaykuaijiedocs` into your Codex skills directory, for example:

```bash
mkdir -p ~/.codex/skills
ln -s "$(pwd)/skills/heepaykuaijiedocs" ~/.codex/skills/heepaykuaijiedocs
```

## Repository Layout

- `skills/heepaykuaijiedocs/SKILL.md` - Codex skill instructions.
- `data/quickpay-methods.json` - sanitized method matrix and menu IDs.
- `scripts/fetch_quickpay_docs.sh` - helper for querying official Heepay docs through a host that can reach `open.heepay.com`.
- `assets/heepay-quickpay-hero.png` - README hero image generated with `$imagegen`.

## Document Access Notes

The official docs are served by a JavaScript application. Some servers can receive `403` from `open.heepay.com`, while test G has been able to read the docs successfully.

Known useful endpoints discovered from the official web app:

```text
GET /Fapi/Doc/ProdDoc.aspx?doType=getDocMenu&prodId=10002
GET /Fapi/Doc/ProdDoc.aspx?doType=getDocContent&menuId=<menuId>&menuType=<0|1>&prodId=10002
```

Run the helper directly on a reachable host:

```bash
scripts/fetch_quickpay_docs.sh
```

Or route the request through SSH:

```bash
HEEPAY_DOCS_SSH_HOST=test-7 scripts/fetch_quickpay_docs.sh
```

The helper writes raw fetch output under `tmp/heepay-quickpay-docs/`. Treat that output as working material: review, summarize, and sanitize before committing anything.

## Integration Rules

- WEB should not call Heepay directly. WEB calls the payment gateway, and the gateway signs/encrypts provider requests server-side.
- User-facing payment gateway routes should be SSO-first and validate the caller JWT with the auth service.
- Use public HTTPS gateway URLs for callbacks and cross-service calls unless a specific private-network contract has been approved.
- Keep REST and webhook responsibilities separate:
  - REST: create/query sessions, apply signing, apply/confirm payment.
  - Webhook: provider callback intake, signature verification, idempotent status updates, audit logging.
- Log trace IDs, provider method, provider code/message, latency, sanitized request identity, and digest values.
- Do not log raw card numbers, ID-card numbers, SMS codes, private keys, JWTs, or full callback payloads containing sensitive values.

## Current Verified Smoke Baseline

Date: 2026-05-06.

For Morepay test G, Heepay Quick Pay signing reached business-level success:

- Method: `pay.heepay.quick.sign.apply`
- Heepay response: `code=10000`, `msg=调用成功`
- Observed provider latency: about `759ms`
- Callback URL shape: `https://morepay.519197.xyz/api/pay/webhooks/heepay`

Remaining caution:

- Response signature verification must be aligned with the final Heepay response-signing rule before production acceptance.

## Header Image

The README hero was generated with `$imagegen` using an all-English fintech banner prompt. It is a documentation asset only and contains no real brand logo, card number, QR code, merchant credential, or user data.

