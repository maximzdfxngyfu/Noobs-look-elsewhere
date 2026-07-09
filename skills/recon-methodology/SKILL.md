---
name: recon-methodology
description: Structured methodology for authorised reconnaissance and enumeration during a penetration test on Kali Linux. Use when scoping a target, planning nmap/enumeration phases, or deciding what to scan next. Covers host discovery, port/service enum, web enum, and note-taking. Enforces scope discipline.
---

# Reconnaissance & Enumeration Methodology (authorised pentest, Kali Linux)

> **Before anything:** confirm the target is in `scope.txt` and inside the
> engagement window (see `RULES-OF-ENGAGEMENT.md`). The scope-guard hook will
> block out-of-scope offensive commands — treat a block as a signal to stop and
> re-check authorisation, not to work around it. Never propose techniques to
> evade detection or expand scope without explicit operator approval.

## Operating principles
- **Enumerate before you exploit.** Most of the engagement is careful enumeration.
- **One target at a time, note as you go.** Write findings to `findings/` and raw
  tool output to `evidence/` immediately — don't rely on scrollback.
- **Least impact first.** Prefer read-only, low-noise techniques; throttle on
  fragile/production hosts; avoid account lockouts (cap auth attempts).
- **Explain each command** you propose: what it does, why now, expected impact.

## Phase 1 — Host discovery
- Confirm reachability and live hosts within the authorised range only.
  - `nmap -sn <cidr>` (ping sweep) — for a range you're authorised to sweep.
  - Single host: skip discovery, go to port scan (`-Pn` if ICMP filtered).

## Phase 2 — Port & service enumeration
- Fast full-port TCP, then targeted service/version + default scripts:
  - `nmap -p- --min-rate 1000 -oA evidence/nmap-allports <host>`
  - `nmap -sC -sV -p <open,ports> -oA evidence/nmap-services <host>`  (-sC = default NSE scripts)
- UDP top ports only if needed (slow/noisy): `nmap -sU --top-ports 50 <host>`.
- Map each open port to a service and pick the next enum step from Phase 3/4.

## Phase 3 — Service-specific enumeration (common services)
- **HTTP/HTTPS (80/443/8080/8443):** go to Phase 4.
- **SMB (139/445):** `enum4linux-ng <host>`, `smbmap -H <host>`, `smbclient -L //<host>/ -N`.
- **FTP (21):** banner, check anonymous login.
- **SSH (22):** version/banner only; do NOT brute-force without approval.
- **DNS (53):** `dnsrecon -d <domain>`; attempt AXFR only if authorised.
- **SNMP (161/udp):** `onesixtyone`, `snmpwalk -v2c -c public <host>` (community strings).
- **SMTP (25):** banner, VRFY/EXPN user enum if in scope.
- **Databases (3306/5432/1433/27017):** version + auth check; no data changes.

## Phase 4 — Web application enumeration
- Fingerprint: `whatweb <url>`, check headers, robots.txt, sitemap, `/.git`, favicon.
- Content/dir discovery (throttle on prod): `ffuf -u <url>/FUZZ -w <wordlist> -mc 200,204,301,302,307,401,403`
  or `gobuster dir -u <url> -w <wordlist>`.
- Vhost/subdomain discovery if a domain is in scope: `ffuf` Host-header fuzzing / `amass enum -passive`.
- Tech-specific: `nikto -h <url>` (noisy), `wpscan --url <url>` for WordPress,
  `nuclei -u <url>` for known-CVE templates (mind noise/impact).
- Note every parameter, form, upload, auth endpoint, and API route for later testing.

## Phase 5 — Triage & next steps
- For each service/finding, record: what, where, evidence path, suspected severity.
- Identify the most promising leads (default creds, known CVEs, exposed panels,
  injectable params) and STOP to confirm with the operator before any exploitation
  that could be destructive or lock accounts.
- Feed confirmed issues into the reporting workflow (see the `pentest-reporting`
  skill and `/pentest-report`).

## Wordlists on Kali (paths)
- `/usr/share/wordlists/dirb/common.txt`, `/usr/share/wordlists/dirbuster/…`
- `/usr/share/seclists/` (install `seclists` if missing): Discovery/Web-Content,
  Usernames, Passwords, DNS/subdomains.

## Note-taking layout (per engagement)
```
findings/     # one markdown file per finding
evidence/     # raw tool output, screenshots
engagement.log# auto audit log of offensive commands (from scope-guard hook)
scope.txt     # authorised targets
RULES-OF-ENGAGEMENT.md
```
