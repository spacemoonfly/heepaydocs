---
name: heepaykuaijiedocs
description: Use when working on Heepay Quick Pay integration docs, method lookup, Morepay gateway planning, SSO/payment lab flows, RSA2 signing/encryption, webhook handling, and sanitized smoke-test reporting.
---

# Heepay Quick Pay Docs Skill

This skill helps Codex work with Heepay Quick Pay (`prodId=10002`) without leaking payment secrets or copying excessive official documentation.

Official product page:

- `https://open.heepay.com/www/index.html#/product/detail?type=15&id=10002`

## When To Use

Use this skill when the task mentions:

- Heepay Quick Pay / 快捷支付.
- Morepay or `519197-pay` payment gateway work.
- Quick signing, bank-card binding, quick payment confirm, SMS resend, direct pay, order query.
- RSA2 signing, encrypted `biz_content`, response verification, or provider webhooks.
- Payment SSO gateway design and lab smoke testing.

## Core Principles

- Treat Heepay as a provider behind a neutral payment gateway, not as a direct WEB dependency.
- Keep user-facing gateway APIs SSO-first. Validate JWTs through the auth service before creating or querying user payment sessions.
- Perform provider signing/encryption only on the backend.
- Keep public HTTPS callback URLs stable and provider-facing.
- Log enough to debug payment state, but never log raw sensitive payment data.

## Important Security Rules

Never commit or print:

- Full merchant credentials.
- Private keys.
- Signing keys or 3DES keys.
- JWTs.
- Bank-card numbers.
- ID-card numbers.
- SMS codes.
- Raw callback bodies containing sensitive values.

When documenting runtime evidence, use:

- Method name.
- HTTP status.
- Provider `code/msg/sub_code/sub_msg`.
- Latency.
- Request ID / trace ID.
- Secret suffixes only when absolutely needed.

## Official Docs Access

The official website is a JavaScript app. Direct HTML may only show a JavaScript placeholder or a `403` depending on source IP.

Known useful official API endpoints:

```text
GET https://open.heepay.com/Fapi/Doc/ProdDoc.aspx?doType=getDocMenu&prodId=10002
GET https://open.heepay.com/Fapi/Doc/ProdDoc.aspx?doType=getDocContent&menuId=<menuId>&menuType=<0|1>&prodId=10002
```

If the local host is blocked, run the repo helper through a reachable host:

```bash
HEEPAY_DOCS_SSH_HOST=test-7 scripts/fetch_quickpay_docs.sh
```

Do not paste full official documents into responses. Summarize relevant fields and cite the official URL or discovered endpoint.

## Quick Pay Method Matrix

Use `data/quickpay-methods.json` as the sanitized starting matrix. Current known menu/API methods:

- `pay.heepay.quick.sign.apply` - quick signing apply.
- `pay.heepay.quick.sign.query` - signing result query.
- `pay.heepay.quick.sign.close` - signing close/unbind.
- `pay.heepay.quick.apply` - payment order apply.
- `pay.heepay.quick.confirm` - payment confirm.
- `pay.heepay.quick.sms.resend` - payment SMS resend.
- `pay.heepay.quick.submit` - direct pay.

## Morepay Gateway Pattern

Recommended route pattern:

- `POST /api/pay/lab/sessions`
- `GET /api/pay/lab/sessions/{id}`
- `POST /api/pay/lab/quick/sign/apply`
- `GET /api/pay/lab/quick/sign/query`
- `POST /api/pay/lab/quick/pay/apply`
- `GET /api/pay/lab/orders/query`
- `POST /api/pay/webhooks/heepay`
- `GET /api/pay/logs/recent` for authenticated lab diagnostics only.

Production hardening checklist:

- Idempotency by merchant order number and callback event.
- Response signature verification aligned with provider docs.
- Callback signature verification before state mutation.
- Strict status transition table.
- Provider request/response digest logging.
- No raw sensitive fields in logs.
- Separate operator/admin log access from user-facing APIs.

## Current Smoke Baseline

On 2026-05-06, Morepay test G reached Heepay business success for:

```text
pay.heepay.quick.sign.apply -> code=10000, msg=调用成功
```

Known caveat:

- Local response verification still needs final Heepay response-signing-string alignment.

