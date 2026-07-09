---
name: privesc-windows
description: Methodology for authorised Windows privilege escalation during a pentest — after a low-privilege foothold on an in-scope Windows host. Use to enumerate escalation vectors (services, tokens, registry, credentials, AD misconfigs) and choose the safest path. Enumerate first; get operator approval before running exploits.
---

# Windows Privilege Escalation (authorised)

> **Preconditions.** Legitimate foothold on an **in-scope** Windows host during an
> authorised test. Enumerate read-only first; STOP for operator approval before any
> exploit or persistence. Record steps/output to `evidence/`. Watch for EDR — do not
> attempt evasion; if something is blocked, note it and move on.

## 0. Orient
- `whoami /all` (user, groups, **privileges**), `systeminfo`, `hostname`,
  `ipconfig /all`, current integrity level, domain vs local.
- OS build/patch level → later cross-ref for known LPE.

## 1. Automated enumeration
- `winPEAS` (PEASS-ng), `PowerUp.ps1` (`Invoke-AllChecks`), `Seatbelt`, `SharpUp`.
- `accesschk.exe` for ACL checks. Save outputs to `evidence/`. Verify leads manually.

## 2. Token / privilege abuse (check `whoami /priv`)
- **SeImpersonatePrivilege / SeAssignPrimaryToken** → Potato family (JuicyPotato,
  PrintSpoofer, GodPotato) → SYSTEM. Very common on service accounts / IIS / MSSQL.
- **SeBackup/SeRestore**, **SeTakeOwnership**, **SeDebug**, **SeLoadDriver** — each has a known technique.

## 3. Service & path misconfigs
- **Unquoted service paths** with writable intermediate dirs.
- **Weak service permissions** (`accesschk -uwcqv <user> *`) → reconfig binPath.
- **Writable service binary / DLL** → DLL hijacking / binary replace.
- **AlwaysInstallElevated** (both HKLM+HKCU set) → malicious MSI as SYSTEM.
- **Autoruns / scheduled tasks** pointing at writable files.

## 4. Credentials & secrets
- `cmdkey /list`, Credential Manager, `runas /savecred`.
- Registry: autologon (`winlogon`), VNC/PuTTY, SNMP, `HKLM\SAM`/`SYSTEM` if readable.
- Files: unattend.xml, sysprep, `web.config`, `*.kdbx`, PowerShell history, GPP `cpassword`.
- **LSASS** (approval needed; noisy/EDR): mimikatz/comsvcs dump for hashes/tickets.

## 5. Active Directory context (if domain-joined)
- BloodHound (`SharpHound` collector) → map paths to Domain Admin.
- Kerberoasting (`GetUserSPNs`), AS-REP roasting, ACL abuse, delegation
  (unconstrained/constrained/RBCD), `MS-` printnightmare/petitpotam — **all need approval**
  and can be high-impact; coordinate with the operator.

## 6. Kernel / known LPE
- Map build number to known exploits (e.g. via wesng / Watson output). High crash risk —
  operator approval required, avoid on production DCs.

## 7. Confirm safely & record
- Prove with `whoami` showing SYSTEM/Domain Admin or reading a protected resource — not
  persistence. No new accounts / backdoors without explicit approval. Log to `/pentest-note`.

## References
PEASS-ng (winPEAS), PowerSploit/PowerUp, GTFOBins→LOLBAS, HackTricks Windows privesc,
BloodHound. Verify build/version before any CVE attempt.
