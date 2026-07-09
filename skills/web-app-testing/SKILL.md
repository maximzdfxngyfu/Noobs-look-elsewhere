---
name: web-app-testing
description: Methodology for authorised web application penetration testing based on the OWASP Web Security Testing Guide (WSTG) and OWASP Top 10. Use when testing a web app or API in scope — planning which test categories to cover, what to check per category, and how to confirm findings safely. Read-only/low-impact first; stop before destructive actions.
---

# Web Application Testing (OWASP WSTG)

> **Authorisation first.** Only test hosts/URLs in `scope.txt`, inside the
> engagement window (`RULES-OF-ENGAGEMENT.md`). The scope-guard hook enforces
> scope on offensive tools. Prefer read-only checks; STOP and ask the operator
> before anything that could modify data, lock accounts, or degrade the service
> (mass fuzzing on prod, destructive payloads, credential brute-force).

Work the WSTG categories systematically. For each, note what you checked, the
result, and evidence path. Don't skip categories just because one looks fruitful.

## WSTG-INFO — Information gathering
- Fingerprint server/framework/versions (`whatweb`, headers, cookies, favicon hash).
- `robots.txt`, `sitemap.xml`, comments, JS source maps, error pages, `/.git`, `.env`.
- Enumerate endpoints, parameters, forms, uploads, APIs (Swagger/OpenAPI, GraphQL introspection).
- Map auth surface: login, register, reset, MFA, SSO, session cookies.

## WSTG-CONF — Configuration & deployment
- TLS config, security headers (CSP, HSTS, X-Frame-Options, cookies `Secure/HttpOnly/SameSite`).
- Exposed admin panels, default files, backup files (`.bak`, `~`, `.old`), directory listing.
- HTTP methods (OPTIONS/PUT/DELETE/TRACE), CORS misconfig (`Access-Control-Allow-Origin: *` + credentials).

## WSTG-IDNT / ATHN — Identity & authentication
- Username enumeration (login/reset/register differential responses & timing).
- Weak password policy, credential stuffing exposure, lockout behaviour (DON'T lock real accounts).
- Auth bypass, "remember me", password reset token predictability/leakage, MFA bypass.
- Default/weak creds — only with approval and low attempt counts.

## WSTG-ATHZ — Authorization
- **IDOR / BOLA**: change object IDs across users — the #1 API bug. Test with two accounts.
- Vertical priv-esc (user→admin), horizontal (user A→user B data).
- Forced browsing to privileged endpoints; missing function-level access control.

## WSTG-SESS — Session management
- Session fixation, token entropy, cookie flags, logout invalidation, concurrent sessions.
- CSRF on state-changing actions (token presence, SameSite).

## WSTG-INPV — Input validation (highest-yield)
- **SQLi**: manual probes first (`'`, `1=1`, boolean/time-based); confirm with `sqlmap`
  on in-scope params only, low `--risk/--level`, NO `--dump` without approval.
- **XSS**: reflected/stored/DOM; use a benign proof marker, not a real payload chain.
- **Command/SSTI/LDAP/XPath/NoSQL injection**, header injection, host-header attacks.
- **SSRF**: parameters that fetch URLs; test against a controlled in-scope collaborator.
- **File upload**: type/extension/content bypass, path traversal, RCE via upload.
- **Path traversal / LFI/RFI**, open redirect, mass assignment.

## WSTG-ERRH / CRYP — Errors & crypto
- Verbose errors/stack traces leaking internals; sensitive data in responses.
- Weak crypto, secrets in JS/responses, JWT flaws (alg=none, weak secret, `kid` injection).

## WSTG-BUSL — Business logic
- Workflow bypass, price/quantity tampering, race conditions, replay, insufficient
  process validation. These need human reasoning — describe the abuse case.

## WSTG-CLNT — Client-side
- DOM XSS, JS sinks, postMessage, clickjacking, CORS, WebSockets, sensitive data in localStorage.

## API-specific (OWASP API Top 10)
- BOLA/IDOR, broken auth, excessive data exposure, mass assignment, missing rate limits,
  BFLA (function-level), unsafe consumption of 3rd-party APIs. Test GraphQL introspection & batching.

## Tools on Kali (use within scope, throttle on prod)
`whatweb`, `nikto`, `ffuf`/`gobuster` (content/param discovery, `seclists`), `sqlmap`,
`wpscan`, `nuclei` (known-CVE templates), Burp Suite (proxy/repeater/intruder — manual).

## Confirming & recording findings
- Reduce each finding to the **minimal safe proof** (a marker, a diff, one row —
  never full data exfiltration).
- Capture request/response + steps to `evidence/`; write the finding with
  `/pentest-note` and score it later with the `pentest-reporting` skill.
- Distinguish **confirmed** from **suspected**; note false-positive checks done.
