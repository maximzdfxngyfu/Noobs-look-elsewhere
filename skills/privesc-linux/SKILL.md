---
name: privesc-linux
description: Methodology for authorised Linux privilege escalation during a pentest — after obtaining a low-privilege foothold on an in-scope host. Use to enumerate escalation vectors (sudo, SUID, cron, capabilities, kernel, misconfigs) and pick the safest path to higher privileges. Enumerate first; get operator approval before running any real exploit.
---

# Linux Privilege Escalation (authorised)

> **Preconditions.** You have a legitimate foothold on an **in-scope** host during
> an authorised test. Escalation on a production box can break it — enumerate
> read-only first, then STOP and get operator approval before running any exploit
> (kernel exploits especially can panic the host). Record every step to `evidence/`.

## 0. Stabilise & orient
- Upgrade to a proper TTY if needed (`python3 -c 'import pty;pty.spawn("/bin/bash")'`).
- `id`, `hostname`, `uname -a`, `cat /etc/os-release`, current shell/user, groups.

## 1. Automated enumeration (fast baseline)
- `linpeas.sh` (from PEASS-ng) — run and read its highlighted findings.
- `linenum.sh`, `pspy` (watch cron/processes without root). Save output to `evidence/`.
- Treat automated output as leads to **verify manually**, not conclusions.

## 2. Manual vectors (highest-yield first)
- **sudo**: `sudo -l`. Misconfigured binaries → check GTFOBins. `NOPASSWD` entries,
  `sudo` version CVEs (e.g. Baron Samedit / CVE-2021-3156 — verify version first).
- **SUID/SGID**: `find / -perm -4000 -type f 2>/dev/null`. Cross-ref GTFOBins.
- **Capabilities**: `getcap -r / 2>/dev/null` (e.g. `cap_setuid` on python/perl).
- **Cron jobs**: `/etc/crontab`, `/etc/cron.*`, writable scripts run by root; `pspy` to catch them.
- **Writable files**: world-writable scripts in root paths, `/etc/passwd` writable,
  writable `PATH` dirs, writable service unit files.
- **Services & sockets**: local-only services running as root, Docker socket
  (`/var/run/docker.sock` → trivial root), LXC/LXD group, exposed DBs with creds.
- **Credentials lying around**: history files, config files, `.env`, SSH keys,
  `/var/backups`, DB creds, cloud metadata/creds, password reuse.
- **NFS**: `no_root_squash` exports → SUID from a controlled host.
- **Kernel**: `uname -r` → search known LPE (get approval; high crash risk).

## 3. Group / environment shortcuts
- Groups: `docker`, `lxd`, `disk`, `adm`, `sudo`, `wheel`, `shadow` — each has a known path.
- Env: `PATH` hijacking on relative-path calls in root cron/SUID wrappers; `LD_PRELOAD`
  / `LD_LIBRARY_PATH` via `sudo` `env_keep`.

## 4. Confirm safely & record
- Prefer a benign proof (`id` as root, read a root-only file) over persistence.
- Do NOT add users, plant backdoors, or persist without explicit operator approval.
- Note the exact vector, command, and evidence path; feed into `/pentest-note`.

## References
GTFOBins, PEASS-ng (linpeas), HackTricks Linux privesc. Always verify a CVE against
the *actual* observed version before attempting it.
