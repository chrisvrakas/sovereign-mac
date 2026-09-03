# SOVEREIGN-MAC

> **A macOS Privacy & Security Toolkit**
> *Don't trust Apple. Verify. YOUR machine. YOUR rules.*

<div align="center"><img src="assets/images/sovereign-banner.png" alt="sovereign-mac" width="100%"></div>

<div align="center"><img src="assets/images/sovereign-hero.png" alt="sovereign-mac main menu" width="100%"></div>

---

sovereign-mac is a menu-driven shell script that automates macOS privacy hardening, system cleanup, and security scanning. No technical expertise required. Every option tells you exactly what it does before it does it — nothing runs silently.

Built for people who want a private, hardened Mac but don't want to spend hours googling terminal commands.

> Want to see every exact terminal command the script runs, organized by module? → **[COMMANDS.md](COMMANDS.md)**

## Quick Links

- [Quick Start](#quick-start)
- [Features](#features)
- [Philosophy](#philosophy)
- [Changelog](#-changelog)
- [Recommended Tools](#-recommended-tools)
- [Command Reference](COMMANDS.md) ← full list of every terminal command
- [Credits](#-credits--inspiration)
- [License](#-license)

---

## Why This Exists

Apple's macOS sends a surprising amount of data about your usage to Apple's servers — crash reports, analytics, app activity, Siri queries, location data, keyboard input corrections, ad targeting profiles, and more. Most of it is on by default.

Turning it all off manually requires running dozens of individual terminal commands scattered across forum posts, blog articles, and security guides. sovereign-mac does all of it in one place, with plain-English explanations at every step.

---

## Quick Start

> **Don't know what Terminal is?** It's a built-in macOS app. Press `Command + Space`, type `Terminal`, and press Enter.

**Step 1** — Download `sovereign.sh` from this repo (click the file, then the download button)

**Step 2** — Open Terminal and navigate to where you downloaded it. If you saved it to your Downloads folder:
```bash
cd ~/Downloads
```

**Step 3** — Make the script executable (this is a one-time step that tells macOS "this file is allowed to run"):
```bash
chmod +x sovereign.sh
```

**Step 4** — Run it:
```bash
./sovereign.sh
```

That's it. You'll see a menu. Type a number and press Enter to select an option.

> **Tip:** The script will ask for your Mac password when it needs to make system-level changes. This is normal — it's the same password you use to install apps. Nothing is sent anywhere.

---

## Requirements

- macOS 12 Monterey or newer (fully tested on Sequoia)
- That's it for most features

**Optional (unlocks additional features):**
- [Homebrew](https://brew.sh) — macOS package manager, used by New Machine Setup and File Search
- [ripgrep](https://github.com/BurntSushi/ripgrep) — `brew install ripgrep` — unlocks content search in File Search
- [exiftool](https://exiftool.org) — `brew install exiftool` — unlocks EXIF metadata stripping in File Search
- [Objective-See tools](https://objective-see.org) — free security apps used by the Security Scans module

---

## Features

### 1 · New Machine Setup
One-time hardening tasks for a fresh macOS installation. Run these in order on a new machine, or after a factory reset.

<div align="center"><img src="assets/images/screenshot-newmachine.jpg" alt="New Machine Setup submenu" width="100%"></div>

| Step | What it does |
|------|-------------|
| Install Homebrew | Installs the most popular macOS package manager with security settings locked down |
| Harden Homebrew | Disables insecure redirects, requires checksum verification on all installs |
| Set Hostname | Randomizes your computer's network name so it doesn't broadcast your real name |
| Block Trackers | Downloads Steven Black's unified hosts file — blocks ~150,000 known tracker and ad domains at the OS level |
| Generate SSH Key | Creates a modern Ed25519 SSH key pair for secure server access |
| Harden Git | Configures Git with security best practices |
| Show Hidden Files | Reveals hidden system files in Finder |
| Secure umask | Sets file permissions so new files are owner-only by default (requires restart) |

> *"Leverage technology before it leverages you."*

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` | Installs Homebrew |
| `echo "export HOMEBREW_NO_INSECURE_REDIRECT=1" >> ~/.zprofile` | Prevents following insecure HTTP redirects |
| `echo "export HOMEBREW_CASK_OPTS=--require-sha" >> ~/.zprofile` | Requires SHA verification on all cask installs |
| `sudo scutil --set ComputerName / HostName / LocalHostName "<name>"` | Sets computer name across all three system namespaces |
| `curl -fsSL https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts` | Downloads ~150k domain blocklist |
| `ssh-keygen -t ed25519 -C "<label>" -f ~/.ssh/id_ed25519` | Generates Ed25519 SSH key pair |
| `git config --global credential.helper ""` | Disables plaintext Git credential storage |
| `defaults write com.apple.finder AppleShowAllFiles TRUE` | Shows hidden files in Finder |
| `sudo launchctl config user umask 077` | Sets owner-only permissions on all new files |

See [COMMANDS.md](COMMANDS.md) for the full command list with all arguments.

</details>

---

### 2 · Weekly Maintenance
Runs Homebrew updates, all Privacy Settings, and full Logs & Cache Cleanup back-to-back with a single selection. Designed to be run weekly. Shows you exactly what it will do before starting.

---

### 3 · Homebrew Maintenance
Keeps your Homebrew installation clean and secure.

- Updates all installed packages
- Lists everything currently installed
- **Uninstall a Package** — interactive picker showing every formula and cask with its size. Toggle multiple packages by number, review the full list before confirming. Casks are removed with `--zap` (all associated app data, not just the app).
- Removes orphaned dependencies
- Clears download cache

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `brew analytics off` | Disables Homebrew telemetry |
| `brew update` | Fetches latest package index |
| `brew upgrade --greedy` | Upgrades all packages including GUI apps |
| `brew cleanup -s` | Removes old versions and clears download cache |
| `brew autoremove` | Removes unused dependencies |
| `brew doctor` | Diagnoses installation issues |
| `brew uninstall --cask --zap --force <app>` | Removes a cask and all associated files |
| `brew uninstall --formula --force <package>` | Removes a formula |

</details>

---

### 4 · Logs & Cache Cleanup
Wipes forensic traces and frees disk space. Typically recovers 1–10GB+.

**What gets deleted:**
- Terminal history (bash and zsh)
- Download quarantine history
- Trash on all mounted volumes
- System logs, audit logs, ASL logs, diagnostic logs
- Daily, weekly, and monthly maintenance logs
- System and user caches — **with privacy-app protection.** Password managers, VPN clients, Signal, and the Objective-See security tools this project recommends are matched against a reverse-DNS bundle-ID list and explicitly skipped, reported by name as each run completes. Real-time output shows exactly what was cleared and how much space it freed, with a closing summary.
- Quick Look thumbnail cache
- Print spooler cache
- Xcode derived data and archives
- **Safari forensic wipe** — History database (all journal files), Downloads list, Top Sites, Last Session, cookies, recent searches, webpage previews, cached icons
- Mail app connection logs
- iOS device backup records and connected device fingerprints
- App install receipts and history
- DNS cache flush
- RAM cache purge

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `sqlite3 ~/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2 'delete from LSQuarantineEvent'` | Clears download quarantine history |
| `rm -f ~/.bash_history && rm -f ~/.zsh_history` | Deletes terminal history |
| `sudo rm -rf /Volumes/*/.Trashes/*` | Empties Trash on all volumes |
| `sudo rm -rf /Library/Logs/* /var/audit/* /private/var/log/asl/*` | Deletes system, audit, and ASL logs |
| `_clear_cache_dir /Library/Caches` / `~/Library/Caches` | Clears system and user caches, skipping anything matched by `PROTECTED_CACHE_IDS` |
| `qlmanage -r cache` | Clears Quick Look thumbnail cache |
| `sudo rm -rf /var/spool/cups/c0*` | Clears print spooler |
| `rm -f ~/Library/Safari/History.db ~/Library/Cookies/Cookies.binarycookies` | Safari forensic wipe (16 files total) |
| `sudo rm -rf /var/db/lockdown/*` | Deletes connected device fingerprints |
| `sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder` | Flushes DNS cache |
| `sudo purge` | Purges RAM cache |

See [COMMANDS.md](COMMANDS.md) for the complete list of all cleanup commands.

</details>

---

### 5 · Privacy Settings
The core of the toolkit. Twelve granular categories of `defaults write` commands — all safe, all reversible, none require deletions. Run all at once or pick individual categories.

<div align="center"><img src="assets/images/screenshot-privacy.jpg" alt="Privacy Settings submenu" width="100%"></div>

| Category | What it does |
|----------|-------------|
| **Telemetry & Analytics** | Stops Apple collecting usage data, crash reports, per-app analytics (WiFi, Wallet, Maps, News, Photos), keyboard learning, internet spell correction, ad tracking |
| **Safari Privacy** | Disables search suggestions, autofill (addresses, passwords, credit cards, forms), auto-opening of downloaded files |
| **Firewall & Stealth Mode** | Enables macOS firewall with logging, stealth mode (your Mac won't respond to network probes), disables auto-allow for signed apps |
| **Screen Lock** | Requires password the instant your screen sleeps, disables FDE auto-login, sets 30-minute auto-logout, enables secure keyboard entry in Terminal |
| **.DS_Store Files** | Stops macOS leaving hidden metadata files on USB drives and network servers |
| **Notification Center** | Hides notification content on lock screen, disables notification suggestions |
| **Handoff & AirPlay** | Stops your Mac talking to nearby Apple devices, kills Captive Portal (a known WiFi attack vector), disables Remote Apple Events, disables network wake |
| **Spotlight** | Stops Spotlight sending your searches to Apple, disables Siri suggestions and web results |
| **Game Center & Sounds** | Disables Game Center entirely, kills startup sound and UI sounds, removes recent apps from Dock, shows all file extensions (prevents `.jpg.app` disguises) |
| **NTP Time Server** | Switches time sync from Apple's server to the independent pool.ntp.org |
| **iCloud Hardening** | Changes document save default from iCloud to local disk, disables Desktop/Documents folder sync, disables Find My tracking |
| **Sleep Security** | Destroys your FileVault encryption key when the Mac enters standby — prevents cold boot RAM extraction attacks. Enables immediate standby regardless of battery level. |

**Reset App Permissions** — a separate submenu with 10 individual options and one "Extended" batch covering 22 total TCC service categories. Forces every app to ask for permission again for Camera, Microphone, Screen Recording, Full Disk Access, Contacts, Calendar, Accessibility, Location, Photos, Speech Recognition, and more.

<details>
<summary><strong>Show terminal commands</strong></summary>

Privacy settings use `defaults write` — the standard macOS preference system. Every change is reversible. See [COMMANDS.md](COMMANDS.md) for the complete list of all ~60 commands across all 12 categories. A few representative examples:

| Command | What it does |
|---------|-------------|
| `defaults write com.apple.AdLib forceLimitAdTracking -bool true` | Forces ad tracking limit |
| `sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on` | Enables stealth mode — Mac ignores unsolicited network probes |
| `sudo pmset -a destroyfvkeyonstandby 1` | Destroys FileVault key on standby — prevents cold boot attacks |
| `sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false` | Disables Captive Portal (WiFi attack vector) |
| `defaults write com.apple.screensaver askForPasswordDelay -int 0` | Password required immediately on sleep |
| `tccutil reset Camera` | Forces all apps to re-request Camera access |
| `defaults write NSGlobalDomain AppleShowAllExtensions -bool true` | Shows all file extensions — prevents `.jpg.app` masquerades |

</details>

---

### 6 · Spoof MAC Address
For Wi-Fi, opens macOS's built-in **Private Wi-Fi Address** setting (System Settings → Wi-Fi → network Details) — this is Apple's own supported, reliable way to randomize your MAC per network. Manual Wi-Fi spoofing via Terminal relied on a disassociation tool (`airport`) that Apple has since removed from macOS, so it's no longer offered here as a Wi-Fi option. For wired/Ethernet or other custom interfaces, manual MAC randomization via `ifconfig` still works reliably and remains available.

<div align="center"><img src="assets/images/screenshot-spoofmacaddress.jpg" alt="Spoof MAC Address submenu" width="100%"></div

- Randomize Wi-Fi MAC address
- Randomize a specific network interface
- Restore your original hardware MAC address
- Show all current MAC addresses

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `networksetup -setairportpower <iface> off` | Disables Wi-Fi (required before MAC change) |
| `sudo ifconfig <iface> ether <mac>` | Sets new MAC address |
| `networksetup -setairportpower <iface> on` | Re-enables Wi-Fi |
| `networksetup -listallhardwareports` | Lists all interfaces and current MACs |

</details>

---

### 7 · System Status
Read-only security audit. Nothing changes — it just checks and reports.

- Spotlight indexing status
- FileVault encryption status
- System Integrity Protection (SIP) status
- Gatekeeper status
- Available OS updates
- LaunchAgents (opens in Finder for easy review and deletion)
- **Cache Protection Coverage Check** — lists any cache entries under `/Library/Caches` or `~/Library/Caches` not matched by `PROTECTED_CACHE_IDS`, so you can spot a new privacy-sensitive app before running Logs & Cache Cleanup, not after

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `mdutil -s /` | Reports Spotlight indexing status |
| `fdesetup status` | Reports FileVault status |
| `csrutil status` | Reports SIP status |
| `spctl --status` | Reports Gatekeeper status |
| `softwareupdate -l` | Lists available OS updates |

</details>

---

### 8 · Objective-See Security Scans
Checks the status of Patrick Wardle's free security tools and runs them if installed.

<div align="center"><img src="assets/images/screenshot-objectivesee.jpg" alt="Objective-See Security Scans submenu" width="100%"></div>

| Tool | What it does |
|------|-------------|
| **LuLu** | Open-source outbound firewall — alerts when apps try to phone home |
| **KnockKnock** | Scans for persistent malware and checks against VirusTotal |
| **TaskExplorer** | Shows all running processes with VirusTotal reputation scores |
| **BlockBlock** | Monitors for persistence attempts in real time |
| **RansomWhere** | Detects ransomware-like file encryption activity |
| **ReiKey** | Detects keyloggers by monitoring for keyboard event taps |

If a tool isn't installed, the script offers to open the download page.

---

### 9 · Encrypted Container Wizard
Creates and manages AES-256 encrypted disk images using macOS's built-in `hdiutil`. No third-party software required.

<div align="center"><img src="assets/images/screenshot-encryptedcontainer.jpg" alt="Encrypted Container submenu" width="100%"></div
                                                                                                                                   
- Create a new encrypted container (specify name, size, and location)
- Mount an existing container (prompts for password)
- Unmount an open container
- List all currently mounted containers

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `hdiutil create -size <size>m -fs APFS -encryption AES-256 -volname <name> -type UDIF <output.dmg>` | Creates AES-256 encrypted disk image |
| `hdiutil attach <path.dmg> -notremovable` | Mounts container (prompts for password) |
| `hdiutil detach /Volumes/<name>` | Unmounts (ejects) a container |
| `hdiutil info` | Lists all mounted disk images |

</details>

> *"That's the incomparable beauty of the cryptological art. A little bit of math can accomplish what all the guns and barbed wire can't. A little bit of math can keep a secret."*
> — Edward Snowden

---

### 10 · System Settings Checklist
A guided walkthrough of privacy settings that can only be changed through macOS System Settings (not via terminal commands). The script opens the correct System Settings pane automatically — you just follow the checklist.

Covers: Wi-Fi, General, Siri & Spotlight, Notifications, Lock Screen, Privacy & Security (including Lockdown Mode), iCloud, Game Center, Wallet & Apple Pay, and Auto-Updates.

---

### 11 · System Toggles
One-click switches for common hardening tasks. Each one confirms before running.

| Toggle | What it does |
|--------|-------------|
| Enable / Disable Spotlight | Turns Spotlight indexing on or off completely |
| Enable / Disable Gatekeeper | Controls whether macOS verifies app signatures |
| Disable Siri | Full launchctl disable — kills all Siri background services |
| Disable AirDrop | Turns off AirDrop |
| Disable Remote Connections | Kills SSH, TFTP, Telnet, mDNS multicast, printer sharing, and wipes all Apple Remote Desktop data |
| Disable Time Machine | Turns off automatic backups |
| Disable Guest Account | Full lockdown via both `defaults write` and `sysadminctl` — covers login screen, SMB, and AFP access |
| Login Window Name & Password | Switches the login screen from showing user icons to a name + password prompt (stops attackers from knowing which accounts exist) |

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `sudo mdutil -i off / && sudo mdutil -E /` | Disables Spotlight indexing |
| `sudo spctl --master-disable` | Disables Gatekeeper |
| `sudo launchctl disable 'system/com.apple.assistantd'` | Disables Siri (one of 6 launchctl calls) |
| `defaults write com.apple.NetworkBrowser DisableAirDrop -bool true` | Disables AirDrop |
| `sudo systemsetup -setremotelogin off` | Disables SSH |
| `sudo launchctl disable 'system/com.apple.tftpd'` | Disables TFTP |
| `sudo launchctl disable system/com.apple.telnetd` | Disables Telnet |
| `sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist NoMulticastAdvertisements -bool true` | Disables mDNS multicast |
| `cupsctl --no-share-printers --no-remote-any --no-remote-admin` | Disables all printer sharing |
| `sudo rm -rf /var/db/RemoteManagement` | Wipes Apple Remote Desktop data |
| `sudo tmutil disable` | Disables Time Machine |
| `sudo sysadminctl -guestAccount off` | Disables Guest account (one of 3 sysadminctl calls) |
| `sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true` | Sets name+password login screen |

</details>

---

### 12 · File Search
Search your filesystem and strip metadata from images. Drag a folder into the terminal to set the search location — no typing required.

| Option | What it does |
|--------|-------------|
| Search by Filename | Finds files (not folders) by name anywhere in your home folder (or any folder you drag in). Searches 5 levels deep, capped at 100 results. |
| Search by Content | Full-text search inside files using ripgrep. Skips binary files. Default: ~/Documents. |
| Search by Size | Finds files above a size threshold. Preset options (100MB–5GB) or custom. Shows top 50 largest, sorted correctly regardless of spaces in folder names. |
| **Strip EXIF Metadata** | Removes all metadata from an image — GPS location, camera model, serial number, timestamps. Prevents doxxing via photo sharing. Backup saved as `filename_original.ext` — extension preserved, so the backup itself stays openable. Requires exiftool (script offers to install it). |

---

### 13 · Touch ID for sudo
Lets `sudo` accept a Touch ID scan instead of a typed password.

- Detects hardware support before making any change
- Uses `sudo_local` on macOS Sonoma (14)+, which survives OS updates that overwrite `/etc/pam.d/sudo` directly
- Falls back to editing `/etc/pam.d/sudo` on older macOS (12–13), with the original file backed up first
- Password entry always remains available as a fallback — this adds Touch ID, it doesn't remove the password option
- Enable, disable, and status are all separate, explicit actions — nothing is turned on silently

<details>
<summary><strong>Show terminal commands</strong></summary>

| Command | What it does |
|---------|-------------|
| `grep pam_tid.so /etc/pam.d/sudo_local` | Checks whether Touch ID is currently configured |
| `sudo install -m 444 -o root -g wheel <file> /etc/pam.d/sudo_local` | Writes the Touch ID PAM line with correct permissions |

</details>

---

## Philosophy

sovereign-mac follows a strict set of principles:

**Full disclosure before every action.** Every option shows exactly what it will do before asking you to confirm. Nothing runs silently.

**Safe and reversible.** Privacy Settings use `defaults write` — the standard macOS preference system. Every change can be undone. Nothing deletes system files.

**Minimum footprint.** No installation. No background processes. No configuration files. One script. Run it, close Terminal.

**Plain English.** Every menu option has a plain-English description. No assumption of technical knowledge.

---

## About the Name

**VONU** — *VOluntary Not vUlnerable*

> *"Vonu is the condition or quality of, as well as the action of achieving, an invulnerability to coercion — emphasizing individual responsibility, empowerment, and ultimately FREEDOM."*
> — [Rayo](https://ad-store.sgp1.digitaloceanspaces.com/VONU/2022/08/Vonu%20Book%201%20Paperback%20Official.pdf), libertarian theorist (1960s)

The name originates from Rayo's philosophy of personal sovereignty through radical self-liberation. In the context of macOS privacy, vonu means exactly what it says: your machine should be voluntary and not vulnerable — working for you, on your terms, under your control. Not Apple's.

---

## Security Note

Always review scripts before running them. `sovereign.sh` is plain zsh — no obfuscation, no minification, no funny business. Read it.

Verify the file integrity before running:
```bash
shasum -a 256 sovereign.sh
```

**Expected SHA256:**
```
5787bcfba3332078fd02a82a9694b4b5ca1965b9eb2749df141851fb82d33add
```

See the [Changelog](#-changelog) for what changed in this build.

---

## 📋 Changelog

### Unreleased — Security & Correctness Audit Fixes

Two rounds of independent code audits surfaced several correctness bugs and UX honesty issues. All have been fixed below. SHA256 of `sovereign.sh` updated accordingly (see Security Note above).

**Round 1:**
- **Fixed:** MAC randomization operator-precedence bug — the multicast bit was never actually cleared, which could generate invalid (multicast) MAC addresses.
- **Fixed:** MAC restore function called `ifconfig ... ether ""`, a no-op that did nothing.
- **Fixed:** Quoting bug in Homebrew hardening that wrote a malformed `HOMEBREW_CASK_OPTS` line (worked by accident, but fragile).
- **Fixed:** EXIF stripping tool promised a backup file it never created — now actually creates `filename_original` before stripping metadata.

**Round 2:**
- **Fixed:** MAC restore function still assigned a new random MAC while claiming to "restore" — it now only cycles Wi-Fi power and honestly reports whether a reboot is needed to get back to the hardware MAC.
- **Fixed:** Removed dead/redundant `hdiutil` block in the container list function; fixed a subshell variable-scoping bug using process substitution.
- **Fixed:** Clarified ambiguous backup-filename wording in the EXIF confirmation dialog.
- **Fixed:** Strengthened the log cleanup warning to explicitly call out loss of forensic evidence (`install.log`, `/var/db/receipts`), not just "cannot be recovered."
- **Fixed:** Confirmation prompts now accept `y`, `Y`, `yes`, and `Yes` (previously lowercase `y` only).
- **Added:** macOS version check at script startup — exits cleanly with a clear message on macOS < 12.
- **Removed:** SIGWINCH terminal-resize trap that could wipe in-progress output (e.g. mid-`brew upgrade` or file search) on terminal resize.

**Planned for a future release:**
- Two-mode log cleanup ("Safe Clear" vs. "Full Forensic Wipe") as a more granular alternative to the current single confirmation + warning.

### Round 3 — Real-world testing on Apple Silicon (Mac Mini M4)

- **Confirmed & scoped:** MAC spoofing failure appeared specific to the Wi-Fi interface in initial testing. Testing on wired/Ethernet interfaces succeeded.
- **Fixed:** misleading MAC-change failure message that suggested a sudo or interface-name problem.
- **Fixed:** randomizing a non-Wi-Fi interface (e.g. Ethernet) no longer toggles Wi-Fi power as an unrelated side effect. Previously, `networksetup -setairportpower` would silently redirect to the Wi-Fi interface even when targeting Ethernet, since that command doesn't error on a non-Wi-Fi target — it was disrupting Wi-Fi connectivity for a change that had nothing to do with it.
- **Fixed:** "Show current MAC addresses" crashed with an `awk: non-terminated string` error caused by a literal line break embedded inside a `printf` format string instead of an escaped `\n`.

### Round 4 — Entropy upgrade + native fallback

- **Upgraded:** MAC generation now uses `openssl rand` for real entropy, falling back to `$RANDOM` only if openssl is unavailable.
- **Added:** when Wi-Fi MAC spoofing fails or doesn't verify, the script now points to macOS's built-in Private Wi-Fi Address setting (System Settings → Wi-Fi → network Details) as a reliable native alternative.
- **Corrected:** earlier changelog language overstated Wi-Fi MAC spoofing as a confirmed, universal OS-level block. Further testing showed the earlier diagnostic commands were run against the wrong (unplugged Ethernet) interface, so the "confirmed" block was never actually verified against real Wi-Fi. Real-world evidence across the community is mixed by Mac/macOS version — messaging now reflects that some Macs restrict it, rather than presenting it as certain.

### Round 5 — Pivot to native Private Wi-Fi Address for Wi-Fi

- **Root cause fully identified:** manual Wi-Fi MAC spoofing (via this script, and via well-known community tools like `feross/spoof`/`SpoofMAC`) has always depended on Apple's `airport` binary to disassociate the Wi-Fi interface before changing its MAC. That binary has been removed from current macOS entirely — confirmed missing via direct testing. This isn't fixable from a shell script; it's a removed OS component.
- **Changed:** the MAC spoofing menu no longer offers Wi-Fi-specific randomize/restore options. Instead, it opens System Settings directly to the Wi-Fi pane and directs users to Apple's own **Private Wi-Fi Address** feature, which solves the same privacy goal natively and reliably.
- **Kept:** manual MAC randomization for wired/Ethernet and other custom interfaces, which is confirmed to still work via `ifconfig` on current macOS.

### Round 6 — New modules + cache/path safety audit (cross-checked against Mole)

**Added:**
- Touch ID for sudo (menu item 13) — `sudo_local`-first (Sonoma+) with legacy PAM fallback, original config always backed up before any edit.
- Cache Protection Coverage Check (System Status) — read-only scan listing any cache entries not covered by `PROTECTED_CACHE_IDS`, so new privacy-sensitive apps can be spotted before running Logs & Cache Cleanup rather than after.
- Interactive multi-select picker for Homebrew uninstall (Homebrew Maintenance → Uninstall a Package), replacing a free-text "enter app name" prompt. Lists formulae and casks with sizes, toggle by number, single confirmation before removal.
- Real-time per-item output during cache cleanup (name + size cleared) with a closing summary (items cleared, approximate free-space delta).

**Fixed — cache cleanup was deleting privacy-critical app data:**
- `run_logs_cache_cleanup` used an unqualified wildcard (`rm -rf /Library/Caches/*`, `rm -rf ~/Library/Caches/*`) that deleted the cache for anything living under those paths — including password managers, VPN clients, and the Objective-See tools this project recommends installing. Added `PROTECTED_CACHE_IDS`, a list of real reverse-DNS bundle identifiers (not marketing names), and a `_clear_cache_dir` helper that skips them with per-item reporting.
- Removed four now-dead cache-deletion lines (Homebrew/pip/yarn/npm) that ran *after* the wildcard above had already deleted the same paths — harmless no-ops, but confusing to read as if they were doing something.

**Fixed — path handling:**
- `_clean_path()` had no structural validation. Added `_validate_path()` (rejects non-absolute paths, `..` traversal, control characters) as a sanitizer only — deliberately no existence check, so the three existing call sites keep their specific "Folder not found" / "File not found" messages instead of one generic error.
- Those three call sites previously showed a blank `"Folder not found: "` (nothing after the colon) when `_clean_path` rejected an input outright. Now reports the actual reason and the original input typed.
- Filename search (`_search_filename`) had no `-type f` restriction, so a search root could match its own directory name as a "found" result. Restricted to files.

**Fixed — EXIF strip backup was unopenable:**
- The automatic backup was named `photo.png_original` — appending `_original` after the extension leaves a file with no extension the OS recognizes as an image, so Finder/Preview/QuickLook can't open it even though the underlying data is intact. Now inserts `_original` before the extension (`photo_original.png`).

**Fixed — Search by Size silently truncated results:**
- Parsed `ls -lh` output by awk field position (`$9`), which breaks on any path containing a space — extremely common on macOS (`Library/Application Support/...`). Rewritten to use `stat -f` with a tab-delimited format and sort numerically on raw byte count, which also removes a dependency on GNU-only `sort -h`.

---

## 🔧 Recommended Tools

These aren't required to run sovereign-mac but represent the broader privacy stack worth building around it.

### Browsers
- **[Firefox](https://www.mozilla.org/firefox/)** — open source, extensible, the daily driver. Pair with uBlock Origin.
- **[LibreWolf](https://librewolf.net/)** — Firefox fork with hardened defaults out of the box
- **[Mullvad Browser](https://mullvad.net/browser)** — built with Tor Project, designed to minimize fingerprinting without requiring Tor network
- **[Tor Browser](https://www.torproject.org/)** — maximum anonymity, significant tradeoffs in speed and usability. Not for daily driving.

### VPN
- **[Mullvad VPN](https://mullvad.net)** — no account required, accepts cash and crypto, no logs. The gold standard.
- **[ProtonVPN](https://protonvpn.com)** — open source, audited, strong track record

### Firewall & Security (macOS)
- **[LuLu](https://objective-see.org/products/lulu.html)** — free outbound firewall, alerts when apps phone home
- **[KnockKnock](https://objective-see.org/products/knockknock.html)** — scans for persistent malware, checks VirusTotal
- **[TaskExplorer](https://objective-see.org/products/taskexplorer.html)** — shows all running processes with reputation scores
- **[BlockBlock](https://objective-see.org/products/blockblock.html)** — monitors for persistence attempts in real time
- **[RansomWhere](https://objective-see.org/products/ransomwhere.html)** — detects ransomware-like file encryption
- **[ReiKey](https://objective-see.org/products/reikey.html)** — detects keyloggers
- **[Oversight](https://objective-see.org/products/oversight.html)** — alerts when mic or camera is activated
- **[ClamAV](https://www.clamav.net/)** — open source antivirus, CLI-based, pairs well with this script
- **[Little Snitch](https://www.obdev.at/products/littlesnitch)** — paid, more advanced outbound firewall than LuLu

### Email & Messaging
- **[ProtonMail](https://proton.me)** — encrypted email, zero-knowledge
- **[Signal](https://signal.org)** — the standard for encrypted messaging
- **[Session](https://getsession.org)** — Signal alternative, no phone number required

### Password Management
- **[KeePassXC](https://keepassxc.org)** — local, open source, no cloud sync required
- **[Bitwarden](https://bitwarden.com)** — open source, self-hostable cloud option

### Terminal Setup
- **[iTerm2](https://iterm2.com)** — the macOS terminal replacement. What the screenshots in this README were made with.
- **[Powerlevel10k](https://github.com/romkatv/powerlevel10k)** — zsh theme, instant prompt, beautiful and fast
- **[iTerm2 Color Schemes](https://iterm2colorschemes.com)** — 250+ curated color themes

### Further Reading
- **[privacytools.io](https://www.privacytools.io)** — comprehensive privacy tool recommendations, actively maintained
- **[Privacy Guides](https://www.privacyguides.org)** — community-driven privacy recommendations
- **[Surveillance Self-Defense (EFF)](https://ssd.eff.org)** — practical guides from the Electronic Frontier Foundation

---

Looking for more? I maintain an ever-evolving list of 1,000+ hand-picked privacy tools, books, software, and resources at **[chrisvrakas.com/resources.html](https://chrisvrakas.com/resources.html)** — also available as an open-source repo at **[github.com/chrisvrakas/awesome-polymathic-resource-stack](https://github.com/chrisvrakas/awesome-polymathic-resource-stack)**.

---

## 🙏 Credits & Inspiration

sovereign-mac stands on the shoulders of people who have spent years documenting macOS privacy and security. If you find this tool useful, check out their work:

- **[Michael Bazzell / IntelTechniques](https://inteltechniques.com)** — macOS privacy guide and terminal scripts from *Extreme Privacy* — the book that started this
- **[Patrick Wardle / Objective-See](https://objective-see.org)** — LuLu, KnockKnock, TaskExplorer, BlockBlock, RansomWhere, ReiKey — essential free security tools for macOS
- **[drduh / macOS-Security-and-Privacy-Guide](https://github.com/drduh/macOS-Security-and-Privacy-Guide)** — the definitive macOS security reference on GitHub
- **[undergroundwires / privacy.sexy](https://github.com/undergroundwires/privacy.sexy)** — comprehensive macOS/Windows/Linux privacy script collection
- **[herrbischoff / awesome-macos-command-line](https://github.com/herrbischoff/awesome-macos-command-line)** — curated macOS CLI reference
- **[StevenBlack / hosts](https://github.com/StevenBlack/hosts)** — unified hosts file blocking ~150,000 tracker and ad domains
- **[arkenfox / user.js](https://github.com/arkenfox/user.js)** — Firefox hardening reference
- **[Sun Knudsen](https://sunknudsen.com)** — macOS privacy guides including cold boot attack protection
- **[Rayo](https://ad-store.sgp1.digitaloceanspaces.com/VONU/2022/08/Vonu%20Book%201%20Paperback%20Official.pdf)** — the Vonu philosophy: *VOluntary Not vUlnerable*

---

## 📄 License

**When everyone copyrights, copyleft.**

This project is open source and available under the [MIT License](LICENSE) — fork it, modify it, learn from it. Just give credit where it's due.

---

## 📬 Contact

**Chris Vrakas**

- Website: [chrisvrakas.com](https://chrisvrakas.com)
- GitHub: [@chrisvrakas](https://github.com/chrisvrakas)
- X: [@chris_vrakas](https://x.com/chris_vrakas)
- Medium: [@chrisvrakas](https://medium.com/@chrisvrakas)
- PGP: [freedom@chrisvrakas.com](mailto:freedom@chrisvrakas.com)

---

## ⚡ Fast Facts

- **Zero installation** — no npm, no webpack, no build step, no dependencies
- **Zero tracking** — no analytics, no telemetry, no phoning home
- **Zero trust** — in Apple's defaults, in surveillance capitalism, in the idea that privacy is something to opt into
- **100% zsh** — readable, auditable, yours
- **Shows its work** — every option tells you exactly what it's about to do before doing it. No silent execution, no surprises. Most competing scripts just run.
- **Opens System Settings for you** — the checklist module doesn't just list settings to find yourself. It opens the exact System Settings pane automatically. Nobody else does this.

---

<div align="center">

*"Privacy is not the antithesis of security. Privacy is security, and security is not the absence of crime, it is the presence of justice."*

**— Andreas Antonopoulos**

<br>

**[chrisvrakas.com](https://chrisvrakas.com)** · **[@chris_vrakas](https://x.com/chris_vrakas)** · **[GitHub](https://github.com/chrisvrakas)**

<br>

*YOUR machine. YOUR rules.*

</div>
