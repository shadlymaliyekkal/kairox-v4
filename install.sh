#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────────
#   KAIROX v4 — Full OSCP-Grade Installer
#   Author : Shadly Maliyekkal
#   Usage  : bash install.sh
# ─────────────────────────────────────────────────────────────────

GREEN='\033[0;32m'; CYAN='\033[0;36m'; YELLOW='\033[1;33m'
RED='\033[0;31m';   BOLD='\033[1m';    PURP='\033[0;35m'; NC='\033[0m'

info()  { echo -e "${CYAN}[KAIROX]${NC} $*"; }
ok()    { echo -e "${GREEN}[  OK  ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[ WARN ]${NC} $*"; }
fail()  { echo -e "${RED}[ FAIL ]${NC} $*"; }
step()  { echo -e "\n${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; \
          echo -e "${BOLD}${PURP}  ◈  $*${NC}"; \
          echo -e "${BOLD}${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"; }

echo ""
echo -e "${CYAN} ██╗  ██╗ █████╗ ██╗██████╗  ██████╗ ██╗  ██╗${NC}"
echo -e "${CYAN} ██║ ██╔╝██╔══██╗██║██╔══██╗██╔═══██╗╚██╗██╔╝${NC}"
echo -e "${CYAN} █████╔╝ ███████║██║██████╔╝██║   ██║ ╚███╔╝ ${NC}"
echo -e "${CYAN} ██╔═██╗ ██╔══██║██║██╔══██╗██║   ██║ ██╔██╗ ${NC}"
echo -e "${CYAN} ██║  ██╗██║  ██║██║██║  ██║╚██████╔╝██╔╝ ██╗${NC}"
echo -e "${CYAN} ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝${NC}"
echo ""
echo -e "${BOLD}${GREEN}  KAIROX v4 — OSCP-Grade Installer   by Shadly Maliyekkal${NC}"
echo -e "${CYAN}  Installs: subfinder amass httpx gau waybackurls dnsx dnsrecon${NC}"
echo -e "${CYAN}           nuclei nikto whatweb wapiti sslscan wafw00f ffuf nmap${NC}"
echo ""

OS="$(uname -s)"
ARCH="$(uname -m)"
GOPATH_DEFAULT="$HOME/go"

# ─────────────────────────────────────────────────────────────────
step "Fixing Files"
# ─────────────────────────────────────────────────────────────────
for f in install.sh kairox; do
    if [ -f "$f" ]; then
        tr -d '\r' < "$f" > "${f}.tmp" && mv "${f}.tmp" "$f"
        chmod +x "$f"
        ok "Fixed + chmod +x: $f"
    fi
done

# ─────────────────────────────────────────────────────────────────
step "Python 3 + pip"
# ─────────────────────────────────────────────────────────────────
if ! command -v python3 &>/dev/null; then
    info "Installing python3 ..."
    sudo apt-get install -y python3 python3-pip 2>/dev/null || \
    sudo dnf install -y python3 python3-pip 2>/dev/null || \
    fail "Cannot install python3 — install manually"
fi
ok "python3 -> $(python3 --version 2>&1)"

if ! command -v pip3 &>/dev/null && ! python3 -m pip --version &>/dev/null 2>&1; then
    sudo apt-get install -y python3-pip 2>/dev/null || \
    sudo dnf install -y python3-pip 2>/dev/null || true
fi

install_pip() {
    local pkg="$1"
    python3 -c "import $pkg" &>/dev/null 2>&1 && ok "$pkg already installed" && return
    info "pip install $pkg ..."
    python3 -m pip install "$pkg" --break-system-packages -q 2>/dev/null || \
    pip3 install "$pkg" --break-system-packages -q 2>/dev/null || \
    pip3 install "$pkg" -q 2>/dev/null || \
    warn "Could not install $pkg"
    python3 -c "import $pkg" &>/dev/null 2>&1 && ok "$pkg installed" || warn "$pkg install may have failed"
}

install_pip rich
install_pip requests

# ─────────────────────────────────────────────────────────────────
step "System Packages (apt/dnf/yum)"
# ─────────────────────────────────────────────────────────────────
SYS_PKGS="nmap nikto sslscan dnsrecon curl wget whois git openssl"

if command -v apt-get &>/dev/null; then
    info "Updating apt ..."
    sudo apt-get update -qq 2>/dev/null
    for pkg in $SYS_PKGS; do
        if command -v "$pkg" &>/dev/null; then
            ok "$pkg already installed"
        else
            info "apt install $pkg ..."
            sudo apt-get install -y -qq "$pkg" 2>/dev/null && ok "$pkg installed" || warn "$pkg apt failed"
        fi
    done
    # testssl.sh
    if ! command -v testssl.sh &>/dev/null; then
        info "Installing testssl.sh ..."
        sudo apt-get install -y -qq testssl.sh 2>/dev/null && ok "testssl.sh installed" || {
            wget -q https://testssl.sh/testssl.sh -O /usr/local/bin/testssl.sh 2>/dev/null && \
            chmod +x /usr/local/bin/testssl.sh && ok "testssl.sh installed from source" || \
            warn "testssl.sh not installed"
        }
    else
        ok "testssl.sh already installed"
    fi
    # whatweb
    if ! command -v whatweb &>/dev/null; then
        info "apt install whatweb ..."
        sudo apt-get install -y -qq whatweb 2>/dev/null && ok "whatweb installed" || warn "whatweb not in apt"
    else
        ok "whatweb already installed"
    fi
    # wapiti
    if ! command -v wapiti &>/dev/null; then
        info "pip install wapiti3 ..."
        pip3 install wapiti3 -q 2>/dev/null && ok "wapiti installed" || warn "wapiti install failed"
    else
        ok "wapiti already installed"
    fi
    # wafw00f
    if ! command -v wafw00f &>/dev/null; then
        info "pip install wafw00f ..."
        pip3 install wafw00f --break-system-packages -q 2>/dev/null || \
        pip3 install wafw00f -q 2>/dev/null && ok "wafw00f installed" || warn "wafw00f install failed"
    else
        ok "wafw00f already installed"
    fi

elif command -v dnf &>/dev/null; then
    for pkg in nmap curl wget whois git openssl; do
        command -v "$pkg" &>/dev/null && ok "$pkg installed" || \
        { sudo dnf install -y -q "$pkg" 2>/dev/null && ok "$pkg installed" || warn "$pkg dnf failed"; }
    done
elif command -v yum &>/dev/null; then
    for pkg in nmap curl wget whois git openssl; do
        command -v "$pkg" &>/dev/null && ok "$pkg installed" || \
        { sudo yum install -y -q "$pkg" 2>/dev/null && ok "$pkg installed" || warn "$pkg yum failed"; }
    done
fi

# ─────────────────────────────────────────────────────────────────
step "Go Language Runtime"
# ─────────────────────────────────────────────────────────────────
install_go() {
    local GO_VERSION="1.22.4"
    case "$OS-$ARCH" in
        Linux-x86_64)        GO_FILE="go${GO_VERSION}.linux-amd64.tar.gz" ;;
        Linux-aarch64|Linux-arm64) GO_FILE="go${GO_VERSION}.linux-arm64.tar.gz" ;;
        Linux-armv6l|Linux-armv7l) GO_FILE="go${GO_VERSION}.linux-armv6l.tar.gz" ;;
        Darwin-arm64)        GO_FILE="go${GO_VERSION}.darwin-arm64.tar.gz" ;;
        Darwin-x86_64)       GO_FILE="go${GO_VERSION}.darwin-amd64.tar.gz" ;;
        *)  warn "Unsupported OS/arch: $OS/$ARCH"; return 1 ;;
    esac
    local GO_URL="https://go.dev/dl/${GO_FILE}"
    local TMP="/tmp/go_dl_$$"
    mkdir -p "$TMP"
    info "Downloading Go ${GO_VERSION} ..."
    if command -v wget &>/dev/null; then
        wget -q --show-progress "$GO_URL" -O "$TMP/$GO_FILE"
    else
        curl -L --progress-bar "$GO_URL" -o "$TMP/$GO_FILE"
    fi
    if [ ! -s "$TMP/$GO_FILE" ]; then
        fail "Go download failed"; rm -rf "$TMP"; return 1
    fi
    info "Extracting Go ..."
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$TMP/$GO_FILE" && rm -rf "$TMP"
    export PATH="$PATH:/usr/local/go/bin"
    command -v go &>/dev/null && ok "Go installed -> $(go version)" || fail "Go install failed"
}

if command -v go &>/dev/null; then
    ok "Go already installed -> $(go version)"
else
    install_go
fi

# ─────────────────────────────────────────────────────────────────
step "Go PATH Setup"
# ─────────────────────────────────────────────────────────────────
export GOPATH="${GOPATH:-$GOPATH_DEFAULT}"
export PATH="$PATH:/usr/local/go/bin:$GOPATH/bin"
mkdir -p "$GOPATH/bin"

for RC in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    touch "$RC" 2>/dev/null || continue
    grep -q "/usr/local/go/bin" "$RC" 2>/dev/null || \
        echo 'export PATH=$PATH:/usr/local/go/bin' >> "$RC"
    grep -q "go/bin" "$RC" 2>/dev/null || \
        echo 'export PATH=$PATH:$HOME/go/bin' >> "$RC"
done
ok "PATH configured: /usr/local/go/bin  +  $GOPATH/bin"

# ─────────────────────────────────────────────────────────────────
step "Go Recon Tools"
# ─────────────────────────────────────────────────────────────────
install_go_tool() {
    local name="$1" pkg="$2" desc="$3"
    if command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ]; then
        ok "$name already installed"
        return 0
    fi
    if ! command -v go &>/dev/null; then
        warn "Go not available — skipping $name"
        return 1
    fi
    info "go install $name ($desc) ..."
    GOPATH="$GOPATH" go install "${pkg}@latest" 2>&1 | tail -3
    if command -v "$name" &>/dev/null || [ -f "$GOPATH/bin/$name" ]; then
        ok "$name installed -> $GOPATH/bin/$name"
    else
        warn "$name binary not found after install — check $GOPATH/bin"
    fi
}

install_go_tool "subfinder"   "github.com/projectdiscovery/subfinder/v2/cmd/subfinder"  "subdomain enum"
install_go_tool "httpx"       "github.com/projectdiscovery/httpx/cmd/httpx"             "live host probe"
install_go_tool "dnsx"        "github.com/projectdiscovery/dnsx/cmd/dnsx"               "DNS resolver"
install_go_tool "nuclei"      "github.com/projectdiscovery/nuclei/v3/cmd/nuclei"        "vuln templates"
install_go_tool "gau"         "github.com/lc/gau/v2/cmd/gau"                            "URL harvesting"
install_go_tool "waybackurls" "github.com/tomnomnom/waybackurls"                        "Wayback URLs"
install_go_tool "ffuf"        "github.com/ffuf/ffuf/v2"                                 "directory fuzzer"
install_go_tool "anew"        "github.com/tomnomnom/anew"                               "dedup lines"

# ─────────────────────────────────────────────────────────────────
step "Nuclei Templates"
# ─────────────────────────────────────────────────────────────────
if command -v nuclei &>/dev/null || [ -f "$GOPATH/bin/nuclei" ]; then
    info "Updating nuclei templates ..."
    "$GOPATH/bin/nuclei" -update-templates -silent 2>/dev/null && ok "nuclei templates updated" || \
    nuclei -update-templates -silent 2>/dev/null && ok "nuclei templates updated" || \
    warn "nuclei template update failed — run: nuclei -update-templates"
else
    warn "nuclei not installed — skipping template update"
fi

# ─────────────────────────────────────────────────────────────────
step "amass (OSINT)"
# ─────────────────────────────────────────────────────────────────
if command -v amass &>/dev/null; then
    ok "amass already installed"
elif command -v snap &>/dev/null; then
    info "snap install amass ..."; sudo snap install amass 2>/dev/null && ok "amass installed" || warn "snap failed"
elif command -v go &>/dev/null; then
    info "go install amass ..."; go install github.com/owasp-amass/amass/v4/...@latest 2>&1 | tail -2
    command -v amass &>/dev/null && ok "amass installed" || warn "amass go install failed"
else
    warn "amass not installed — DNS fallback will be used"
fi

# ─────────────────────────────────────────────────────────────────
step "Wordlists (SecLists)"
# ─────────────────────────────────────────────────────────────────
if [ ! -d /usr/share/seclists ]; then
    if command -v apt-get &>/dev/null; then
        info "Installing seclists via apt ..."
        sudo apt-get install -y -qq seclists 2>/dev/null && ok "seclists installed" || {
            info "Cloning SecLists from GitHub ..."
            sudo git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists 2>/dev/null \
            && ok "SecLists cloned to /usr/share/seclists" \
            || warn "SecLists clone failed — directory fuzzing may be limited"
        }
    else
        info "Cloning SecLists from GitHub ..."
        sudo git clone --depth 1 https://github.com/danielmiessler/SecLists /usr/share/seclists 2>/dev/null \
        && ok "SecLists cloned" || warn "SecLists clone failed"
    fi
else
    ok "SecLists already at /usr/share/seclists"
fi

# ─────────────────────────────────────────────────────────────────
step "Final Tool Status"
# ─────────────────────────────────────────────────────────────────
echo ""
echo -e "${CYAN}  ┌──────────────────────────────────────────────────────┐${NC}"
echo -e "${CYAN}  │              TOOL INSTALLATION SUMMARY               │${NC}"
echo -e "${CYAN}  └──────────────────────────────────────────────────────┘${NC}"
echo ""

ALL_TOOLS="go python3 subfinder amass httpx dnsx nuclei gau waybackurls ffuf nmap nikto whatweb sslscan testssl.sh wafw00f dnsrecon wapiti curl wget whois openssl"
MISSING=()

for t in $ALL_TOOLS; do
    if command -v "$t" &>/dev/null || [ -f "$GOPATH/bin/$t" ]; then
        echo -e "  ${GREEN}✔${NC}  $t"
    else
        echo -e "  ${YELLOW}✘${NC}  $t  (missing — fallback active)"
        MISSING+=("$t")
    fi
done

echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BOLD}${GREEN}  Installation complete!${NC}"
echo ""
echo -e "  Launch KAIROX:  ${CYAN}./kairox${NC}"
echo ""

if [ ${#MISSING[@]} -gt 0 ]; then
    echo -e "  ${YELLOW}Missing tools:${NC} ${MISSING[*]}"
    echo -e "  ${YELLOW}NOTE:${NC} KAIROX has built-in fallbacks — it will still run."
    echo -e "        To activate newly installed Go tools run:"
    echo -e "        ${CYAN}source ~/.bashrc && ./kairox${NC}"
fi
echo ""
