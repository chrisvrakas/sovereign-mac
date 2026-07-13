# Security Policy

## Reporting a Vulnerability

If you discover a security vulnerability in sovereign-mac, please report it responsibly.

**Do not open a public GitHub issue for security vulnerabilities.**

Instead, email: [freedom@chrisvrakas.com](mailto:freedom@chrisvrakas.com)

Include:
- A description of the vulnerability
- Steps to reproduce it
- The macOS version and hardware you tested on
- Any suggested fix if you have one

I'll acknowledge your report within 48 hours and aim to release a fix within 14 days for confirmed issues.

---

## Scope

sovereign-mac is a local shell script — it runs entirely on your machine and makes no network requests except for:

- Homebrew installation (official Homebrew installer)
- Steven Black hosts file download (direct from GitHub)
- Objective-See tool downloads (opened in browser, not downloaded by the script)

Any vulnerability that allows unintended code execution, privilege escalation, or data exfiltration via sovereign-mac is in scope.

---

## Supported Versions

| Version | Supported |
|---------|-----------|
| v1.0.x (current) | ✅ |
| Pre-release | ❌ |

---

## Verifying Integrity

Always verify the SHA256 hash of `sovereign.sh` before running it:

```bash
shasum -a 256 sovereign.sh
```

Compare against the hash published in the [README](README.md#security-note).

If the hashes don't match, do not run the script.

---

*sovereign-mac by [Chris Vrakas](https://chrisvrakas.com)*
