#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#   KAIROX v4 — OSCP-Grade Installer  (Clean Animated Edition)
#   Author : Shadly Maliyekkal
#   Usage  : bash install.sh
# ─────────────────────────────────────────────────────────────────

# ── Colours ──────────────────────────────────────────────────────
GREEN='\033[0;32m'; CYAN='\033[0;36m';  YELLOW='\033[1;33m'
RED='\033[0;31m';   BOLD='\033[1m';     PURP='\033[0;35m'
BLUE='\033[0;34m';  WHITE='\033[1;37m'; DIM='\033[2m'; NC='\033[0m'

# ── Terminal control ──────────────────────────────────────────────
hide_cursor() { tput civis 2>/dev/null; }
show_cursor() { tput cnorm 2>/dev/null; }
trap show_cursor EXIT INT TERM

# ── Spinner state ─────────────────────────────────────────────────
SPINNER_PID=""
SPINNER_FRAMES=('⠋' '⠙' '⠹' '⠸' '⠼' '⠴' '⠦' '⠧' '⠇' '⠏')

spinner_start() {
    local label="$1"
    hide_cursor
    (
        local i=0
        while true; do
            local f="${SPINNER_FRAMES[$((i % ${#SPINNER_FRAMES[@]}))]}"
            printf "\r  ${CYAN}${f}${NC}  ${WHITE}%-55s${NC}" "$label"
            sleep 0.08
            ((i++))
        done
    ) &
    SPINNER_PID=$!
}

spinner_ok() {
    local label="$1"
    [ -n "$SPINNER_PID" ] && kill "$SPINNER_PID" 2>/dev/null && wait "$SPINNER_PID" 2>/dev/null
    SPINNER_PID=""
    printf "\r  ${GREEN}✔${NC}  ${WHITE}%-55s${NC}  ${DIM}done${NC}\n" "$label"
    show_cursor
}

spinner_warn() {
    local label="$1" msg="$2"
    [ -n "$SPINNER_PID" ] && kill "$SPINNER_PID" 2>/dev/null && wait "$SPINNER_PID" 2>/dev/null
    SPINNER_PID=""
    printf "\r  ${YELLOW}⚠${NC}  ${WHITE}%-55s${NC}  ${YELLOW}${msg}${NC}\n" "$label"
    show_cursor
}

spinner_skip() {
    local label="$1"
    [ -n "$SPINNER_PID" ] && kill "$SPINNER_PID" 2>/dev/null && wait "$SPINNER_PID" 2>/dev/null
    SPINNER_PID=""
    printf "\r  ${CYAN}◈${NC}  ${WHITE}%-55s${NC}  ${DIM}already installed${NC}\n" "$label"
    show_cursor
}

spinner_fail() {
    local label="$1" msg="$2"
    [ -n "$SPINNER_PID" ] && kill "$SPINNER_PID" 2>/dev/null && wait "$SPINNER_PID" 2>/dev/null
    SPINNER_PID=""
    printf "\r  ${RED}✘${NC}  ${WHITE}%-55s${NC}  ${RED}${msg}${NC}\n" "$label"
    show_cursor
}

section() {
    echo ""
    echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${BOLD}${PURP}  ◈  $*${NC}"
    echo -e "  ${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
}

# ── Banner ────────────────────────────────────────────────────────
clear
echo ""
echo -e "${CYAN} ██╗  ██╗ █████╗ ██╗██████╗  ██████╗ ██╗  ██╗${NC}"
echo -e "${CYAN} ██║ ██╔╝██╔══██╗██║██╔══██╗██╔═══██╗╚██╗██╔╝${NC}"
echo -e "${CYAN} █████╔╝ ███████║██║██████╔╝██║   ██║ ╚███╔╝ ${NC}"
echo -e "${CYAN} ██╔═██╗ ██╔══██║██║██╔══██╗██║   ██║ ██╔██╗ ${NC}"
echo -e "${CYAN} ██║  ██╗██║  ██║██║██║  ██║╚██████╔╝██╔╝ ██╗${NC}"
echo -e "${CYAN} ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝${NC}"
echo ""
echo -e "  ${BOLD}${GREEN}KAIROX v4 — OSCP-Grade Installer${NC}  ${DIM}by Shadly Maliyekkal${NC}"
echo ""

OS="$(uname -s)"
ARCH="$(uname -m)"
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"

# ─────────────────────────────────────────────────────────────────
section "Fixing Files"
# ─────────────────────────────────────────────────────────────────
for f in install.sh kairox; do
    if [ -f "$f" ]; then
        spinner_start "Fixing line endings: $f"
        tr -d '\r' < "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
        chmod +x "$f"
        spinner_ok "Fixed + chmod +x: $f"
    fi
done

# ─────────────────────────────────────────────────────────────────
section "Python 3 + pip + rich"
# ─────────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    spinner_start "Installing python3"
    sudo apt-get install -y python3 python3-pip &>/dev/null 2>&1 || \
    sudo dnf install -y python3 python3-pip &>/dev/null 2>&1
    command -v python3 &>/dev/null && spinner_ok "python3 installed" || spinner_fail "python3" "install failed"
else
    spinner_skip "python3 ($(python3 --version 2>&1))"
fi

if ! command -v pip3 &>/dev/null && ! python3 -m pip --version &>/dev/null 2>&1; then
    spinner_start "Installing pip3"
    sudo apt-get install -y python3-pip &>/dev/null 2>&1 || \
    sudo dnf install -y python3-pip &>/dev/null 2>&1 || true
    spinner_ok "pip3 installed"
fi

install_pip() {
    local pkg="$1" import_name="${2:-$1}"
    if python3 -c "import $import_name" &>/dev/null 2>&1; then
        spinner_skip "pip: $pkg"
        return 0
    fi
    spinner_start "pip install: $pkg"
    python3 -m pip install "$pkg" --break-system-packages -q &>/dev/null 2>&1 || \
    pip3 install "$pkg" --break-system-packages -q &>/dev/null 2>&1 || \
    pip3 install "$pkg" -q &>/dev/null 2>&1 || true
    if python3 -c "import $import_name" &>/dev/null 2>&1; then
        spinner_ok "pip: $pkg"
    else
        spinner_warn "pip: $pkg" "may have failed — try manually"
    fi
}

install_pip "rich"
install_pip "requests"
install_pip "wafw00f" "wafw00f"
install_pip "wapiti3" "wapitiCore"

# ─────────────────────────────────────────────────────────────────
section "System Tools (nmap nikto sslscan dnsrecon whatweb ...)"
# ─────────────────────────────────────────────────────────────────

apt_install() {
    local name="$1" pkg="${2:-$1}"
    if command -v "$name" &>/dev/null; then
        spinner_skip "$name"
        return 0
    fi
    spinner_start "Installing: $name"
    sudo apt-get install -y -qq "$pkg" &>/dev/null 2>&1
    if command -v "$name" &>/dev/null; then
        spinner_ok "$name installed"
    else
        spinner_warn "$name" "not found in apt — skipping"
    fi
}

dnf_install() {
    local name="$1" pkg="${2:-$1}"
    command -v "$name" &>/dev/null && spinner_skip "$name" && return
    spinner_start "Installing: $name"
    sudo dnf install -y -q "$pkg" &>/dev/null 2>&1
    command -v "$name" &>/dev/null && spinner_ok "$name installed" || spinner_warn "$name" "dnf failed"
}

if command -v apt-get &>/dev/null; then
    # Silent apt update
    spinner_start "Updating package index (apt)"
    sudo apt-get update -qq &>/dev/null 2>&1
    spinner_ok "Package index updated"

    for pkg in nmap nikto sslscan dnsrecon curl wget whois git openssl unzip; do
        apt_install "$pkg"
    done

    # whatweb
    apt_install "whatweb"

    # wafw00f via apt fallback
    if ! command -v wafw00f &>/dev/null; then
        apt_install "wafw00f"
    fi

    # testssl.sh — NOT in main apt repo, install directly
    if command -v testssl.sh &>/dev/null || [ -f /usr/local/bin/testssl.sh ]; then
        spinner_skip "testssl.sh"
    else
        spinner_start "Installing testssl.sh (direct download)"
        sudo apt-get install -y -qq testssl.sh &>/dev/null 2>&1
        if command -v testssl.sh &>/dev/null; then
            spinner_ok "testssl.sh (apt)"
        else
            # Download directly from testssl.sh project
            # FIX: removed 'local' keyword — not inside a function
            TSSL_URL="https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh"
            if command -v curl &>/dev/null; then
                sudo curl -fsSL "$TSSL_URL" -o /usr/local/bin/testssl.sh &>/dev/null 2>&1
            elif command -v wget &>/dev/null; then
                sudo wget -q "$TSSL_URL" -O /usr/local/bin/testssl.sh &>/dev/null 2>&1
            fi
            if [ -s /usr/local/bin/testssl.sh ]; then
                sudo chmod +x /usr/local/bin/testssl.sh
                spinner_ok "testssl.sh (direct download -> /usr/local/bin/testssl.sh)"
            else
                spinner_warn "testssl.sh" "download failed — sslscan fallback active"
            fi
        fi
    fi

elif command -v dnf &>/dev/null; then
    spinner_start "Updating package index (dnf)"
    sudo dnf check-update -q &>/dev/null 2>&1 || true
    spinner_ok "Package index updated"
    for pkg in nmap curl wget whois git openssl unzip; do dnf_install "$pkg"; done
    # testssl.sh on dnf systems
    if ! command -v testssl.sh &>/dev/null; then
        spinner_start "Installing testssl.sh (direct download)"
        sudo curl -fsSL "https://raw.githubusercontent.com/drwetter/testssl.sh/3.2/testssl.sh" \
             -o /usr/local/bin/testssl.sh &>/dev/null 2>&1 && \
        sudo chmod +x /usr/local/bin/testssl.sh && \
        spinner_ok "testssl.sh installed" || spinner_warn "testssl.sh" "download failed"
    else
        spinner_skip "testssl.sh"
    fi

elif command -v yum &>/dev/null; then
    for pkg in nmap curl wget whois git openssl unzip; do
        command -v "$pkg" &>/dev/null && spinner_skip "$pkg" && continue
        spinner_start "Installing: $pkg"
        sudo yum install -y -q "$pkg" &>/dev/null 2>&1
        command -v "$pkg" &>/dev/null && spinner_ok "$pkg installed" || spinner_warn "$pkg" "yum failed"
    done
fi

# ─────────────────────────────────────────────────────────────────
section "Go Language Runtime"
# ─────────────────────────────────────────────────────────────────
install_go() {
    local GO_VERSION="1.22.4"
    local GO_FILE
    case "$OS-$ARCH" in
        Linux-x86_64)              GO_FILE="go${GO_VERSION}.linux-amd64.tar.gz"   ;;
        Linux-aarch64|Linux-arm64) GO_FILE="go${GO_VERSION}.linux-arm64.tar.gz"  ;;
        Linux-armv6l|Linux-armv7l) GO_FILE="go${GO_VERSION}.linux-armv6l.tar.gz" ;;
        Darwin-arm64)              GO_FILE="go${GO_VERSION}.darwin-arm64.tar.gz"  ;;
        Darwin-x86_64)             GO_FILE="go${GO_VERSION}.darwin-amd64.tar.gz"  ;;
        *)
            spinner_warn "Go" "Unsupported OS/arch: $OS/$ARCH"
            return 1
            ;;
    esac
    local GO_URL="https://go.dev/dl/${GO_FILE}"
    local TMP="/tmp/kairox_go_$$"
    mkdir -p "$TMP"
    spinner_start "Downloading Go ${GO_VERSION} for ${ARCH}"
    if command -v curl &>/dev/null; then
        curl -fsSL "$GO_URL" -o "$TMP/$GO_FILE" 2>/dev/null
    else
        wget -q "$GO_URL" -O "$TMP/$GO_FILE" 2>/dev/null
    fi
    if [ ! -s "$TMP/$GO_FILE" ]; then
        spinner_fail "Go download" "failed — check internet connection"
        rm -rf "$TMP"; return 1
    fi
    spinner_ok "Go ${GO_VERSION} downloaded"
    spinner_start "Extracting Go to /usr/local"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$TMP/$GO_FILE" &>/dev/null 2>&1
    rm -rf "$TMP"
    export PATH="$PATH:/usr/local/go/bin"
    command -v go &>/dev/null && spinner_ok "Go installed ($(go version))" || spinner_fail "Go" "install failed"
}

if command -v go &>/dev/null; then
    spinner_skip "Go ($(go version))"
else
    install_go
fi

# ─────────────────────────────────────────────────────────────────
section "Go PATH Setup"
# ─────────────────────────────────────────────────────────────────
export GOPATH="${GOPATH:-$HOME/go}"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
mkdir -p "$GOPATH/bin"

spinner_start "Configuring PATH in shell profiles"
for RC in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    [ -f "$RC" ] || [ "$RC" = "$HOME/.bashrc" ] || continue
    touch "$RC" 2>/dev/null
    grep -q "/usr/local/go/bin" "$RC" 2>/dev/null || echo 'export PATH=$PATH:/usr/local/go/bin' >> "$RC"
    grep -q "go/bin" "$RC" 2>/dev/null           || echo 'export PATH=$PATH:$HOME/go/bin'       >> "$RC"
done
spinner_ok "PATH configured (~/.bashrc  ~/.zshrc  ~/.profile)"

# ─────────────────────────────────────────────────────────────────
section "Go Recon & Vuln Tools"
# ─────────────────────────────────────────────────────────────────
install_go_tool() {
    local name="$1" pkg="$2" desc="$3"
    if command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ]; then
        spinner_skip "$name ($desc)"
        return 0
    fi
    if ! command -v go &>/dev/null; then
        spinner_warn "$name" "Go not available"
        return 1
    fi
    spinner_start "go install: $name ($desc)"
    GOPATH="$GOPATH" go install "${pkg}@latest" &>/dev/null 2>&1
    if command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ]; then
        spinner_ok "$name → $GOPATH/bin/$name"
    else
        spinner_warn "$name" "binary not in $GOPATH/bin — may have failed"
    fi
}

install_go_tool "subfinder"   "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"  "subdomain enum"
install_go_tool "httpx"       "github.com/projectdiscovery/httpx/cmd/httpx"             "live host probe + tech"
install_go_tool "dnsx"        "github.com/projectdiscovery/dnsx/cmd/dnsx"               "fast DNS resolver"
install_go_tool "nuclei"      "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"        "CVE/vuln templates"
# FIX: updated naabu to v3 to resolve binary not found issue
install_go_tool "naabu"       "github.com/projectdiscovery/naabu/v3/cmd/naabu"          "fast port scanner"
install_go_tool "katana"      "github.com/projectdiscovery/katana/cmd/katana"           "web crawler"
install_go_tool "gau"         "github.com/lc/gau/v2/cmd/gau"                            "URL harvesting"
install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls"                        "Wayback URLs"
install_go_tool "ffuf"        "github.com/ffuf/ffuf/v2"                                 "directory fuzzer"
install_go_tool "anew"        "github.com/tomnomnom/anew"                               "deduplicate output"

# ─────────────────────────────────────────────────────────────────
section "Nuclei Templates"
# ─────────────────────────────────────────────────────────────────
NUCLEI_BIN=""
command -v nuclei &>/dev/null       && NUCLEI_BIN="nuclei"
[ -f "$GOPATH/bin/nuclei" ]         && NUCLEI_BIN="$GOPATH/bin/nuclei"

if [ -n "$NUCLEI_BIN" ]; then
    spinner_start "Updating nuclei templates (CVE/misconfig/exposure)"
    "$NUCLEI_BIN" -update-templates &>/dev/null 2>&1
    spinner_ok "nuclei templates updated"
else
    spinner_warn "nuclei templates" "nuclei not installed"
fi

# ─────────────────────────────────────────────────────────────────
section "amass (OSINT Subdomain Engine)"
# ─────────────────────────────────────────────────────────────────
if command -v amass &>/dev/null || [ -f "$GOPATH/bin/amass" ]; then
    spinner_skip "amass"
elif command -v snap &>/dev/null; then
    spinner_start "snap install amass"
    sudo snap install amass &>/dev/null 2>&1 && spinner_ok "amass (snap)" || spinner_warn "amass" "snap failed"
elif command -v go &>/dev/null; then
    spinner_start "go install amass"
    go install github.com/owasp-amass/amass/v4/...@latest &>/dev/null 2>&1
    command -v amass &>/dev/null || [ -f "$GOPATH/bin/amass" ] && spinner_ok "amass installed" || spinner_warn "amass" "install failed"
else
    spinner_warn "amass" "not available — DNS fallback active"
fi

# ─────────────────────────────────────────────────────────────────
section "SecLists Wordlists"
# ─────────────────────────────────────────────────────────────────
if [ -d /usr/share/seclists ] || [ -d /usr/share/SecLists ]; then
    spinner_skip "SecLists (already present)"
elif command -v apt-get &>/dev/null; then
    spinner_start "Installing SecLists (apt)"
    sudo apt-get install -y -qq seclists &>/dev/null 2>&1
    if [ -d /usr/share/seclists ]; then
        spinner_ok "SecLists installed via apt"
    else
        spinner_start "Cloning SecLists from GitHub"
        sudo git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists &>/dev/null 2>&1
        [ -d /usr/share/seclists ] && spinner_ok "SecLists cloned" || spinner_warn "SecLists" "clone failed — ffuf limited"
    fi
else
    spinner_start "Cloning SecLists from GitHub"
    sudo git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists &>/dev/null 2>&1
    [ -d /usr/share/seclists ] && spinner_ok "SecLists cloned" || spinner_warn "SecLists" "clone failed"
fi

# ─────────────────────────────────────────────────────────────────
section "Final Tool Status"
# ─────────────────────────────────────────────────────────────────

echo -e "  ${CYAN}┌──────────────────────────────────────────────────────────┐${NC}"
echo -e "  ${CYAN}│            KAIROX v4 — TOOL STATUS SUMMARY               │${NC}"
echo -e "  ${CYAN}└──────────────────────────────────────────────────────────┘${NC}"
echo ""

ALL_TOOLS=(
    "go:Go runtime"
    "python3:Python 3"
    "subfinder:Subdomain enum"
    "amass:OSINT enum"
    "httpx:Live host probe"
    "dnsx:DNS resolver"
    "nuclei:Vuln templates"
    "naabu:Port scanner"
    "katana:Web crawler"
    "gau:URL harvesting"
    "waybackurls:Wayback URLs"
    "ffuf:Directory fuzzer"
    "nmap:Port + service scan"
    "nikto:Web vuln scan"
    "whatweb:Tech fingerprint"
    "sslscan:SSL audit"
    "testssl.sh:Deep SSL audit"
    "wafw00f:WAF detection"
    "dnsrecon:DNS recon"
    "wapiti:Web app scan"
    "curl:HTTP fallback"
    "wget:Downloader"
    "whois:WHOIS lookup"
    "openssl:Cert analysis"
)

INSTALLED=0; MISSING_LIST=()

for entry in "${ALL_TOOLS[@]}"; do
    name="${entry%%:*}"; desc="${entry##*:}"
    if command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ] || [ -f "/usr/local/bin/$name" ]; then
        printf "  ${GREEN}✔${NC}  %-20s ${DIM}%s${NC}\n" "$name" "$desc"
        ((INSTALLED++))
    else
        printf "  ${YELLOW}✘${NC}  %-20s ${YELLOW}missing — fallback active${NC}\n" "$name"
        MISSING_LIST+=("$name")
    fi
done

echo ""
echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${BOLD}${GREEN}  ${INSTALLED}/${#ALL_TOOLS[@]} tools installed${NC}"
echo ""
echo -e "  ${BOLD}Launch KAIROX:${NC}  ${CYAN}./kairox${NC}"
echo ""

if [ ${#MISSING_LIST[@]} -gt 0 ]; then
    echo -e "  ${YELLOW}Missing:${NC} ${MISSING_LIST[*]}"
    echo -e "  ${DIM}KAIROX will use built-in fallbacks for missing tools.${NC}"
    echo ""
    echo -e "  ${DIM}Activate newly installed tools in current shell:${NC}"
    echo -e "  ${CYAN}source ~/.bashrc && ./kairox${NC}"
fi
echo ""
