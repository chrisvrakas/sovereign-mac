#!/bin/zsh

# ============================================
#  ░██████╗  ██████╗ ██╗   ██╗███████╗██████╗ ███████╗██╗ ██████╗ ███╗  ██╗
#  ██╔════╝ ██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██║██╔════╝ ████╗ ██║
#  ╚█████╗  ██║   ██║╚██╗ ██╔╝█████╗  ██████╔╝█████╗  ██║██║  ███╗██╔██╗██║
#  ░╚═══██╗ ██║   ██║ ╚████╔╝ ██╔══╝  ██╔══██╗██╔══╝  ██║██║   ██║██║╚████║
#  ██████╔╝ ╚██████╔╝  ╚██╔╝  ███████╗██║  ██║███████╗██║╚██████╔╝██║ ╚███║
#  ╚═════╝   ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝╚═╝  ╚══╝
#
#  sovereign.sh — macOS Privacy & Security Toolkit
#  Don't trust Apple. Verify.
#  YOUR machine. YOUR rules.
#
# ============================================
# Author:  Chris Vrakas (chrisvrakas.com)
# GitHub:  https://github.com/chrisvrakas/sovereign-mac
# License: MIT
# ============================================
#
# Requirements:
#   macOS 12 (Monterey) or newer
#   Homebrew       https://brew.sh
#   ripgrep        brew install ripgrep
#
# Recommended (from objective-see.org):
#   LuLu, KnockKnock, TaskExplorer,
#   BlockBlock, RansomWhere, ReiKey
#
# Usage:
#   chmod +x sovereign.sh && ./sovereign.sh
#
# ============================================

# Colors
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
BLUE=$(tput setaf 4)
CYAN=$(tput setaf 6)
BOLD=$(tput bold)
RESET=$(tput sgr0)

# Note: previously had a SIGWINCH trap that redrew the header on terminal
# resize, but that cleared the screen mid-operation (e.g. during brew upgrade
# or file search), wiping in-progress output. Removed — not worth the risk.

# ============================================
# HELPERS
# ============================================

print_header() {
    clear
    local cols
    cols=$(tput cols 2>/dev/null || echo "${COLUMNS:-80}")

    echo "${BOLD}${CYAN}"
    if [[ $cols -ge 80 ]]; then
        echo " ░██████╗  ██████╗ ██╗   ██╗███████╗██████╗ ███████╗██╗ ██████╗ ███╗  ██╗"
        echo " ██╔════╝ ██╔═══██╗██║   ██║██╔════╝██╔══██╗██╔════╝██║██╔════╝ ████╗ ██║"
        echo " ╚█████╗  ██║   ██║╚██╗ ██╔╝█████╗  ██████╔╝█████╗  ██║██║  ███╗██╔██╗██║"
        echo " ░╚═══██╗ ██║   ██║ ╚████╔╝ ██╔══╝  ██╔══██╗██╔══╝  ██║██║   ██║██║╚████║"
        echo " ██████╔╝ ╚██████╔╝  ╚██╔╝  ███████╗██║  ██║███████╗██║╚██████╔╝██║ ╚███║"
        echo " ╚═════╝   ╚═════╝    ╚═╝   ╚══════╝╚═╝  ╚═╝╚══════╝╚═╝ ╚═════╝╚═╝  ╚══╝"
    else
        echo "  ╔═╗╔═╗╦  ╦╔═╗╦═╗╔═╗╦╔═╗╔╗╔"
        echo "  ╚═╗║ ║╚╗╔╝║╣ ╠╦╝║╣ ║║ ╦║║║"
        echo "  ╚═╝╚═╝ ╚╝ ╚═╝╩╚═╚═╝╩╚═╝╝╚╝"
    fi
    echo "${RESET}"

    echo "  ${BOLD}${CYAN}A macOS Privacy & Security Toolkit${RESET}"
    echo "  ${RED}Don't trust Apple. Verify.${RESET}"
    echo "  ${BLUE}YOUR machine. YOUR rules.${RESET}"
    echo ""
}

print_section() {
    echo ""
    echo "${BOLD}${CYAN}── $1 ──────────────────────────────────${RESET}"
    echo ""
}

print_ok()   { echo "${GREEN}  ✅ $1${RESET}"; }
print_warn() { echo "${YELLOW}  ⚠  $1${RESET}"; }
print_info() { echo "${BLUE}  → $1${RESET}"; }
print_err()  { echo "${RED}  ✗  $1${RESET}"; }

pause() {
    echo ""
    printf "${BOLD}  Press Enter to continue...${RESET}"
    read -r
}

confirm_proceed() {
    # Usage: confirm_proceed "Title" "line1" "line2" ...
    # Returns 0 (true) if user confirms, 1 (false) if not
    local title="$1"
    shift
    echo ""
    echo "  ${BOLD}${CYAN}$title${RESET}"
    echo ""
    for line in "$@"; do
        echo "  ${BLUE}  • $line${RESET}"
    done
    echo ""
    printf "${YELLOW}  Proceed? (y/n): ${RESET}"
    read -r ans
    [[ "$ans" =~ ^[Yy](es)?$ ]]
}

# ============================================
# MODULE: BREW UPDATES
# ============================================

run_brew_updates() {
    print_section "BREW UPDATES"

    confirm_proceed "What this does:" \
        "Disables Homebrew analytics" \
        "Updates Homebrew and all installed packages" \
        "Upgrades casks (GUI apps) via --greedy flag" \
        "Removes old versions and clears download cache" \
        "Removes unused dependencies" \
        "Runs brew doctor to flag any issues" \
        "Requires internet - does NOT modify system files" \
    || return

    if ! command -v brew &>/dev/null; then
        print_err "Homebrew not found. Install from https://brew.sh"
        return
    fi

    print_info "Disabling analytics..."
    brew analytics off

    print_info "Updating Homebrew..."
    brew update

    print_info "Upgrading all packages (including casks)..."
    brew upgrade --greedy

    print_info "Cleaning up old versions..."
    brew cleanup -s
    rm -rf "$(brew --cache)"

    print_info "Checking for missing dependencies..."
    brew missing

    print_info "Removing unused dependencies..."
    brew autoremove

    print_info "Running brew doctor..."
    brew doctor

    print_ok "Brew updates complete."
}

# ============================================
# MODULE: PRIVACY SETTINGS
# ============================================

# ─────────────────────────────────────────
# Privacy sub-functions (each independently callable)
# ─────────────────────────────────────────

_privacy_telemetry() {
    print_info "Disabling telemetry, analytics and crash reporting..."
    # Core Apple telemetry
    defaults write com.apple.appleseed.FeedbackAssistant "Autogather" -bool false
    defaults write com.apple.CrashReporter DialogType none
    defaults write com.apple.AdLib allowApplePersonalizedAdvertising -bool false
    defaults write com.apple.cloudd.service DisableAnalytics -bool true
    defaults write com.apple.AppStore DisableCollectAnonymousUsage -bool true
    defaults write com.apple.AppStore DisableAdvertisingAnalytics -bool true
    # Per-app analytics
    defaults write com.apple.wifivelocityd DisableWiFiAnalytics -bool true
    defaults write com.apple.passd DisableAnalytics -bool true
    defaults write com.apple.Maps DisableAnalytics -bool true
    defaults write com.apple.news Analytics -bool false
    defaults write com.apple.Photos PHPhotoAnalysisEnabled -bool false
    defaults write com.apple.Photos DisableFacePrint -bool true
    # Keyboard & input privacy
    defaults write NSGlobalDomain WebAutomaticSpellingCorrectionEnabled -bool false
    defaults write NSGlobalDomain AppleAllowKeyboardLearning -bool false
    defaults write com.apple.lookup.shared LookupEnabled -bool false
    # Recent items
    defaults write com.apple.recentitems Applications -dict MaxAmount 0
    # Diagnostic services
    sudo launchctl disable system/com.apple.diagmond 2>/dev/null || true
    sudo defaults write /Library/Application\ Support/CrashReporter/DiagnosticMessagesHistory.plist AutoSubmit -bool false 2>/dev/null || true
    # Full ad tracking lockdown
    defaults write com.apple.AdLib allowIdentifierForAdvertising -bool false
    defaults write com.apple.AdLib forceLimitAdTracking -bool true
    # Screenshot filename hardening — removes timezone/locale metadata from filenames
    defaults write com.apple.screencapture include-date -bool false
    killall SystemUIServer 2>/dev/null || true
    print_ok "Telemetry and analytics disabled."
}

_privacy_safari() {
    print_info "Hardening Safari..."
    defaults write com.apple.Safari UniversalSearchEnabled -bool false
    defaults write com.apple.Safari SuppressSearchSuggestions -bool true
    defaults write com.apple.Safari AutoOpenSafeDownloads -bool false
    defaults write com.apple.Safari BlockStoragePolicy -int 2
    defaults write com.apple.Safari AutoFillFromAddressBook -bool false
    defaults write com.apple.Safari AutoFillPasswords -bool false
    defaults write com.apple.Safari AutoFillCreditCardData -bool false
    print_ok "Safari privacy hardened."
}

_privacy_firewall() {
    print_info "Enabling firewall with stealth mode..."
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setloggingmode on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsigned off
    sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setallowsignedapp off
    # Belt-and-suspenders plist writes
    sudo defaults write /Library/Preferences/com.apple.alf globalstate -bool true
    sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -bool true
    sudo defaults write /Library/Preferences/com.apple.alf allowsignedenabled -bool false
    sudo defaults write /Library/Preferences/com.apple.alf allowdownloadsignedenabled -bool false
    sudo defaults write /Library/Preferences/com.apple.alf loggingenabled -bool true
    sudo defaults write com.apple.security.firewall EnableFirewall -bool true
    sudo defaults write com.apple.security.firewall EnableStealthMode -bool true
    sudo pkill -HUP socketfilterfw 2>/dev/null || true
    print_ok "Firewall enabled with stealth mode and logging."
}

_privacy_screenlock() {
    print_info "Configuring screen lock..."
    defaults write com.apple.screensaver askForPassword -int 1
    defaults write com.apple.screensaver askForPasswordDelay -int 0
    # Disable automatic FDE login (require password even after FileVault unlock on boot)
    sudo defaults write /Library/Preferences/com.apple.loginwindow DisableFDEAutoLogin -bool true
    # Auto-logout after 30 minutes of inactivity
    sudo defaults write /Library/Preferences/com.apple.loginwindow "com.apple.autologout.AutoLogOutDelay" -int 1800
    # Secure keyboard entry in Terminal (prevents other apps reading keystrokes)
    defaults write com.apple.Terminal SecureKeyboardEntry -bool true
    print_ok "Screen lock hardened."
}

_privacy_dsstore() {
    print_info "Disabling .DS_Store on network/USB drives..."
    defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true
    print_ok ".DS_Store creation disabled on network and USB drives."
}

_privacy_notifications() {
    print_info "Disabling Notification Center suggestions and previews..."
    defaults write com.apple.ncprefs NotificationCenterDisableSuggestions -bool true
    defaults write com.apple.notificationcenterui "NSUserDictionaryReplacementItems" -int 0
    defaults write com.apple.ncprefs "showSensitiveContent" -int 0
    defaults write com.apple.TimeMachine DoNotOfferNewDisksForBackup -bool true
    print_ok "Notifications hardened."
}

_privacy_connectivity() {
    print_info "Disabling Handoff, AirPlay, Captive Portal and network wake..."
    defaults write com.apple.coreservices.uiagent "CSUIHasSafariBeenLaunched" -bool true
    defaults write com.apple.NetworkBrowser DisableAirDrop -bool true
    defaults write com.apple.coreservices.useractivityd "ActivityAdvertisingAllowed" -bool false
    defaults write com.apple.coreservices.useractivityd "ActivityReceivingAllowed" -bool false
    defaults write com.apple.controlcenter "AirplayReceiverEnabled" -bool false
    sudo pmset -a womp 0
    # Disable Continuity / Universal Clipboard
    defaults write com.apple.continuity.pickup.notification enabled -bool false
    # Disable Captive Portal (auto-browser on new WiFi — exploitable by attackers)
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.captive.control.plist Active -bool false
    # Disable Remote Apple Events
    sudo systemsetup -setremoteappleevents off 2>/dev/null || true
    print_ok "Handoff, AirPlay, Captive Portal and network wake disabled."
}

_privacy_spotlight() {
    print_info "Disabling Spotlight analytics and web search features..."
    defaults write com.apple.Spotlight "AnalyticsEnabled" -bool false
    defaults write com.apple.lookup.shared LookupSuggestionsDisabled -bool true
    defaults write com.apple.spotlight WebResults -int 0
    defaults write com.apple.Spotlight WebEnabled -bool false
    defaults write com.apple.Spotlight SiriSuggestionsEnabled -bool false
    sudo killall mds 2>/dev/null || true
    print_ok "Spotlight analytics and web search disabled."
}

_privacy_misc() {
    print_info "Disabling Game Center, sounds, and recent items in Dock..."
    defaults write com.apple.gamed Disabled -bool true
    sudo nvram SystemAudioVolume=" "
    defaults write com.apple.systemsound "com.apple.sound.beep.sound" -string ""
    defaults write NSGlobalDomain "com.apple.sound.uiaudio.enabled" -int 0
    # Remove recent apps from Dock
    defaults write com.apple.dock show-recents -bool false
    killall Dock 2>/dev/null || true
    # Prevent apps from restoring windows on relaunch
    defaults write NSGlobalDomain NSQuitAlwaysKeepsWindows -bool false
    # Show all file extensions — prevents Evil.jpg.app masquerading as an image
    defaults write NSGlobalDomain AppleShowAllExtensions -bool true
    killall Finder 2>/dev/null || true
    print_ok "Game Center, sounds, Dock recent items, and file extensions updated."
}

_privacy_ntp() {
    print_info "Switching NTP server to pool.ntp.org..."
    sudo systemsetup -setnetworktimeserver pool.ntp.org 2>/dev/null
    sudo systemsetup -setusingnetworktime on 2>/dev/null
    sudo defaults write /Library/Preferences/com.apple.timezone.auto Active -bool false
    print_ok "NTP server set to pool.ntp.org."
}

# ─────────────────────────────────────────
# Additional privacy sub-functions
# ─────────────────────────────────────────

_privacy_icloud() {
    print_info "Hardening iCloud settings..."
    # Save documents locally by default, not iCloud
    defaults write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false
    # Disable iCloud Desktop & Documents sync
    defaults write com.apple.finder FXICloudDriveDesktop -bool false
    defaults write com.apple.finder FXICloudDriveDocuments -bool false
    # Disable Find My Mac tracking
    defaults write com.apple.FindMy FMMDisabled -bool true
    # Suppress Apple ID cloud setup prompt
    defaults write com.apple.SetupAssistant DidSeeCloudSetup -bool true
    print_ok "iCloud hardened — documents save locally by default."
}

_privacy_sleep() {
    print_info "Hardening sleep and hibernation security..."
    # Destroy FileVault key on standby — prevents cold boot attacks
    # Without this, your encryption key stays in RAM during sleep and can be extracted
    sudo pmset -a destroyfvkeyonstandby 1
    sudo pmset -a hibernatemode 25    # Full disk hibernate — RAM contents written to disk, then cleared
    sudo pmset -a standbydelaylow 0   # Enter standby immediately when battery is LOW
    sudo pmset -a standbydelayhigh 0  # Enter standby immediately when battery is HIGH
    sudo pmset -a standby 1           # Keep standby ENABLED (required for destroyfvkeyonstandby to work)
    sudo pmset -a powernap 0          # Disable Power Nap (background network activity during sleep)
    sudo pmset -a autopoweroff 0      # Disable autopoweroff
    print_ok "Sleep security hardened — FileVault key destroyed on standby."
    print_warn "Your Mac will take slightly longer to wake from sleep."
}

# ─────────────────────────────────────────
# App permission reset via tccutil
# ─────────────────────────────────────────

_privacy_permissions() {
    print_section "RESET APP PERMISSIONS"
    echo "  ${BLUE}  macOS tracks which apps can access Camera, Microphone,${RESET}"
    echo "  ${BLUE}  Contacts, Calendar, Screen Recording, Full Disk Access, etc.${RESET}"
    echo "  ${BLUE}  Resetting forces every app to ask for permission again.${RESET}"
    echo "  ${YELLOW}  Apps will prompt for access next time they need it.${RESET}"
    echo ""

    while true; do
        echo "  ${GREEN}1)${RESET} Reset ALL permissions         ${BLUE}(nuclear — every app asks again)${RESET}"
        echo "  ${GREEN}2)${RESET} Reset Camera permissions"
        echo "  ${GREEN}3)${RESET} Reset Microphone permissions"
        echo "  ${GREEN}4)${RESET} Reset Screen Recording permissions"
        echo "  ${GREEN}5)${RESET} Reset Full Disk Access permissions"
        echo "  ${GREEN}6)${RESET} Reset Contacts permissions"
        echo "  ${GREEN}7)${RESET} Reset Calendar permissions"
        echo "  ${GREEN}8)${RESET} Reset Accessibility permissions"
        echo "  ${GREEN}9)${RESET} Reset Extended permissions     ${BLUE}(AppleEvents, Speech, Media, Policy, etc.)${RESET}"
        echo "  ${RED}10)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt
        case $opt in
            1)
                confirm_proceed "Reset ALL App Permissions:" \
                    "Every app will lose its current Camera/Mic/Contacts/etc access" \
                    "Apps will prompt you again next time they need access" \
                    "This is the most thorough privacy reset available" \
                || continue
                tccutil reset All 2>/dev/null
                print_ok "All app permissions reset."
                print_warn "Apps will ask for permission again on next use."
                pause ;;
            2) tccutil reset Camera 2>/dev/null
               print_ok "Camera permissions reset."; pause ;;
            3) tccutil reset Microphone 2>/dev/null
               print_ok "Microphone permissions reset."; pause ;;
            4) tccutil reset ScreenCapture 2>/dev/null
               print_ok "Screen Recording permissions reset."; pause ;;
            5) tccutil reset SystemPolicyAllFiles 2>/dev/null
               print_ok "Full Disk Access permissions reset."; pause ;;
            6) tccutil reset AddressBook 2>/dev/null
               print_ok "Contacts permissions reset."; pause ;;
            7) tccutil reset Calendar 2>/dev/null
               print_ok "Calendar permissions reset."; pause ;;
            8) tccutil reset Accessibility 2>/dev/null
               print_ok "Accessibility permissions reset."; pause ;;
            9)
                confirm_proceed "Reset ALL remaining permissions:" \
                    "AppleEvents, ListenEvent, PostEvent, SpeechRecognition" \
                    "FileProviderPresence, MediaLibrary, Siri, Ubiquity" \
                    "Photos, PhotosAdd, Reminders, Location, Motion" \
                    "Contacts (Full+Limited), SystemPolicy (all folders)" \
                    "SystemPolicyAppBundles/AppData/NetVolumes/RemovableVolumes/SysAdminFiles" \
                || continue
                for svc in AppleEvents ListenEvent PostEvent SpeechRecognition \
                           FileProviderPresence MediaLibrary Siri Ubiquity \
                           Photos PhotosAdd Reminders Location Motion \
                           ContactsFull ContactsLimited \
                           SystemPolicyAppBundles SystemPolicyAppData \
                           SystemPolicyNetworkVolumes SystemPolicyRemovableVolumes \
                           SystemPolicySysAdminFiles \
                           SystemPolicyDesktopFolder SystemPolicyDocumentsFolder \
                           SystemPolicyDownloadsFolder; do
                    if tccutil reset "$svc" 2>/dev/null; then
                        print_ok "Reset: $svc"
                    else
                        print_warn "Skipped: $svc (not supported on this macOS version)"
                    fi
                done
                pause ;;
            10) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}

# ─────────────────────────────────────────
# Run all privacy settings non-interactively (used by Run All)
# ─────────────────────────────────────────

_privacy_all() {
    print_section "PRIVACY SETTINGS"
    _privacy_telemetry
    _privacy_safari
    _privacy_firewall
    _privacy_screenlock
    _privacy_dsstore
    _privacy_notifications
    _privacy_connectivity
    _privacy_spotlight
    _privacy_misc
    _privacy_ntp
    _privacy_icloud
    _privacy_sleep
    print_ok "All privacy settings applied."
    print_warn "Some changes require a restart to fully take effect."
}

# ─────────────────────────────────────────
# Privacy settings menu
# ─────────────────────────────────────────

run_privacy_settings() {
    print_section "PRIVACY SETTINGS"
    echo "  ${BLUE}  All settings use 'defaults write' - safe, reversible, no deletions.${RESET}"
    echo "  ${BLUE}  Run all at once or pick individual categories below.${RESET}"
    echo ""

    while true; do
        echo ""
        echo "  ${BOLD}${GREEN}1)${RESET}  Apply All ${BLUE}(recommended — runs all 12 categories below)${RESET}"
        echo "  ${BOLD}${GREEN}2)${RESET}  Telemetry & Analytics    ${BLUE}stops Apple collecting usage data, per-app analytics, keyboard learning${RESET}"
        echo "  ${BOLD}${GREEN}3)${RESET}  Safari Privacy           ${BLUE}disables search suggestions, autofill, and auto-opening downloads${RESET}"
        echo "  ${BOLD}${GREEN}4)${RESET}  Firewall & Stealth Mode  ${BLUE}turns on macOS firewall with logging — hides Mac from network probes${RESET}"
        echo "  ${BOLD}${GREEN}5)${RESET}  Screen Lock              ${BLUE}immediate password on sleep, auto-logout after 30min, secure Terminal input${RESET}"
        echo "  ${BOLD}${GREEN}6)${RESET}  .DS_Store Files          ${BLUE}stops macOS leaving hidden tracking files on USB drives & servers${RESET}"
        echo "  ${BOLD}${GREEN}7)${RESET}  Notification Center      ${BLUE}hides notification previews on lock screen, disables suggestions${RESET}"
        echo "  ${BOLD}${GREEN}8)${RESET}  Handoff & AirPlay        ${BLUE}stops Mac talking to nearby Apple devices, kills Captive Portal exploit${RESET}"
        echo "  ${BOLD}${GREEN}9)${RESET}  Spotlight                ${BLUE}stops Spotlight web searches and sending data to Apple${RESET}"
        echo "  ${BOLD}${GREEN}10)${RESET} Game Center & Sounds     ${BLUE}disables Game Center, kills startup/UI sounds, clears Dock recent apps${RESET}"
        echo "  ${BOLD}${GREEN}11)${RESET} NTP Time Server          ${BLUE}switches time sync from Apple's server to the independent pool.ntp.org${RESET}"
        echo "  ${BOLD}${GREEN}12)${RESET} iCloud Hardening         ${BLUE}saves docs locally by default, disables Find My tracking, iCloud sync${RESET}"
        echo "  ${BOLD}${GREEN}13)${RESET} Sleep Security           ${BLUE}destroys FileVault key on standby — prevents cold boot RAM attacks${RESET}"
        echo "  ${BOLD}${GREEN}14)${RESET} Reset App Permissions    ${BLUE}forces Camera, Mic, Contacts, Screen Recording etc. to ask again${RESET}"
        echo ""
        echo "  ${BOLD}${RED}15)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt
        case $opt in
            1)
                confirm_proceed "Apply ALL privacy settings:" \
                    "Telemetry, Safari, Firewall, Screen Lock, .DS_Store" \
                    "Notifications, Handoff/AirPlay/Captive Portal, Spotlight" \
                    "Game Center/Sounds, NTP, iCloud hardening, Sleep security" \
                    "Note: App Permissions reset is NOT included in Apply All" \
                    "Safe, reversible - uses defaults write only" \
                || continue
                sudo -v
                _privacy_telemetry
                _privacy_safari
                _privacy_firewall
                _privacy_screenlock
                _privacy_dsstore
                _privacy_notifications
                _privacy_connectivity
                _privacy_spotlight
                _privacy_misc
                _privacy_ntp
                _privacy_icloud
                _privacy_sleep
                echo ""
                print_ok "All privacy settings applied."
                print_warn "Some changes require a restart to fully take effect."
                pause ;;
            2)
                confirm_proceed "Telemetry & Analytics:" \
                    "Disables Apple telemetry, crash reporting, personalized ads" \
                    "Disables per-app analytics (WiFi, Wallet, Maps, News, Photos)" \
                    "Disables keyboard learning and internet spell correction" \
                || continue
                _privacy_telemetry; pause ;;
            3)
                confirm_proceed "Safari Privacy:" \
                    "Disables search suggestions, universal search" \
                    "Disables autofill (addresses, passwords, credit cards)" \
                    "Disables auto-open safe downloads" \
                || continue
                _privacy_safari; pause ;;
            4)
                confirm_proceed "Firewall & Stealth Mode:" \
                    "Enables macOS application firewall with logging" \
                    "Enables stealth mode (ignores unsolicited probes)" \
                    "Disables auto-allow for built-in and signed apps" \
                    "Writes to ALF plist for persistence across updates" \
                || continue
                sudo -v
                _privacy_firewall; pause ;;
            5)
                confirm_proceed "Screen Lock:" \
                    "Requires password immediately on screensaver or sleep" \
                    "Disables FDE auto-login (requires password after FileVault boot)" \
                    "Sets auto-logout after 30 minutes of inactivity" \
                    "Enables secure keyboard entry in Terminal" \
                || continue
                sudo -v
                _privacy_screenlock; pause ;;
            6)
                confirm_proceed ".DS_Store on Network/USB:" \
                    "Stops macOS writing .DS_Store files to network drives" \
                    "Stops macOS writing .DS_Store files to USB drives" \
                || continue
                _privacy_dsstore; pause ;;
            7)
                confirm_proceed "Notification Center:" \
                    "Disables notification suggestions" \
                    "Disables notification previews on lock screen" \
                    "Disables Time Machine new disk prompts" \
                || continue
                _privacy_notifications; pause ;;
            8)
                confirm_proceed "Handoff, AirPlay & Captive Portal:" \
                    "Disables Handoff between Mac and iCloud devices" \
                    "Disables AirDrop and AirPlay Receiver" \
                    "Disables Captive Portal (auto-browser on new WiFi — exploitable)" \
                    "Disables Remote Apple Events" \
                    "Disables wake for network access" \
                || continue
                sudo -v
                _privacy_connectivity; pause ;;
            9)
                confirm_proceed "Spotlight:" \
                    "Disables Spotlight web search and Siri suggestions" \
                    "Disables Spotlight analytics and improvement sharing" \
                || continue
                _privacy_spotlight; pause ;;
            10)
                confirm_proceed "Game Center & Sounds:" \
                    "Disables Game Center" \
                    "Disables startup sound and UI sound effects" \
                    "Removes recent apps from Dock" \
                || continue
                sudo -v
                _privacy_misc; pause ;;
            11)
                confirm_proceed "NTP Time Server:" \
                    "Switches time server from Apple to pool.ntp.org" \
                    "Disables automatic timezone detection" \
                || continue
                sudo -v
                _privacy_ntp; pause ;;
            12)
                confirm_proceed "iCloud Hardening:" \
                    "Sets documents to save locally by default (not iCloud)" \
                    "Disables iCloud Desktop and Documents folder sync" \
                    "Disables Find My Mac tracking" \
                || continue
                _privacy_icloud; pause ;;
            13)
                confirm_proceed "Sleep Security:" \
                    "Destroys FileVault encryption key when Mac enters standby" \
                    "Prevents cold boot RAM attacks (attacker extracts key from RAM)" \
                    "Enables full disk hibernate mode — RAM written to disk then cleared" \
                    "Disables Power Nap and autopoweroff (standby remains ON for key destruction)" \
                    "Your Mac will take slightly longer to wake from deep sleep" \
                || continue
                sudo -v
                _privacy_sleep; pause ;;
            14) _privacy_permissions ;;
            15) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}

# ============================================
# MODULE: LOGS & CACHE CLEANUP
# ============================================

run_logs_cache_cleanup() {
    print_section "LOGS & CACHE CLEANUP"

    confirm_proceed "What this does:" \
        "Clears download quarantine history and terminal history" \
        "Empties trash on all volumes" \
        "Deletes system logs, ASL logs, audit logs, diagnostic data" \
        "Clears maintenance logs (daily/weekly/monthly)" \
        "Clears system and user caches (Homebrew, pip, npm, yarn)" \
        "Clears Quick Look thumbnail cache and print spooler" \
        "Clears Xcode derived data and archives" \
        "Clears Safari browsing history, cache, cookies, and thumbnails" \
        "Clears Mail app connection logs" \
        "Clears iOS device backup records and connected device history" \
        "Flushes DNS cache and purges RAM cache" \
        "WARNING: Deletes install.log and receipts — removes forensic evidence" \
        "If your Mac is later compromised, these logs are critical for incident response" \
        "Deleted logs cannot be recovered" \
        "Typically frees 1-10GB+ of disk space" \
    || return

    sudo -v

    print_info "Clearing download quarantine history..."
    sqlite3 "$HOME/Library/Preferences/com.apple.LaunchServices.QuarantineEventsV2" \
        'delete from LSQuarantineEvent' 2>/dev/null

    print_info "Clearing terminal history..."
    rm -f "$HOME/.bash_history"
    rm -f "$HOME/.zsh_history"

    print_info "Emptying trash on all volumes..."
    sudo rm -rfv /Volumes/*/.Trashes/* 2>/dev/null
    rm -rf "$HOME/.Trash/"* 2>/dev/null

    print_info "Clearing system logs..."
    sudo rm -rfv /Library/Logs/* 2>/dev/null
    sudo rm -rfv /var/audit/* 2>/dev/null
    sudo rm -rfv /private/var/audit/* 2>/dev/null
    sudo rm -rfv "$HOME/Library/Logs/"* 2>/dev/null
    sudo rm -rfv /private/var/db/diagnostics/* 2>/dev/null
    sudo rm -rfv /var/db/diagnostics/* 2>/dev/null
    sudo rm -rfv /private/var/db/uuidtext/ 2>/dev/null
    sudo rm -rfv /var/db/uuidtext/ 2>/dev/null
    sudo rm -rfv /private/var/log/asl/* 2>/dev/null
    sudo rm -rfv /var/log/asl/* 2>/dev/null
    sudo rm -fv /var/log/asl.log 2>/dev/null
    sudo rm -fv /var/log/asl.db 2>/dev/null
    sudo rm -fv /var/log/install.log 2>/dev/null
    sudo rm -rfv /var/log/* 2>/dev/null
    sudo rm -rfv /var/db/receipts/* 2>/dev/null
    sudo rm -vf /Library/Receipts/InstallHistory.plist 2>/dev/null

    print_info "Clearing maintenance logs..."
    sudo rm -f /private/var/log/daily.out 2>/dev/null
    sudo rm -f /private/var/log/weekly.out 2>/dev/null
    sudo rm -f /private/var/log/monthly.out 2>/dev/null

    print_info "Clearing system and user caches..."
    sudo rm -rfv /Library/Caches/* 2>/dev/null
    sudo rm -rfv "$HOME/Library/Caches/"* 2>/dev/null
    rm -rf "$HOME/Library/Caches/Homebrew" 2>/dev/null
    rm -rf "$HOME/Library/Caches/pip" 2>/dev/null
    rm -rf "$HOME/Library/Caches/yarn" 2>/dev/null
    rm -rf "$HOME/Library/Caches/npm" 2>/dev/null

    print_info "Clearing Quick Look cache..."
    rm -rf "$HOME/Library/Application Support/Quick Look/"* 2>/dev/null
    qlmanage -r cache 2>/dev/null

    print_info "Clearing print spooler..."
    sudo rm -rfv /var/spool/cups/c0* 2>/dev/null
    sudo rm -rfv /var/spool/cups/tmp/* 2>/dev/null
    sudo rm -rfv /var/spool/cups/cache/job.cache* 2>/dev/null

    print_info "Clearing Xcode derived data..."
    rm -rfv "$HOME/Library/Developer/Xcode/DerivedData/"* 2>/dev/null
    rm -rfv "$HOME/Library/Developer/Xcode/Archives/"* 2>/dev/null
    rm -rfv "$HOME/Library/Developer/Xcode/iOS Device Logs/"* 2>/dev/null

    print_info "Clearing Safari history, cache, and cookies..."
    rm -f "$HOME/Library/Safari/History.db" 2>/dev/null
    rm -f "$HOME/Library/Safari/History.db-lock" 2>/dev/null
    rm -f "$HOME/Library/Safari/History.db-shm" 2>/dev/null
    rm -f "$HOME/Library/Safari/History.db-wal" 2>/dev/null
    rm -f "$HOME/Library/Safari/History.plist" 2>/dev/null
    rm -f "$HOME/Library/Safari/HistoryIndex.sk" 2>/dev/null
    rm -f "$HOME/Library/Safari/Downloads.plist" 2>/dev/null
    rm -f "$HOME/Library/Safari/TopSites.plist" 2>/dev/null
    rm -f "$HOME/Library/Safari/LastSession.plist" 2>/dev/null
    rm -f "$HOME/Library/Safari/WebpageIcons.db" 2>/dev/null
    rm -f "$HOME/Library/Safari/PerSiteZoomPreferences.plist" 2>/dev/null
    rm -f "$HOME/Library/Safari/PerSitePreferences.db" 2>/dev/null
    rm -f "$HOME/Library/Caches/com.apple.Safari/Cache.db" 2>/dev/null
    rm -rf "$HOME/Library/Caches/com.apple.Safari/Webpage Previews" 2>/dev/null
    rm -rf "$HOME/Library/Caches/Metadata/Safari/History" 2>/dev/null
    rm -f "$HOME/Library/Cookies/Cookies.binarycookies" 2>/dev/null
    rm -f "$HOME/Library/Cookies/Cookies.plist" 2>/dev/null
    rm -f "$HOME/Library/Safari/UserNotificationPreferences.plist" 2>/dev/null
    defaults write "$HOME/Library/Preferences/com.apple.Safari" RecentSearchStrings '( )' 2>/dev/null

    print_info "Clearing Mail app logs..."
    rm -rf "$HOME/Library/Containers/com.apple.mail/Data/Library/Logs/Mail/"* 2>/dev/null

    print_info "Clearing iOS device records..."
    rm -rfv "$HOME/Library/Application Support/MobileSync/Backup/"* 2>/dev/null
    sudo rm -rfv /var/db/lockdown/* 2>/dev/null

    print_info "Flushing DNS cache..."
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder

    print_info "Purging RAM cache..."
    sudo purge

    print_ok "Logs and cache cleanup complete."
}


# ============================================
# MODULE: MAC ADDRESS SPOOFER
# ============================================

menu_mac_spoofer() {
    print_section "SPOOF MAC ADDRESS"
    echo "  ${BLUE}  Your MAC address is a unique hardware identifier broadcast${RESET}"
    echo "  ${BLUE}  on every network you join. Spoofing it makes your device${RESET}"
    echo "  ${BLUE}  harder to track across networks (coffee shops, airports, etc).${RESET}"
    echo "  ${YELLOW}  Note: on Apple Silicon, the MAC resets to hardware default on reboot.${RESET}"
    echo "  ${YELLOW}  Use before joining untrusted networks. Restore before going home.${RESET}"
    echo ""

    # Show current MACs for all interfaces
    print_info "Current network interfaces:"
    echo ""
    networksetup -listallhardwareports 2>/dev/null | while IFS= read -r line; do
        echo "  $line"
    done
    echo ""

    while true; do
        echo "  ${GREEN}1)${RESET} Randomize MAC on Wi-Fi interface"
        echo "  ${GREEN}2)${RESET} Randomize MAC on specific interface"
        echo "  ${GREEN}3)${RESET} Restore MAC to hardware default (Wi-Fi)"
        echo "  ${GREEN}4)${RESET} Show current MAC addresses"
        echo "  ${GREEN}5)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt

        case $opt in
            1) _mac_randomize_wifi ;;
            2) _mac_randomize_custom ;;
            3) _mac_restore_wifi ;;
            4) _mac_show_all ;;
            5) break ;;
            *) print_warn "Invalid selection." ;;
        esac
        echo ""
    done
}

_mac_get_wifi_interface() {
    # Returns the BSD interface name for Wi-Fi (e.g. en0)
    networksetup -listallhardwareports 2>/dev/null |         awk '/Wi-Fi/{found=1} found && /Device:/{print $2; exit}'
}

_mac_randomize_wifi() {
    local iface
    iface=$(_mac_get_wifi_interface)
    if [[ -z "$iface" ]]; then
        print_err "Could not detect Wi-Fi interface."
        return
    fi
    _mac_randomize_interface "$iface"
}

_mac_randomize_custom() {
    echo ""
    print_info "Available interfaces:"
    networksetup -listallhardwareports 2>/dev/null |         awk '/Hardware Port:/{port=$0} /Device:/{print "  " port " | " $0}'
    echo ""
    printf "  Enter interface name (e.g. en0, en1): "
    read -r iface
    [[ -z "$iface" ]] && return
    _mac_randomize_interface "$iface"
}

_mac_randomize_interface() {
    local iface="$1"
    # Generate a random locally administered MAC
    # First byte must have bit 1 set (locally administered) and bit 0 unset (unicast)
    local mac
    # Pure zsh MAC generation — no python3 dependency required
    # First byte: bit 1 set (locally administered), bit 0 unset (unicast)
    local b0=$(( ((RANDOM % 254) | 0x02) & 0xFE ))
    mac=$(printf '%02x:%02x:%02x:%02x:%02x:%02x' \
        $b0 \
        $((RANDOM % 256)) \
        $((RANDOM % 256)) \
        $((RANDOM % 256)) \
        $((RANDOM % 256)) \
        $((RANDOM % 256)))
    print_info "Disabling Wi-Fi..."
    networksetup -setairportpower "$iface" off 2>/dev/null || true
    sleep 1
    print_info "Setting MAC to $mac on $iface..."
    sudo ifconfig "$iface" ether "$mac" 2>/dev/null
    if [[ $? -eq 0 ]]; then
        print_info "Re-enabling Wi-Fi..."
        networksetup -setairportpower "$iface" on 2>/dev/null || true
        sleep 2
        local current
        current=$(ifconfig "$iface" 2>/dev/null | awk '/ether/{print $2}')
        if [[ "$current" == "$mac" ]]; then
            print_ok "MAC randomized: $mac on $iface"
            print_warn "This resets on reboot. Run again each session if needed."
        else
            print_warn "MAC may not have changed. Current: $current"
            print_warn "Apple Silicon devices enforce hardware MAC on some interfaces."
        fi
    else
        print_err "Failed to change MAC. Try running with sudo or check interface name."
    fi
}

_mac_restore_wifi() {
    local iface
    iface=$(_mac_get_wifi_interface)
    if [[ -z "$iface" ]]; then
        print_err "Could not detect Wi-Fi interface."
        return
    fi
    confirm_proceed "Restore hardware MAC:"         "This will ONLY work if you have REBOOTED since spoofing"         "Without a reboot, your MAC remains spoofed regardless of this action"         "A full reboot is the only reliable way to restore the hardware-default MAC"     || return
    print_info "Cycling Wi-Fi interface power..."
    networksetup -setairportpower "$iface" off 2>/dev/null || true
    sleep 2
    networksetup -setairportpower "$iface" on 2>/dev/null || true
    sleep 2
    local current
    current=$(ifconfig "$iface" 2>/dev/null | awk '/ether/{print $2}')
    print_ok "Current MAC: $current"
    print_warn "If this is NOT your hardware MAC, a full system reboot is required."
}

_mac_show_all() {
    echo ""
    echo "  ${BOLD}Current MAC addresses:${RESET}"
    echo ""
    networksetup -listallhardwareports 2>/dev/null |         awk '
            /Hardware Port:/ { port=substr($0, index($0,$3)) }
            /Device:/ { dev=$2 }
            /Ethernet Address:/ {
                printf "  %-28s %s  →  %s
", port, dev, $3
            }
        '
    echo ""
}

# ============================================
# MODULE: ENCRYPTED CONTAINER WIZARD
# ============================================

menu_encrypted_container() {
    print_section "ENCRYPTED CONTAINER WIZARD"
    echo "  ${BLUE}  Creates an encrypted .dmg container using Apple's AES-256.${RESET}"
    echo "  ${BLUE}  The container mounts like a drive — anything inside is encrypted.${RESET}"
    echo "  ${BLUE}  Works on internal drives, external drives, or USB sticks.${RESET}"
    echo "  ${BLUE}  Perfect for sensitive files you want protected at rest.${RESET}"
    echo ""

    while true; do
        echo "  ${GREEN}1)${RESET} Create new encrypted container"
        echo "  ${GREEN}2)${RESET} Mount existing container"
        echo "  ${GREEN}3)${RESET} Unmount (eject) a container"
        echo "  ${GREEN}4)${RESET} List mounted containers"
        echo "  ${GREEN}5)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt

        case $opt in
            1) _container_create ;;
            2) _container_mount ;;
            3) _container_unmount ;;
            4) _container_list ;;
            5) break ;;
            *) print_warn "Invalid selection." ;;
        esac
        echo ""
    done
}

_container_create() {
    echo ""
    print_info "Where do you want to save the container?"
    echo "  ${BLUE}  Press Enter to use Desktop, or type a full path.${RESET}"
    printf "  Location [$HOME/Desktop]: "
    read -r location
    [[ -z "$location" ]] && location="$HOME/Desktop"

    if [[ ! -d "$location" ]]; then
        print_err "Directory not found: $location"
        return
    fi

    printf "  Container name (no extension, e.g. 'SecureFiles'): "
    read -r name
    if [[ -z "$name" ]]; then
        print_warn "Name cannot be empty."
        return
    fi

    echo ""
    echo "  ${BOLD}Container size:${RESET}"
    echo "  ${GREEN}1)${RESET} 500 MB"
    echo "  ${GREEN}2)${RESET} 1 GB"
    echo "  ${GREEN}3)${RESET} 5 GB"
    echo "  ${GREEN}4)${RESET} 10 GB"
    echo "  ${GREEN}5)${RESET} Custom size"
    echo ""
    printf "  Selection: "
    read -r size_choice

    local size_mb
    case $size_choice in
        1) size_mb=500 ;;
        2) size_mb=1024 ;;
        3) size_mb=5120 ;;
        4) size_mb=10240 ;;
        5)
            printf "  Enter size in MB: "
            read -r size_mb
            if ! [[ "$size_mb" =~ ^[0-9]+$ ]]; then
                print_warn "Invalid size."
                return
            fi
            ;;
        *) print_warn "Invalid selection."; return ;;
    esac

    local output="$location/$name.dmg"
    if [[ -f "$output" ]]; then
        print_warn "File already exists: $output"
        printf "  Overwrite? (y/n): "
        read -r ow
        [[ "$ow" != "y" ]] && return
    fi

    echo ""
    print_warn "You will be prompted to set a password for the container."
    print_warn "Store this password in your password manager. It cannot be recovered."
    echo ""
    printf "  Press Enter to continue..."
    read -r

    print_info "Creating $size_mb MB encrypted container at $output ..."
    hdiutil create         -size "${size_mb}m"         -fs APFS         -encryption AES-256         -volname "$name"         -type UDIF         "$output" 2>&1

    if [[ -f "$output" ]]; then
        print_ok "Container created: $output"
        print_ok "Size: ${size_mb} MB | Encryption: AES-256 | Format: APFS"
        print_info "Double-click the .dmg file to mount it, or use option 2 from this menu."
    else
        print_err "Container creation failed."
    fi
}

_container_mount() {
    echo ""
    print_info "Drag the .dmg file into this window, or type the full path:"
    printf "  Path to .dmg: "
    read -r dmg_path
    # Strip any drag-and-drop spaces/escapes
    dmg_path=$(echo "$dmg_path" | sed "s/\\ / /g" | xargs)
    if [[ ! -f "$dmg_path" ]]; then
        print_err "File not found: $dmg_path"
        return
    fi
    print_info "Mounting $dmg_path ..."
    hdiutil attach "$dmg_path" -notremovable 2>&1
    local volume
    volume=$(hdiutil info | grep "$dmg_path" -A 20 | grep "Volumes/" | awk '{print $NF}')
    [[ -n "$volume" ]] && print_ok "Mounted at: $volume" || print_ok "Container mounted. Check Finder."
}

_container_unmount() {
    echo ""
    print_info "Mounted containers:"
    _container_list
    echo ""
    printf "  Enter volume name to unmount (e.g. SecureFiles): "
    read -r vol_name
    if [[ -z "$vol_name" ]]; then return; fi
    local vol_path="/Volumes/$vol_name"
    if [[ ! -d "$vol_path" ]]; then
        print_err "Volume not found: $vol_path"
        return
    fi
    hdiutil detach "$vol_path" 2>&1 && print_ok "Unmounted: $vol_path" ||         print_err "Could not unmount. Make sure no files are open inside the container."
}

_container_list() {
    echo ""
    local found=false
    echo "  ${BOLD}Mounted volumes:${RESET}"
    while IFS= read -r vol; do
        echo "  /Volumes/$vol"
        found=true
    done < <(ls /Volumes/ 2>/dev/null)
    [[ "$found" == false ]] && echo "  (no mounted containers)"
}

# ============================================
# MODULE: NEW MACHINE SETUP
# ============================================

menu_new_machine_setup() {
    print_section "NEW MACHINE SETUP"
    echo "  ${BLUE}  One-time hardening tasks for a fresh macOS installation.${RESET}"
    echo "  ${BLUE}  Run these in order on a new machine before daily use.${RESET}"
    echo "  ${YELLOW}  Most of these only need to be done once.${RESET}"
    echo ""

    while true; do
        echo "  ${BOLD}${GREEN}1)${RESET}  Install Homebrew"
        echo "  ${BOLD}${GREEN}2)${RESET}  Harden Homebrew (security env vars)"
        echo "  ${BOLD}${GREEN}3)${RESET}  Set hostname / computer name"
        echo "  ${BOLD}${GREEN}4)${RESET}  Block trackers via /etc/hosts"
        echo "  ${BOLD}${GREEN}5)${RESET}  Generate SSH key pair (Ed25519)"
        echo "  ${BOLD}${GREEN}6)${RESET}  Harden Git global config"
        echo "  ${BOLD}${GREEN}7)${RESET}  Show hidden files in Finder"
        echo "  ${BOLD}${GREEN}8)${RESET}  Set secure umask (077)"
        echo "  ${BOLD}${GREEN}9)${RESET}  Run All New Machine Steps"
        echo "  ${RED}10)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt

        case $opt in
            1) _newmachine_install_brew; pause ;;
            2) _newmachine_harden_brew; pause ;;
            3) _newmachine_hostname; pause ;;
            4) _newmachine_hosts_file; pause ;;
            5) _newmachine_ssh_key; pause ;;
            6) _newmachine_git_config; pause ;;
            7) _newmachine_finder_hidden; pause ;;
            8) _newmachine_umask; pause ;;
            9)
                confirm_proceed "Run ALL new machine setup steps:" \
                    "Install/verify Homebrew" \
                    "Harden Homebrew security environment variables" \
                    "Set hostname and computer name" \
                    "Block trackers via /etc/hosts (Steven Black list)" \
                    "Generate Ed25519 SSH key pair" \
                    "Harden Git global config" \
                    "Show hidden files in Finder" \
                    "Set secure umask (077) — restart required" \
                || continue
                sudo -v
                _newmachine_install_brew
                _newmachine_harden_brew
                _newmachine_hostname
                _newmachine_hosts_file
                _newmachine_ssh_key
                _newmachine_git_config
                _newmachine_finder_hidden
                _newmachine_umask
                print_ok "New machine setup complete."
                print_warn "Restart your Mac for umask changes to take effect."
                pause ;;
            10) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}

_newmachine_install_brew() {
    print_info "Checking Homebrew..."
    if command -v brew &>/dev/null; then
        print_ok "Homebrew already installed: $(brew --version | head -1)"
        return
    fi
    confirm_proceed "Install Homebrew:"         "Downloads and installs Homebrew from brew.sh"         "Requires internet connection and admin password"         "Homebrew is required for most software in this script"     || return
    print_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if command -v brew &>/dev/null; then
        brew analytics off
        print_ok "Homebrew installed and analytics disabled."
    else
        print_err "Installation failed. Visit https://brew.sh for manual instructions."
    fi
}

_newmachine_harden_brew() {
    confirm_proceed "Harden Homebrew:"         "Sets HOMEBREW_NO_INSECURE_REDIRECT=1 in your shell config"         "  — prevents brew from following insecure HTTP redirects (MITM protection)"         "Sets HOMEBREW_CASK_OPTS=--require-sha in your shell config"         "  — requires SHA checksum verification for every cask install"         "Also runs: brew analytics off"         "Writes to ~/.zprofile (takes effect in new terminal sessions)"     || return

    local profile="$HOME/.zprofile"
    local changed=false

    if ! grep -q "HOMEBREW_NO_INSECURE_REDIRECT" "$profile" 2>/dev/null; then
        echo "" >> "$profile"
        echo "# Homebrew security hardening" >> "$profile"
        echo "export HOMEBREW_NO_INSECURE_REDIRECT=1" >> "$profile"
        print_ok "Added HOMEBREW_NO_INSECURE_REDIRECT=1 to $profile"
        changed=true
    else
        print_ok "HOMEBREW_NO_INSECURE_REDIRECT already set."
    fi

    if ! grep -q "HOMEBREW_CASK_OPTS" "$profile" 2>/dev/null; then
        echo 'export HOMEBREW_CASK_OPTS="--require-sha"' >> "$profile"
        print_ok "Added HOMEBREW_CASK_OPTS=--require-sha to $profile"
        changed=true
    else
        print_ok "HOMEBREW_CASK_OPTS already set."
    fi

    # Also disable analytics for current session
    brew analytics off 2>/dev/null
    print_ok "Homebrew analytics disabled."

    if [[ "$changed" == true ]]; then
        print_warn "Open a new terminal session for env vars to take effect."
        print_warn "Or run: source ~/.zprofile"
    fi
}

_newmachine_hostname() {
    local current_host
    current_host=$(scutil --get ComputerName 2>/dev/null)
    echo ""
    echo "  ${BOLD}Current computer name:${RESET} $current_host"
    echo ""
    echo "  ${BLUE}  Your computer name is broadcast on every network you join.${RESET}"
    echo "  ${BLUE}  A generic name like 'MacBook' leaks less identity than${RESET}"
    echo "  ${BLUE}  'Johns-MacBook-Pro' which reveals your name and device.${RESET}"
    echo ""
    echo "  ${GREEN}1)${RESET} Set a custom name"
    echo "  ${GREEN}2)${RESET} Set to generic 'MacBook'"
    echo "  ${GREEN}3)${RESET} Set to random string"
    echo "  ${GREEN}4)${RESET} Cancel"
    echo ""
    printf "  Selection: "
    read -r host_choice

    local new_name
    case $host_choice in
        1)
            printf "  Enter new computer name: "
            read -r new_name
            [[ -z "$new_name" ]] && return
            ;;
        2) new_name="MacBook" ;;
        3)
            new_name="Mac-$(openssl rand -hex 3 | tr '[:lower:]' '[:upper:]')"
            ;;
        4) return ;;
        *) print_warn "Invalid selection."; return ;;
    esac

    sudo scutil --set ComputerName "$new_name"
    sudo scutil --set HostName "$new_name"
    sudo scutil --set LocalHostName "$new_name"
    sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "$new_name"
    print_ok "Computer name set to: $new_name"
    print_warn "Restart for all changes to take effect."
}

_newmachine_hosts_file() {
    confirm_proceed "Block trackers via /etc/hosts:"         "Downloads Steven Black's hosts file (industry standard blocklist)"         "Blocks ads, trackers, malware, and telemetry domains at OS level"         "Works for ALL apps and browsers, not just a browser extension"         "Backs up existing /etc/hosts before making any changes"         "Requires internet connection and sudo"     || return

    print_info "Backing up existing /etc/hosts..."
    sudo cp /etc/hosts "/etc/hosts.backup.$(date +%Y%m%d_%H%M%S)"
    print_ok "Backed up to /etc/hosts.backup.$(date +%Y%m%d_%H%M%S)"

    print_info "Downloading Steven Black's unified hosts file..."
    local tmp_hosts="/tmp/hosts_new"
    curl -fsSL "https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts"         -o "$tmp_hosts" 2>/dev/null

    if [[ ! -s "$tmp_hosts" ]]; then
        print_err "Download failed. Check your internet connection."
        return
    fi

    local count
    count=$(grep -c "^0.0.0.0" "$tmp_hosts" 2>/dev/null || echo "unknown")
    print_info "Downloaded $count blocked domains."

    sudo cp "$tmp_hosts" /etc/hosts
    sudo dscacheutil -flushcache
    sudo killall -HUP mDNSResponder 2>/dev/null || true
    rm -f "$tmp_hosts"

    print_ok "Hosts file updated. $count domains now blocked at OS level."
    print_info "To update in the future, run this option again."
    print_info "To restore original: sudo cp /etc/hosts.backup.<date> /etc/hosts"
}

_newmachine_ssh_key() {
    echo ""
    if [[ -f "$HOME/.ssh/id_ed25519" ]]; then
        print_ok "Ed25519 SSH key already exists at ~/.ssh/id_ed25519"
        printf "  Generate an additional key anyway? (y/n): "
        read -r extra
        [[ "$extra" != "y" ]] && return
    fi

    confirm_proceed "Generate Ed25519 SSH key pair:"         "Creates ~/.ssh/id_ed25519 (private) and id_ed25519.pub (public)"         "Ed25519 is the most secure and modern SSH key algorithm"         "You will be prompted to set a passphrase (strongly recommended)"         "Never share your private key — only share the .pub file"     || return

    printf "  Label for this key (e.g. your email or machine name): "
    read -r key_label
    [[ -z "$key_label" ]] && key_label="$(whoami)@$(scutil --get ComputerName 2>/dev/null || hostname)"

    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    ssh-keygen -t ed25519 -C "$key_label" -f "$HOME/.ssh/id_ed25519"

    if [[ -f "$HOME/.ssh/id_ed25519.pub" ]]; then
        print_ok "SSH key pair generated."
        echo ""
        echo "  ${BOLD}Your public key (safe to share):${RESET}"
        cat "$HOME/.ssh/id_ed25519.pub"
        echo ""
        print_info "Add this public key to GitHub, servers, etc."
        print_warn "NEVER share the private key: ~/.ssh/id_ed25519"
    fi
}

_newmachine_git_config() {
    confirm_proceed "Harden Git global config:"         "Sets a generic or alias name/email (avoids leaking identity in commits)"         "Disables Git credential storage in plaintext"         "Sets main as default branch name"     || return

    echo ""
    printf "  Git display name (press Enter for 'Anonymous'): "
    read -r git_name
    [[ -z "$git_name" ]] && git_name="Anonymous"

    printf "  Git email (press Enter for 'user@localhost'): "
    read -r git_email
    [[ -z "$git_email" ]] && git_email="user@localhost"

    git config --global user.name "$git_name"
    git config --global user.email "$git_email"
    git config --global init.defaultBranch main
    git config --global credential.helper ""
    git config --global core.excludesFile "$HOME/.gitignore_global"

    # Create a sensible global gitignore
    cat > "$HOME/.gitignore_global" << 'GITIGNORE'
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
*.log
.env
.env.local
*.pem
*.key
GITIGNORE

    print_ok "Git configured: name='$git_name' email='$git_email'"
    print_ok "Credential storage disabled."
    print_ok "Global .gitignore created at ~/.gitignore_global"
}

_newmachine_finder_hidden() {
    confirm_proceed "Show hidden files in Finder:"         "Makes all hidden files and folders visible in Finder"         "Equivalent to pressing Shift+Cmd+. in Finder"         "Important for accessing ~/Library and other hidden system folders"         "Reversible — run again to toggle off"     || return

    local current
    current=$(defaults read com.apple.finder AppleShowAllFiles 2>/dev/null)
    if [[ "$current" == "TRUE" || "$current" == "1" || "$current" == "true" ]]; then
        defaults write com.apple.finder AppleShowAllFiles FALSE
        killall Finder 2>/dev/null
        print_ok "Hidden files now CONCEALED in Finder."
    else
        defaults write com.apple.finder AppleShowAllFiles TRUE
        killall Finder 2>/dev/null
        print_ok "Hidden files now VISIBLE in Finder."
        print_info "You can now access ~/Library and other hidden folders."
    fi
}

_newmachine_umask() {
    confirm_proceed "Set secure umask (077):" \
        "Makes all new files/folders owner-only by default" \
        "No group or other users can read your new files" \
        "Recommended by macOS Security and Privacy Guide (drduh)" \
        "Requires a restart to take effect" \
    || return
    sudo launchctl config user umask 077
    print_ok "umask set to 077."
    print_warn "Restart required for this to take effect."
}

run_weekly_all() {
    print_section "WEEKLY MAINTENANCE - RUN ALL"

    echo "  ${BOLD}This will run the following three tasks in sequence:${RESET}"
    echo ""

    echo "  ${BOLD}${CYAN}1. Brew Updates${RESET}"
    echo "  ${BLUE}   Disables Homebrew analytics, then runs:${RESET}"
    echo "  ${BLUE}   brew update         - fetches latest package info${RESET}"
    echo "  ${BLUE}   brew upgrade --greedy - upgrades ALL packages including GUI apps${RESET}"
    echo "  ${BLUE}   brew cleanup        - removes old versions and clears download cache${RESET}"
    echo "  ${BLUE}   brew autoremove     - removes unused dependencies${RESET}"
    echo "  ${BLUE}   brew doctor         - checks for issues${RESET}"
    echo ""

    echo "  ${BOLD}${CYAN}2. Privacy Settings (ALL categories)${RESET}"
    echo "  ${BLUE}   Applies macOS privacy hardening via defaults write - safe and reversible:${RESET}"
    echo "  ${BLUE}   - Disables Apple telemetry, crash reporting, personalized ads${RESET}"
    echo "  ${BLUE}   - Disables Siri data sharing and analytics${RESET}"
    echo "  ${BLUE}   - Hardens Safari (search suggestions, autofill, auto-downloads off)${RESET}"
    echo "  ${BLUE}   - Enables macOS firewall with stealth mode${RESET}"
    echo "  ${BLUE}   - Requires password immediately on screensaver/sleep${RESET}"
    echo "  ${BLUE}   - Disables Handoff, AirPlay Receiver, wake for network access${RESET}"
    echo "  ${BLUE}   - Disables Spotlight analytics and suggestions${RESET}"
    echo "  ${BLUE}   - Disables notification previews and suggestions${RESET}"
    echo "  ${BLUE}   - Disables Game Center, startup sound, UI sounds${RESET}"
    echo "  ${BLUE}   - Switches NTP time server to pool.ntp.org${RESET}"
    echo "  ${BLUE}   - Hardens iCloud (local saves by default, disables Find My)${RESET}"
    echo "  ${BLUE}   - Hardens sleep security (destroys FileVault key on standby)${RESET}"
    echo "  ${BLUE}   Note: nothing is deleted - all changes are reversible${RESET}"
    echo ""

    echo "  ${BOLD}${CYAN}3. Logs & Cache Cleanup${RESET}"
    echo "  ${BLUE}   Permanently deletes the following (cannot be recovered):${RESET}"
    echo "  ${BLUE}   - Terminal history (bash + zsh)${RESET}"
    echo "  ${BLUE}   - Download quarantine history${RESET}"
    echo "  ${BLUE}   - System logs, ASL logs, audit logs, diagnostic data${RESET}"
    echo "  ${BLUE}   - System and user caches (Homebrew, pip, npm, yarn)${RESET}"
    echo "  ${BLUE}   - Quick Look thumbnail cache and print spooler${RESET}"
    echo "  ${BLUE}   - Xcode derived data and archives${RESET}"
    echo "  ${BLUE}   - Trash contents${RESET}"
    echo "  ${BLUE}   Also: flushes DNS cache and purges RAM cache${RESET}"
    echo "  ${YELLOW}   Typically frees 1-10GB+ of disk space${RESET}"
    echo ""

    echo "  ${YELLOW}  Excluded (run separately): Security scans, App Permissions reset${RESET}"
    echo ""
    printf "${YELLOW}  Proceed? (y/n): ${RESET}"
    read -r ans
    [[ "$ans" != "y" ]] && return

    sudo -v

    run_brew_updates
    _privacy_all
    run_logs_cache_cleanup

    echo ""
    print_section "DISK SPACE AFTER CLEANUP"
    df -h / | grep -v "Filesystem"

    echo ""
    print_ok "Weekly maintenance complete!"
    print_warn "A restart is recommended to apply all changes."
    echo ""
    printf "${YELLOW}  Restart now? (y/n): ${RESET}"
    read -r restart
    [[ "$restart" == "y" ]] && sudo reboot
}

# ============================================
# MODULE: SYSTEM SETTINGS CHECKLIST
# ============================================

menu_system_settings_checklist() {
    while true; do
        print_section "SYSTEM SETTINGS CHECKLIST"
        echo "  ${BLUE}  These settings require manual clicks in System Settings.${RESET}"
        echo "  ${BLUE}  Select a category - System Settings will open to that pane${RESET}"
        echo "  ${BLUE}  and instructions will be printed here to follow along.${RESET}"
        echo ""
        echo "  ${BOLD}${GREEN}1)${RESET}  Wi-Fi & Network"
        echo "  ${BOLD}${GREEN}2)${RESET}  General (AirDrop, Handoff, AutoFill, Sharing)"
        echo "  ${BOLD}${GREEN}3)${RESET}  Apple Intelligence & Siri"
        echo "  ${BOLD}${GREEN}4)${RESET}  Spotlight"
        echo "  ${BOLD}${GREEN}5)${RESET}  Notifications"
        echo "  ${BOLD}${GREEN}6)${RESET}  Lock Screen"
        echo "  ${BOLD}${GREEN}7)${RESET}  Privacy & Security"
        echo "  ${BOLD}${GREEN}8)${RESET}  iCloud, Game Center & Wallet"
        echo "  ${BOLD}${GREEN}9)${RESET}  Auto-Updates Toggle (with warning)"
        echo "  ${BOLD}${RED}0)${RESET}  Back"
        echo ""
        printf "  ${BOLD}Selection: ${RESET}"
        read -r choice

        case $choice in
            1) _checklist_wifi ;;
            2) _checklist_general ;;
            3) _checklist_siri ;;
            4) _checklist_spotlight ;;
            5) _checklist_notifications ;;
            6) _checklist_lockscreen ;;
            7) _checklist_privacy ;;
            8) _checklist_icloud ;;
            9) _toggle_auto_updates ;;
            0) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}

_open_settings() {
    # Opens System Settings to a specific pane
    # Usage: _open_settings "pane-identifier"
    open "x-apple.systempreferences:$1" 2>/dev/null \
        || open -a "System Settings" 2>/dev/null
    sleep 1
}

_print_checklist() {
    # Prints a formatted checklist of manual steps
    # Usage: _print_checklist "item1" "item2" ...
    echo ""
    echo "  ${BOLD}Follow these steps in System Settings:${RESET}"
    echo ""
    for item in "$@"; do
        echo "  ${YELLOW}  [ ]${RESET} $item"
    done
    echo ""
    print_warn "Check each box as you complete it, then press Enter to continue."
    pause
}

_checklist_wifi() {
    print_section "WI-FI & NETWORK"
    print_info "Opening Network settings..."
    _open_settings "com.apple.preference.network"
    _print_checklist \
        "Wi-Fi > Ask to join networks > Off" \
        "Wi-Fi > Ask to join hotspots > Never" \
        "Firewall > Turn On Firewall (if not already on)" \
        "Firewall > Options > Automatically allow built-in software > Disabled" \
        "Firewall > Options > Automatically allow downloaded signed software > Disabled" \
        "Firewall > Options > Enable stealth mode > Enabled" \
        "Battery > Options > Wake for network access > Never"
}

_checklist_general() {
    print_section "GENERAL SETTINGS"
    print_info "Opening General settings..."
    _open_settings "com.apple.preference.general"
    _print_checklist \
        "AirDrop & Handoff > Allow Handoff between this Mac and your iCloud devices > Off" \
        "AirDrop & Handoff > AirDrop > No One" \
        "AirDrop & Handoff > AirPlay Receiver > Off" \
        "AutoFill & Passwords > AutoFill Passwords and Passkeys > Off" \
        "Date & Time > Source > Set to pool.ntp.org (script handles this automatically)" \
        "Date & Time > Set time zone automatically using current location > Off" \
        "Login Items & Extensions > Review and remove anything unrecognised" \
        "Sharing > Disable ALL sharing services"
}

_checklist_siri() {
    print_section "APPLE INTELLIGENCE & SIRI"
    print_info "Opening Apple Intelligence & Siri settings..."
    _open_settings "com.apple.preference.speech"
    _print_checklist \
        "Apple Intelligence > Off" \
        "Siri > Off" \
        "Siri History > Delete Siri & Dictation History > Delete" \
        "Siri Suggestions & Privacy > Disable all toggles" \
        "Accessibility > Siri > Type to Siri > Off" \
        "Accessibility > Siri > Listen for atypical speech > Off"
}

_checklist_spotlight() {
    print_section "SPOTLIGHT"
    print_info "Opening Spotlight settings..."
    _open_settings "com.apple.preference.spotlight"
    _print_checklist \
        "Show Related Content > Off" \
        "Spotlight Search History > Delete Search History" \
        "Help Apple Improve Search > Off" \
        "Results from Apps > Disable all" \
        "Results from System > Disable all" \
        "Results from Clipboard > Off"
}

_checklist_notifications() {
    print_section "NOTIFICATIONS"
    print_info "Opening Notifications settings..."
    _open_settings "com.apple.preference.notifications"
    _print_checklist \
        "Show previews > Never" \
        "Allow notifications when the device is sleeping > Off" \
        "Allow notifications when the screen is locked > Off" \
        "Allow notifications when mirroring or sharing the display > Off" \
        "Review each app listed and disable notifications for anything unnecessary"
}

_checklist_lockscreen() {
    print_section "LOCK SCREEN"
    print_info "Opening Lock Screen settings..."
    _open_settings "com.apple.preference.screenlock"
    _print_checklist \
        "Turn display off on battery when inactive > 1 hour (or less)" \
        "Turn display off on power adapter when inactive > 1 hour (or less)" \
        "Require password after screen saver begins or display is turned off > Immediately" \
        "Show password hints > Off" \
        "Show message when locked > Off"
}

_checklist_privacy() {
    print_section "PRIVACY & SECURITY"
    print_info "Opening Privacy & Security settings..."
    _open_settings "com.apple.preference.security"
    _print_checklist \
        "Location Services > Off (or review per-app and disable all non-essential)" \
        "Sensitive Content Warning > Off" \
        "Analytics & Improvements > Disable ALL toggles" \
        "Apple Advertising > Personalized Ads > Off" \
        "Apple Intelligence Report > Off" \
        "FileVault > Turn On FileVault (if not already enabled)" \
        "Accessories > Ask for New Accessories > Always Ask" \
        "Lockdown Mode > Turn On (Apple Silicon only — reduces attack surface significantly)" \
        "  Note: Lockdown Mode blocks some web tech, attachments & connections — review Apple's list first"
}

_checklist_icloud() {
    print_section "ICLOUD, GAME CENTER & WALLET"
    print_info "Opening relevant settings..."
    _open_settings "com.apple.preferences.AppleIDPrefPane"
    _print_checklist \
        "iCloud > Review and disable any iCloud services you do not use" \
        "iCloud > iCloud Drive > Off (if not needed)" \
        "iCloud > Photos > Off (if not needed)"
    _open_settings "com.apple.Game-Center-Settings-Extension"
    _print_checklist \
        "Game Center > Disabled (toggle off at top of pane)"
    _open_settings "com.apple.WalletSettingsExtension"
    _print_checklist \
        "Wallet & Apple Pay > Remove any saved cards if not used" \
        "Wallet & Apple Pay > AutoFill Cards > 0 cards selected" \
        "Wallet & Apple Pay > Shipping Address > None" \
        "Wallet & Apple Pay > Add Orders to Wallet > Off"
}

_toggle_auto_updates() {
    print_section "AUTOMATIC UPDATES TOGGLE"
    echo ""
    echo "  ${RED}${BOLD}  WARNING - READ CAREFULLY BEFORE PROCEEDING${RESET}"
    echo ""
    echo "  ${RED}  Disabling automatic updates means your Mac will NOT automatically${RESET}"
    echo "  ${RED}  receive security patches from Apple. This includes critical fixes${RESET}"
    echo "  ${RED}  for zero-day vulnerabilities and active exploits.${RESET}"
    echo ""
    echo "  ${YELLOW}  This is appropriate ONLY if you manually check for and install${RESET}"
    echo "  ${YELLOW}  updates regularly (at least weekly) via:${RESET}"
    echo "  ${YELLOW}  System Settings > General > Software Update${RESET}"
    echo "  ${YELLOW}  OR via this script's System Status > Confirm OS Updates option.${RESET}"
    echo ""
    echo "  ${BLUE}  Reason to disable: Prevents Apple from pushing updates${RESET}"
    echo "  ${BLUE}  at unexpected times and stops background data collection${RESET}"
    echo "  ${BLUE}  associated with the update check process.${RESET}"
    echo ""
    echo "  ${BOLD}Options:${RESET}"
    echo "  ${GREEN}1)${RESET} Disable all automatic updates (manual updates only)"
    echo "  ${GREEN}2)${RESET} Disable only background downloads (keep update checks)"
    echo "  ${GREEN}3)${RESET} Re-enable all automatic updates (restore Apple defaults)"
    echo "  ${GREEN}4)${RESET} Cancel"
    echo ""
    printf "  Selection: "
    read -r upd_choice

    case $upd_choice in
        1)
            print_info "Disabling all automatic updates..."
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool false
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool false
            sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool false
            sudo launchctl disable system/com.apple.softwareupdated 2>/dev/null
            print_ok "All automatic updates disabled."
            print_warn "YOU must now check for updates manually and regularly."
            ;;
        2)
            print_info "Disabling background downloads only..."
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool false
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool false
            print_ok "Background downloads disabled. macOS will still check for updates."
            ;;
        3)
            print_info "Re-enabling all automatic updates..."
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate AutomaticDownload -bool true
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate CriticalUpdateInstall -bool true
            sudo defaults write /Library/Preferences/com.apple.SoftwareUpdate ConfigDataInstall -bool true
            sudo defaults write /Library/Preferences/com.apple.commerce AutoUpdate -bool true
            print_ok "Automatic updates restored to Apple defaults."
            ;;
        4)
            print_info "Cancelled." ;;
        *)
            print_warn "Invalid selection." ;;
    esac
    pause
}



# ============================================
# RESTORED MODULES
# ============================================

menu_homebrew() {
    print_section "HOMEBREW MAINTENANCE"
    echo "  ${BLUE}  Manage all things Homebrew - updates, packages, and security.${RESET}"
    echo ""
    while true; do
        echo ""
        echo "  ${GREEN}1)${RESET} Run Full Brew Update"
        echo "  ${GREEN}2)${RESET} List Installed Packages"
        echo "  ${GREEN}3)${RESET} Uninstall a Package"
        echo "  ${GREEN}4)${RESET} Harden Homebrew Security"
        echo "  ${GREEN}5)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt
        case $opt in
            1) run_brew_updates ;;
            2)
                print_info "Installed brew packages:"
                brew list ;;
            3)
                printf "  Enter app name to uninstall: "
                read -r appname
                confirm_proceed "Uninstall $appname:" \
                    "Removes $appname and all associated files (--zap)" \
                    "Cleans up old Homebrew versions and cache" \
                    "This cannot be undone without reinstalling" \
                || break
                brew uninstall --cask --zap --force "$appname"
                brew cleanup -s
                rm -rf "$(brew --cache)"
                brew missing
                brew autoremove
                print_ok "Uninstall complete." ;;
            4) _newmachine_harden_brew ;;
            5) break ;;
            *) print_warn "Invalid selection." ;;
        esac
        pause
    done
}


menu_system_status() {
    print_section "SYSTEM STATUS"
    echo "  ${BLUE}  Read-only checks - nothing is changed. Use these to verify${RESET}"
    echo "  ${BLUE}  your system security settings are configured correctly.${RESET}"
    echo "  ${BLUE}  Run after macOS updates to confirm nothing was reset.${RESET}"
    echo ""
    while true; do
        echo ""
        echo "  ${GREEN}1)${RESET} Confirm Spotlight"
        echo "  ${GREEN}2)${RESET} Confirm FileVault"
        echo "  ${GREEN}3)${RESET} Confirm SIP"
        echo "  ${GREEN}4)${RESET} Confirm Gatekeeper"
        echo "  ${GREEN}5)${RESET} Confirm OS Updates"
        echo "  ${GREEN}6)${RESET} Confirm Launch Programs"
        echo "  ${GREEN}7)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt
        case $opt in
            1) mdutil -s /; pause ;;
            2) fdesetup status; pause ;;
            3) csrutil status; pause ;;
            4) spctl --status; pause ;;
            5) softwareupdate -l; pause ;;
            6)
                open "$HOME/Library/LaunchAgents/"
                open /Library/LaunchAgents/
                open /Library/LaunchDaemons/
                pause ;;
            7) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}


_check_lulu() {
    print_info "Checking LuLu (outbound firewall — blocks unauthorized connections)..."
    if [[ -d /Applications/LuLu.app ]]; then
        if pgrep -x "LuLu" > /dev/null 2>&1; then
            print_ok "LuLu: Running and active."
        else
            print_warn "LuLu: Installed but NOT running."
            printf "  Launch LuLu now? (y/n): "
            read -r ans
            [[ "$ans" == "y" ]] && open /Applications/LuLu.app
        fi
    else
        print_err "LuLu.app not found - download from objective-see.org/products/lulu.html"
    fi
}


_download_objective_see() {
    echo ""
    print_info "Objective-See tool download links:"
    echo ""
    echo "  LuLu (outbound firewall)          https://objective-see.org/products/lulu.html"
    echo "  KnockKnock (persistent installs)  https://objective-see.org/products/knockknock.html"
    echo "  TaskExplorer (process scanner)    https://objective-see.org/products/taskexplorer.html"
    echo "  BlockBlock (persistence monitor)  https://objective-see.org/products/blockblock.html"
    echo "  RansomWhere (ransomware detector) https://objective-see.org/products/ransomwhere.html"
    echo "  ReiKey (keylogger detector)       https://objective-see.org/products/reikey.html"
    echo ""
    printf "  Open objective-see.org in your browser? (y/n): "
    read -r ans
    [[ "$ans" == "y" ]] && open "https://objective-see.org/products.html"
}


menu_security_scans() {
    print_section "OBJECTIVE-SEE SECURITY SCANS"
    echo "  ${BLUE}  Tools from objective-see.org - free, open source, macOS-native.${RESET}"
    echo "  ${BLUE}  LuLu: outbound firewall - blocks unauthorized connections.${RESET}"
    echo "  ${BLUE}  KnockKnock: scans persistent installs against VirusTotal.${RESET}"
    echo "  ${BLUE}  TaskExplorer: scans running processes against VirusTotal.${RESET}"
    echo "  ${BLUE}  BlockBlock, RansomWhere, ReiKey: real-time monitors.${RESET}"
    echo "  ${BLUE}  Not installed? Each option offers a direct download link.${RESET}"
    echo ""
    while true; do
        echo ""
        echo "  ${GREEN}1)${RESET} Run All Checks"
        echo "  ${GREEN}2)${RESET} LuLu (outbound firewall)"
        echo "  ${GREEN}3)${RESET} KnockKnock (persistent software scan)"
        echo "  ${GREEN}4)${RESET} TaskExplorer (running process scan)"
        echo "  ${GREEN}5)${RESET} BlockBlock (persistence monitor)"
        echo "  ${GREEN}6)${RESET} RansomWhere (ransomware monitor)"
        echo "  ${GREEN}7)${RESET} ReiKey (keylogger monitor)"
        echo "  ${GREEN}8)${RESET} Download missing tools"
        echo "  ${GREEN}9)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt
        case $opt in
            1)
                print_section "RUNNING ALL OBJECTIVE-SEE CHECKS"
                _check_lulu
                _run_knockknock
                _run_taskexplorer
                _check_blockblock
                _check_ransomwhere
                _check_reikey
                print_ok "All Objective-See checks complete."
                pause ;;
            2) _check_lulu; pause ;;
            3) _run_knockknock; pause ;;
            4) _run_taskexplorer; pause ;;
            5) _check_blockblock; pause ;;
            6) _check_ransomwhere; pause ;;
            7) _check_reikey; pause ;;
            8) _download_objective_see; pause ;;
            9) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}


menu_system_toggles() {
    print_section "SYSTEM TOGGLES"
    echo "  ${BLUE}  One-off switches for macOS features. These are set-once-and-forget${RESET}"
    echo "  ${BLUE}  settings - not part of weekly maintenance. Use to lock down features${RESET}"
    echo "  ${BLUE}  like Siri, AirDrop, and remote access that you don't use.${RESET}"
    echo "  ${YELLOW}  Each toggle will ask for confirmation before running.${RESET}"
    echo ""
    while true; do
        echo ""
        echo "  ${GREEN}1)${RESET}  Enable Spotlight"
        echo "  ${GREEN}2)${RESET}  Disable Spotlight"
        echo "  ${GREEN}3)${RESET}  Enable Gatekeeper"
        echo "  ${GREEN}4)${RESET}  Disable Gatekeeper"
        echo "  ${GREEN}5)${RESET}  Disable Siri"
        echo "  ${GREEN}6)${RESET}  Disable AirDrop"
        echo "  ${GREEN}7)${RESET}  Disable Remote Connections"
        echo "  ${GREEN}8)${RESET}  Disable Time Machine"
        echo "  ${GREEN}9)${RESET}  Disable Guest Account"
        echo "  ${GREEN}10)${RESET} Set Login Window to Name & Password"
        echo "  ${RED}11)${RESET} Back"
        echo ""
        printf "  Selection: "
        read -r opt
        case $opt in
            1)
                confirm_proceed "Enable Spotlight:" \
                    "Re-enables Spotlight indexing on the root volume" \
                    "macOS will rebuild the search index (may take a few minutes)" \
                || break
                sudo mdutil -i on / && sudo mdutil -E /
                print_ok "Spotlight enabled." ;;
            2)
                confirm_proceed "Disable Spotlight:" \
                    "Turns off Spotlight indexing on the root volume" \
                    "Spotlight search will no longer work until re-enabled" \
                || break
                sudo mdutil -i off / && sudo mdutil -E /
                print_ok "Spotlight disabled." ;;
            3)
                confirm_proceed "Enable Gatekeeper:" \
                    "Re-enables macOS app verification on launch" \
                    "Apps from unidentified developers will be blocked by default" \
                || break
                sudo spctl --master-enable
                print_ok "Gatekeeper enabled." ;;
            4)
                confirm_proceed "Disable Gatekeeper:" \
                    "Turns off macOS app verification" \
                    "Apps from ANY source will be allowed to run without warning" \
                    "Only disable temporarily if you know what you are installing" \
                || break
                sudo spctl --master-disable
                print_ok "Gatekeeper disabled." ;;
            5)
                confirm_proceed "Disable Siri:" \
                    "Disables Siri assistant and all related background processes" \
                    "Removes Siri from menu bar and disables data sharing" \
                    "Siri will be unavailable until manually re-enabled in System Settings" \
                || break
                defaults write com.apple.assistant.support 'Assistant Enabled' -bool false
                defaults write com.apple.assistant.backedup 'Use device speaker for TTS' -int 3
                launchctl disable "user/$UID/com.apple.assistantd"
                launchctl disable "gui/$UID/com.apple.assistantd"
                sudo launchctl disable 'system/com.apple.assistantd'
                launchctl disable "user/$UID/com.apple.Siri.agent"
                launchctl disable "gui/$UID/com.apple.Siri.agent"
                sudo launchctl disable 'system/com.apple.Siri.agent'
                defaults write com.apple.SetupAssistant 'DidSeeSiriSetup' -bool True
                defaults write com.apple.systemuiserver 'NSStatusItem Visible Siri' 0
                defaults write com.apple.Siri 'StatusMenuVisible' -bool false
                defaults write com.apple.Siri 'UserHasDeclinedEnable' -bool true
                defaults write com.apple.assistant.support 'Siri Data Sharing Opt-In Status' -int 2
                print_ok "Siri disabled." ;;
            6)
                confirm_proceed "Disable AirDrop:" \
                    "Prevents your Mac from appearing in AirDrop to other devices" \
                    "You will not be able to send or receive files via AirDrop" \
                    "Re-enable any time in Finder > AirDrop or System Settings" \
                || break
                defaults write com.apple.NetworkBrowser DisableAirDrop -bool true
                print_ok "AirDrop disabled." ;;
            7)
                confirm_proceed "Disable Remote Connections:" \
                    "Turns off SSH remote login" \
                    "Disables TFTP, Telnet, and mDNS multicast advertisements" \
                    "Disables printer sharing (local printing still works)" \
                    "Wipes Apple Remote Desktop data and settings" \
                    "Use this if you never remotely access your Mac" \
                || break
                sudo systemsetup -setremotelogin off
                sudo launchctl disable 'system/com.apple.tftpd'
                sudo defaults write /Library/Preferences/com.apple.mDNSResponder.plist \
                    NoMulticastAdvertisements -bool true
                sudo launchctl disable system/com.apple.telnetd
                cupsctl --no-share-printers
                cupsctl --no-remote-any
                cupsctl --no-remote-admin
                # Wipe Apple Remote Desktop data files
                sudo rm -rf /var/db/RemoteManagement 2>/dev/null || true
                sudo defaults delete /Library/Preferences/com.apple.RemoteDesktop.plist 2>/dev/null || true
                defaults delete ~/Library/Preferences/com.apple.RemoteDesktop.plist 2>/dev/null || true
                sudo rm -rf "/Library/Application Support/Apple/Remote Desktop/" 2>/dev/null || true
                rm -rf ~/Library/Containers/com.apple.RemoteDesktop 2>/dev/null || true
                print_ok "Remote connections disabled and ARD data wiped." ;;
            8)
                confirm_proceed "Disable Time Machine:" \
                    "Turns off Time Machine automatic backups" \
                    "Existing backups are NOT deleted" \
                    "You can re-enable Time Machine any time in System Settings" \
                || break
                sudo tmutil disable
                print_ok "Time Machine disabled." ;;
            9)
                confirm_proceed "Disable Guest Account:" \
                    "Disables signing in as Guest from the login screen" \
                    "Disables Guest access to file shares over SMB and AFP" \
                    "Uses both defaults write and sysadminctl for thorough lockdown" \
                || break
                sudo defaults write /Library/Preferences/com.apple.loginwindow GuestEnabled -bool NO
                sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server AllowGuestAccess -bool NO
                sudo defaults write /Library/Preferences/com.apple.AppleFileServer guestAccess -bool NO
                sudo sysadminctl -guestAccount off 2>/dev/null || true
                sudo sysadminctl -smbGuestAccess off 2>/dev/null || true
                sudo sysadminctl -afpGuestAccess off 2>/dev/null || true
                sudo killall -HUP AppleFileServer 2>/dev/null || true
                print_ok "Guest account fully disabled." ;;
            10)
                confirm_proceed "Set Login Window to Name & Password:" \
                    "Shows name/password fields instead of user list at login" \
                    "Prevents attackers from seeing which accounts exist on this Mac" \
                || break
                sudo defaults write /Library/Preferences/com.apple.loginwindow SHOWFULLNAME -bool true
                print_ok "Login window set to name and password." ;;
            11) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}


# ─────────────────────────────────────────
# ─────────────────────────────────────────
# FILE SEARCH
# ─────────────────────────────────────────

# Strips surrounding whitespace and quotes from drag-and-drop paths
_clean_path() {
    local p="$1"
    p="${p## }"        # trim leading whitespace
    p="${p%% }"        # trim trailing whitespace
    p="${p//\'/}"      # remove single quotes
    p="${p//\"/}"      # remove double quotes
    p="${p//\\/}"      # remove backslashes (Finder drag-drop escapes spaces as "\ ")
    p="${p/#\~/$HOME}" # expand leading tilde
    echo "$p"
}

menu_search() {
    print_section "FILE SEARCH"
    echo "  ${BLUE}  Search by filename or file content.${RESET}"
    echo "  ${BLUE}  Drag a folder into the terminal to set search location.${RESET}"
    echo "  ${YELLOW}  Note: filename search uses find — not Spotlight.${RESET}"
    echo "  ${YELLOW}  Content search requires ripgrep: brew install ripgrep${RESET}"
    echo "  ${YELLOW}  EXIF strip requires exiftool:   brew install exiftool${RESET}"
    echo ""
    while true; do
        echo ""
        echo "  ${GREEN}1)${RESET}  Search by Filename"
        echo "  ${GREEN}2)${RESET}  Search by Content              ${BLUE}requires ripgrep${RESET}"
        echo "  ${GREEN}3)${RESET}  Search by Size"
        echo "  ${GREEN}4)${RESET}  Strip EXIF Metadata from Image ${BLUE}requires exiftool${RESET}"
        echo "  ${RED}5)${RESET}  Back"
        echo ""
        printf "  Selection: "
        read -r opt
        case $opt in
            1) _search_filename ; pause ;;
            2) _search_content  ; pause ;;
            3) _search_size     ; pause ;;
            4) _strip_exif      ; pause ;;
            5) break ;;
            *) print_warn "Invalid selection." ;;
        esac
    done
}

_search_filename() {
    echo ""
    printf "  Enter filename (or part of it): "
    read -r term
    [[ -z "$term" ]] && { print_warn "No search term entered."; return; }

    echo ""
    echo "  ${BLUE}  Where should we search?${RESET}"
    echo "  ${BLUE}  Press Enter for your home folder, or drag a folder here:${RESET}"
    echo ""
    printf "  Folder (Enter = ~): "
    read -r rawpath
    local searchdir
    searchdir=$(_clean_path "${rawpath:-$HOME}")

    if [[ ! -d "$searchdir" ]]; then
        print_err "Folder not found: $searchdir"
        return
    fi

    echo ""
    print_info "Searching $searchdir for filenames matching: *${term}*"
    print_info "Scanning up to 5 levels deep — showing first 100 results."
    echo ""

    local results
    results=$(find "$searchdir" -maxdepth 5 -iname "*${term}*" 2>/dev/null | head -100)

    if [[ -z "$results" ]]; then
        print_warn "No files found matching: $term"
        print_info "Try a broader term, or search from a higher-level folder."
    else
        echo "$results"
        local count
        count=$(echo "$results" | wc -l | tr -d ' ')
        echo ""
        print_ok "Found ${count} result(s)."
        [[ $count -eq 100 ]] && print_warn "Results capped at 100. Try a more specific term."
    fi
}

_search_content() {
    if ! command -v rg &>/dev/null; then
        print_err "ripgrep is not installed."
        echo ""
        printf "  Install now? (y/n): "
        read -r _ic
        if [[ "$_ic" == "y" || "$_ic" == "Y" ]]; then
            brew install ripgrep
            command -v rg &>/dev/null || { print_err "Install failed. Try: brew install ripgrep"; return; }
            print_ok "ripgrep installed."
        else
            return
        fi
    fi

    echo ""
    printf "  Enter search term: "
    read -r term
    [[ -z "$term" ]] && { print_warn "No search term entered."; return; }

    echo ""
    echo "  ${BLUE}  Where should we search?${RESET}"
    echo "  ${BLUE}  Press Enter for ~/Documents, or drag a folder here:${RESET}"
    echo ""
    printf "  Folder (Enter = ~/Documents): "
    read -r rawpath
    local searchdir
    searchdir=$(_clean_path "${rawpath:-$HOME/Documents}")

    if [[ ! -d "$searchdir" ]]; then
        print_err "Folder not found: $searchdir"
        return
    fi

    echo ""
    print_info "Searching $searchdir for content matching: $term"
    print_info "Skipping binary files. Showing first 200 matches."
    echo ""

    # -F: literal string (not regex) — safe for non-technical users
    # -i: case insensitive
    # -N: no line numbers (cleaner output)
    # No -a: skip binary files — avoids garbage output
    # Temp file lets us stream output live AND check if anything was found
    local tmpfile
    tmpfile=$(mktemp)
    rg -FiN "$term" "$searchdir" 2>/dev/null | head -200 | tee "$tmpfile"

    echo ""
    if [[ -s "$tmpfile" ]]; then
        print_ok "Search complete. Showing up to 200 matches."
    else
        print_warn "No matches found for: $term"
    fi
    rm -f "$tmpfile"
}

_search_size() {
    echo ""
    echo "  ${BOLD}  Find large files on your Mac${RESET}"
    echo ""
    echo "  ${GREEN}1)${RESET}  Files larger than 100 MB"
    echo "  ${GREEN}2)${RESET}  Files larger than 500 MB"
    echo "  ${GREEN}3)${RESET}  Files larger than 1 GB"
    echo "  ${GREEN}4)${RESET}  Files larger than 5 GB"
    echo "  ${GREEN}5)${RESET}  Custom size"
    echo "  ${RED}6)${RESET}  Cancel"
    echo ""
    printf "  Selection: "
    read -r size_choice

    local size_spec=""
    case $size_choice in
        1) size_spec="+100M" ;;
        2) size_spec="+500M" ;;
        3) size_spec="+1G"   ;;
        4) size_spec="+5G"   ;;
        5)
            echo ""
            printf "  Enter minimum size (e.g. 200M, 2G, 500k): "
            read -r custom_size
            [[ -z "$custom_size" ]] && { print_warn "No size entered."; return; }
            size_spec="+${custom_size}"
            ;;
        6) return ;;
        *) print_warn "Invalid selection."; return ;;
    esac

    confirm_proceed "Search for large files:" \
        "Scans your home folder for files above the size threshold" \
        "Does NOT require sudo (your home folder is readable by you)" \
        "Shows the top 50 largest files found" \
        "May take a minute to complete" \
    || return

    echo ""
    print_info "Searching ~/  for files ${size_spec} (this may take a moment)..."
    echo ""

    # Scope to $HOME — scans root is extremely slow and almost never what users need.
    # Power users can open a terminal and run: sudo find / -size +1G 2>/dev/null
    find "$HOME" -type f -size "$size_spec" -exec ls -lh {} \; 2>/dev/null \
        | awk '{print $5 "\t" $9}' \
        | sort -rh \
        | head -50

    echo ""
    print_ok "Done. Showing top 50 largest files in your home folder."
    print_info "To scan your entire Mac: sudo find / -type f -size ${size_spec} 2>/dev/null"
}

_strip_exif() {
    if ! command -v exiftool &>/dev/null; then
        print_err "exiftool is not installed."
        echo ""
        printf "  Install now? (y/n): "
        read -r _ic
        if [[ "$_ic" == "y" || "$_ic" == "Y" ]]; then
            brew install exiftool
            command -v exiftool &>/dev/null || { print_err "Install failed. Try: brew install exiftool"; return; }
            print_ok "exiftool installed."
        else
            return
        fi
    fi

    echo ""
    echo "  ${BLUE}  Strips ALL EXIF metadata from a photo or image file:${RESET}"
    echo "  ${BLUE}  GPS location, camera model, timestamps, serial numbers.${RESET}"
    echo "  ${YELLOW}  A backup is saved automatically as: filename_original${RESET}"
    echo ""
    printf "  Drag image here (or enter full path): "
    read -r rawpath
    local imgpath
    imgpath=$(_clean_path "$rawpath")

    if [[ ! -f "$imgpath" ]]; then
        print_err "File not found: $imgpath"
        return
    fi

    confirm_proceed "Strip EXIF metadata:" \
        "File: $(basename "$imgpath")" \
        "Removes ALL metadata — GPS, camera info, timestamps, serial numbers" \
        "Original backed up as: filename_original (e.g., photo.jpg becomes photo.jpg_original)" \
    || return

    print_info "Backing up original to $(basename "$imgpath")_original..."
    cp "$imgpath" "${imgpath}_original"

    print_info "Stripping metadata from: $(basename "$imgpath")..."
    exiftool -all= -overwrite_original "$imgpath" 2>/dev/null

    if [[ $? -eq 0 ]]; then
        print_ok "All metadata stripped: $imgpath"
        print_info "Backup saved as: ${imgpath}_original"
    else
        print_err "Failed — check that the file is a valid image format."
    fi
}


_run_knockknock() {
    print_info "Running KnockKnock (checks persistent installs against VirusTotal)..."
    if [[ -d /Applications/KnockKnock.app ]]; then
        local tmpfile
        tmpfile=$(mktemp "${TMPDIR:-/tmp}/knockknock.XXXXXX")
        cd /Applications || return
        ./KnockKnock.app/Contents/MacOS/KnockKnock -whosthere -pretty \
            > "$tmpfile" 2>/dev/null
        local hits
        hits=$(rg -aFiNA 1 "VT Detection" "$tmpfile" 2>/dev/null)
        if [[ -z "$hits" ]]; then
            print_ok "KnockKnock: No VirusTotal detections found."
        else
            print_warn "KnockKnock: Detections found - review below:"
            echo "$hits"
        fi
        rm -f "$tmpfile"
    else
        print_err "KnockKnock.app not found - download from objective-see.org"
    fi
}


_run_taskexplorer() {
    print_info "Running TaskExplorer (checks running processes against VirusTotal)..."
    if [[ -d /Applications/TaskExplorer.app ]]; then
        local tmpfile
        tmpfile=$(mktemp "${TMPDIR:-/tmp}/taskexplorer.XXXXXX")
        cd /Applications || return
        sudo ./TaskExplorer.app/Contents/MacOS/TaskExplorer \
            -pretty -explore > "$tmpfile" 2>/dev/null
        sed -i '' 's/VT detection\" \: \"0//g' "$tmpfile"
        local hits
        hits=$(rg -aFiN "VT Detection" "$tmpfile" 2>/dev/null)
        if [[ -z "$hits" ]]; then
            print_ok "TaskExplorer: No VirusTotal detections found."
        else
            print_warn "TaskExplorer: Detections found - review below:"
            echo "$hits"
        fi
        rm -f "$tmpfile"
    else
        print_err "TaskExplorer.app not found - download from objective-see.org"
    fi
}


_check_blockblock() {
    print_info "Checking BlockBlock (monitors persistent installs in real-time)..."
    if [[ -d /Applications/BlockBlock.app ]]; then
        if pgrep -x "BlockBlock" > /dev/null 2>&1; then
            print_ok "BlockBlock: Running and active."
        else
            print_warn "BlockBlock: Installed but NOT running."
            printf "  Launch BlockBlock now? (y/n): "
            read -r ans
            [[ "$ans" == "y" ]] && open /Applications/BlockBlock.app
        fi
    else
        print_err "BlockBlock.app not found - download from objective-see.org"
    fi
}


_check_ransomwhere() {
    print_info "Checking RansomWhere (detects ransomware-like file encryption)..."
    if [[ -d /Applications/RansomWhere.app ]]; then
        if pgrep -x "RansomWhere" > /dev/null 2>&1; then
            print_ok "RansomWhere: Running and active."
        else
            print_warn "RansomWhere: Installed but NOT running."
            printf "  Launch RansomWhere now? (y/n): "
            read -r ans
            [[ "$ans" == "y" ]] && open /Applications/RansomWhere.app
        fi
    else
        print_err "RansomWhere.app not found - download from objective-see.org"
    fi
}


_check_reikey() {
    print_info "Checking ReiKey (detects keyloggers via event tap monitoring)..."
    if [[ -d /Applications/ReiKey.app ]]; then
        if pgrep -x "ReiKey" > /dev/null 2>&1; then
            print_ok "ReiKey: Running and active."
        else
            print_warn "ReiKey: Installed but NOT running."
            printf "  Launch ReiKey now? (y/n): "
            read -r ans
            [[ "$ans" == "y" ]] && open /Applications/ReiKey.app
        fi
    else
        print_err "ReiKey.app not found - download from objective-see.org"
    fi
}


main_menu() {
    # Version flag: ./sovereign.sh --version or -v
    if [[ "$1" == "--version" || "$1" == "-v" ]]; then
        echo "sovereign-mac v1.0.0"
        echo "https://github.com/chrisvrakas/sovereign-mac"
        exit 0
    fi

    while true; do
        print_header
        echo "  ${BOLD}What would you like to do?${RESET}"
        echo ""
        echo "  ${BOLD}${GREEN}1)${RESET}  💾  New Machine Setup"
        echo "  ${BOLD}${GREEN}2)${RESET}  🔄  Weekly Maintenance (Run All)"
        echo "  ${BOLD}${GREEN}3)${RESET}  🍺  Homebrew Maintenance"
        echo "  ${BOLD}${GREEN}4)${RESET}  🧹  Logs & Cache Cleanup"
        echo "  ${BOLD}${GREEN}5)${RESET}  🔒  Privacy Settings"
        echo "  ${BOLD}${GREEN}6)${RESET}  📡  Spoof MAC Address"
        echo "  ${BOLD}${GREEN}7)${RESET}  📊  System Status"
        echo "  ${BOLD}${GREEN}8)${RESET}  🔍  Objective-See Security Scans"
        echo "  ${BOLD}${GREEN}9)${RESET}  🔐  Encrypted Container Wizard"
        echo "  ${BOLD}${GREEN}10)${RESET} 📋  System Settings Checklist"
        echo "  ${BOLD}${GREEN}11)${RESET} 🔧  System Toggles"
        echo "  ${BOLD}${GREEN}12)${RESET} 🔎  File Search"
        echo "  ${BOLD}${RED}0)${RESET}  🛑  Quit"
        echo ""
        printf "  ${BOLD}Selection: ${RESET}"
        read -r choice

        case $choice in
            1)  menu_new_machine_setup ;;
            2)  run_weekly_all ;;
            3)  menu_homebrew ;;
            4)  run_logs_cache_cleanup; pause ;;
            5)  run_privacy_settings ;;
            6)  menu_mac_spoofer ;;
            7)  menu_system_status ;;
            8)  menu_security_scans ;;
            9)  menu_encrypted_container ;;
            10) menu_system_settings_checklist ;;
            11) menu_system_toggles ;;
            12) menu_search ;;
            0)  echo ""; echo ""
        echo "  ${CYAN}  Voluntary Not Vulnerable.${RESET}"
        echo "  ${CYAN}  sovereign-mac — YOUR machine. YOUR rules.${RESET}"; echo ""; exit 0 ;;
            *)  print_warn "Invalid selection." ;;
        esac
    done
}

_check_macos_version() {
    local os_ver
    os_ver=$(sw_vers -productVersion 2>/dev/null | cut -d. -f1)
    if [[ -n "$os_ver" ]] && [[ "$os_ver" -lt 12 ]]; then
        print_err "macOS 12 (Monterey) or newer required. You have $(sw_vers -productVersion)."
        exit 1
    fi
}

_check_macos_version
main_menu "$@"
