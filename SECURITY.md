# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in cyrius-polyomino, please report it
responsibly through **GitHub Security Advisories**:

1. Go to the [Security tab](../../security/advisories) of this repository
2. Click **"Report a vulnerability"**
3. Fill in the details and submit

**Do not open a public issue for security vulnerabilities.**

## Scope

This policy covers the cyrius-polyomino game binary and the files it reads and
writes. It is a single-player game with a deliberately small attack surface:

- **No FFI, no libc, no network.** Everything runs through the Cyrius stdlib —
  the simulation core is self-rolled on bare stdlib ([ADR 0003](docs/adr/0003-self-rolled-primitives.md)).
  There is no foreign-function boundary to attack.
- **The sandbox is not ours to manage.** Per the AGNOS security model,
  **kavach owns the sandbox, not the application.** cyrius-polyomino does not
  roll its own security boundary; report sandbox-escape concerns against kavach.
- **Upstream-stack vulnerabilities** (the Cyrius stdlib, and the earmarked
  vani / sankoch / sigil deps) belong in their respective repositories. If such
  a bug affects cyrius-polyomino users specifically, flag it here and we will
  harden the call site, document the workaround, or both.

### Untrusted-input surfaces

The only places external data enters the game:

1. **Command-line arguments** — `<frames> [seed]` for the headless smoke;
   parsed with `atoi`, used as a loop bound and an RNG seed. A negative/garbage
   `frames` is a no-op; the `seed` accepts any value. (Audited 2026-05-26.)
2. **Keyboard input** — non-blocking raw-tty reads into a bounded 32-byte
   buffer, iterated against the syscall return; no over-read.
3. **High-score save file** — `~/.cyrius-polyomino/scores.cyb` (planned for M5):
   sankoch-decompressed and **sigil-integrity-verified** on load. A hash
   mismatch means a corrupted or hand-edited save — the game **refuses to load
   it and does not crash**. Tamper detection is a correctness requirement, not
   best-effort.
4. **Optional user-supplied music** — `~/.cyrius-polyomino/music/` (planned for
   M4): validated before decode; silent-by-default if absent. No path traversal
   — paths from the data dir are validated, no `../` escape.

Every `var buf[N]` is bounded (N is **bytes**); no `sys_system()` with
unsanitized input.

## Supported Versions

cyrius-polyomino is **pre-1.0** — the surface is still moving. Only the current
development line receives security fixes; there is no back-port commitment until
the v1.0 release.

| Version | Supported                                              |
|---------|--------------------------------------------------------|
| 0.x     | **Yes** — current development line, receives fixes     |
| < 0.1   | No                                                     |

Once v1.0 ships, this table moves to a standard supported-versions policy.

## Response Timeline

| Action                        | Target                     |
|-------------------------------|----------------------------|
| Acknowledgement               | Within **48 hours**        |
| Initial assessment            | Within **5 business days** |
| Fix for CRITICAL severity     | Within **14 days**         |
| Fix for HIGH severity         | Within **30 days**         |
| Fix for MEDIUM / LOW severity | Next scheduled release     |

Severity ladder: **CRITICAL** (exploitable immediately) / **HIGH** (moderate
effort) / **MEDIUM** (specific conditions) / **LOW** (defense-in-depth) — the
same rubric the internal audits use.

## Audit History

A **P(-1) hardening pass** runs before each feature minor and before the v1.0
freeze, per [`CLAUDE.md`](CLAUDE.md) and the
[first-party standards](https://github.com/MacCracken/agnosticos/blob/main/docs/development/first-party/first-party-standards.md#security-hardening-new--required-before-every-release).
Findings are filed as `docs/audit/YYYY-MM-DD-audit.md`.

| Date       | Release | Findings                          | Report |
|------------|---------|-----------------------------------|--------|
| 2026-05-26 | 0.2.0   | 2 LOW (both fixed); 0 CRIT/HIGH/MED | [audit](docs/audit/2026-05-26-audit.md) |

## Disclosure

We follow coordinated disclosure. Once a fix is released, we will publish a
security advisory crediting the reporter (unless anonymity is requested). Audit
findings that surface internally are disclosed through `docs/audit/*.md` and the
corresponding CHANGELOG entry.
