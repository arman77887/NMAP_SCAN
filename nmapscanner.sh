#!/bin/bash

# ====================================================
# Nmap Scanner Pro - Multi-Terminal Fixed Version
# Version: 4.0 | Compatible: Termux, iSH, Kali Linux
# Team: HCS BY CRYPTICX
# ====================================================

# ================= CONFIGURATION =================
VERSION="4.0"
TEAM="HCS BY CRYPTICX"
AUTHOR="Security Automation Team"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m'

# Global Variables
TARGET=""
RESULTS_DIR=""
SCAN_ID=$(date +%Y%m%d_%H%M%S)
TERMINAL_TYPE=""
HAS_SUDO=false
IS_ROOT=false
NMAP_CMD="nmap"

# ================= DETECT & CONFIGURE =================
detect_and_configure() {
    echo -e "${CYAN}[*] Detecting terminal environment...${NC}"
    
    # Check for Termux
    if [[ -d /data/data/com.termux/files/usr ]]; then
        TERMINAL_TYPE="TERMUX"
        RESULTS_DIR="/sdcard/NmapScanner"
        HAS_SUDO=false
        IS_ROOT=false
        echo -e "${GREEN}[✓] Terminal: Termux (Android)${NC}"
        
    # Check for iSH (Alpine Linux)
    elif [[ -f /etc/alpine-release ]]; then
        TERMINAL_TYPE="ISH"
        RESULTS_DIR="$HOME/NmapScanner"
        
        # Check if sudo exists in iSH
        if command -v sudo &> /dev/null; then
            HAS_SUDO=true
        else
            HAS_SUDO=false
        fi
        
        # Check root in iSH
        if [[ $EUID -eq 0 ]]; then
            IS_ROOT=true
            NMAP_CMD="nmap"
        else
            IS_ROOT=false
            NMAP_CMD="nmap"
        fi
        echo -e "${GREEN}[✓] Terminal: iSH Shell (iOS)${NC}"
        
    # Check for Kali Linux
    elif [[ -f /etc/debian_version ]] && grep -qi "kali" /etc/os-release 2>/dev/null; then
        TERMINAL_TYPE="KALI"
        RESULTS_DIR="/var/log/nmap_scanner"
        HAS_SUDO=true
        IS_ROOT=false
        echo -e "${GREEN}[✓] Terminal: Kali Linux${NC}"
        
    # Check for a-Shell (iOS)
    elif [[ -d /private/var/mobile ]] || [[ -d /var/mobile ]]; then
        TERMINAL_TYPE="A_SHELL"
        RESULTS_DIR="$HOME/Documents/NmapScanner"
        HAS_SUDO=false
        IS_ROOT=false
        echo -e "${GREEN}[✓] Terminal: a-Shell (iOS)${NC}"
        
    # Check for other Linux
    elif [[ -f /etc/os-release ]]; then
        TERMINAL_TYPE="LINUX"
        RESULTS_DIR="$HOME/NmapScanner"
        
        if command -v sudo &> /dev/null; then
            HAS_SUDO=true
        fi
        
        if [[ $EUID -eq 0 ]]; then
            IS_ROOT=true
        fi
        echo -e "${GREEN}[✓] Terminal: Linux${NC}"
        
    else
        TERMINAL_TYPE="UNKNOWN"
        RESULTS_DIR="$HOME/NmapScanner"
        echo -e "${YELLOW}[!] Terminal: Unknown${NC}"
    fi
    
    # Install nmap if not found
    check_and_install_nmap
    
    # Create results directory
    mkdir -p "$RESULTS_DIR/$SCAN_ID"
    echo -e "${GREEN}[✓] Results directory: $RESULTS_DIR/$SCAN_ID${NC}"
    
    # Terminal specific warnings
    if [[ "$TERMINAL_TYPE" == "TERMUX" || "$TERMINAL_TYPE" == "A_SHELL" ]]; then
        echo -e "${YELLOW}[!] Note: Limited scan capabilities in $TERMINAL_TYPE${NC}"
        echo -e "${YELLOW}[!] Using TCP Connect scans instead of SYN scans${NC}"
    fi
}

check_and_install_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${YELLOW}[!] Nmap not found. Installing...${NC}"
        
        case $TERMINAL_TYPE in
            "TERMUX")
                pkg update -y && pkg install nmap -y
                ;;
            "ISH")
                apk update && apk add nmap
                ;;
            "KALI")
                apt update && apt install nmap -y
                ;;
            "A_SHELL")
                pkg install nmap
                ;;
            *)
                echo -e "${RED}[✗] Cannot auto-install nmap on this system${NC}"
                echo -e "${YELLOW}[!] Please install nmap manually${NC}"
                exit 1
                ;;
        esac
        
        if command -v nmap &> /dev/null; then
            echo -e "${GREEN}[✓] Nmap installed successfully${NC}"
        else
            echo -e "${RED}[✗] Failed to install nmap${NC}"
            exit 1
        fi
    else
        echo -e "${GREEN}[✓] Nmap is installed${NC}"
    fi
}

# ================= BANNER =================
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo "┃                                                      ┃"
    echo "┃  ███╗   ██╗███╗   ███╗ █████╗ ██████╗    ██████╗    ┃"
    echo "┃  ████╗  ██║████╗ ████║██╔══██╗██╔══██╗   ██╔══██╗   ┃"
    echo "┃  ██╔██╗ ██║██╔████╔██║███████║██████╔╝   ██████╔╝   ┃"
    echo "┃  ██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝    ██╔══██╗   ┃"
    echo "┃  ██║ ╚████║██║ ╚═╝ ██║██║  ██║██║        ██████╔╝   ┃"
    echo "┃  ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝        ╚═════╝    ┃"
    echo "┃                                                      ┃"
    echo "┃              S C A N N E R   P R O                  ┃"
    echo "┃               Version: $VERSION                    ┃"
    echo "┃                                                      ┃"
    echo "┠──────────────────────────────────────────────────────┨"
    echo "┃               TEAM HCS BY CRYPTICX                  ┃"
    echo "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛"
    echo -e "${NC}"
    
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    echo -e "${WHITE}Terminal: ${GREEN}$TERMINAL_TYPE${NC} | User: ${CYAN}$(whoami)${NC} | Date: $(date)"
    echo -e "${YELLOW}══════════════════════════════════════════════════════════════${NC}"
    echo ""
}

# ================= TARGET INPUT =================
get_target() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║               TARGET INPUT                        ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    while true; do
        echo -e "${YELLOW}[?] Enter target (IP/Domain/Range):${NC}"
        echo -e "${BLUE}Examples:${NC}"
        echo -e "  ${GREEN}•${NC} Single IP: 192.168.1.1"
        echo -e "  ${GREEN}•${NC} Domain: google.com"
        echo -e "  ${GREEN}•${NC} IP Range: 192.168.1.1-100"
        echo -e "  ${GREEN}•${NC} CIDR: 192.168.1.0/24"
        echo -e "  ${GREEN}•${NC} File: targets.txt"
        echo ""
        echo -ne "${WHITE}Target (or 'menu' to go back): ${NC}"
        read TARGET_INPUT
        
        if [[ "$TARGET_INPUT" == "menu" ]]; then
            return 1
        fi
        
        if [[ -z "$TARGET_INPUT" ]]; then
            echo -e "${RED}[!] Target cannot be empty${NC}"
            continue
        fi
        
        # Check if it's a file
        if [[ -f "$TARGET_INPUT" ]]; then
            TARGET="-iL $TARGET_INPUT"
            echo -e "${GREEN}[✓] Target file: $TARGET_INPUT${NC}"
        else
            TARGET="$TARGET_INPUT"
            echo -e "${GREEN}[✓] Target set: $TARGET${NC}"
        fi
        return 0
    done
}

# ================= SCAN EXECUTION =================
run_scan_safe() {
    local scan_options="$1"
    local scan_name="$2"
    
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/${scan_name}_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running $scan_name scan...${NC}"
    echo -e "${BLUE}Command:${NC} $NMAP_CMD $scan_options $TARGET"
    
    # Handle root-only scans
    local requires_root=false
    if [[ $scan_options == *"-sS"* ]] || 
       [[ $scan_options == *"-sU"* ]] || 
       [[ $scan_options == *"-O"* ]] ||
       [[ $scan_options == *"-A"* ]]; then
        requires_root=true
    fi
    
    if [[ $requires_root == true ]]; then
        if [[ $IS_ROOT == true ]]; then
            # Running as root
            $NMAP_CMD $scan_options $TARGET -oN "$output_file"
        elif [[ $HAS_SUDO == true ]]; then
            # Has sudo access
            sudo $NMAP_CMD $scan_options $TARGET -oN "$output_file"
        else
            # No root/sudo - use alternative
            echo -e "${YELLOW}[!] Root required for this scan. Using alternative...${NC}"
            
            # Replace SYN scan with Connect scan
            local safe_options=$(echo "$scan_options" | sed 's/-sS/-sT/g')
            
            # Remove OS detection
            safe_options=$(echo "$safe_options" | sed 's/-O//g')
            
            # Remove UDP scan
            safe_options=$(echo "$safe_options" | sed 's/-sU//g')
            
            # Remove aggressive
            safe_options=$(echo "$safe_options" | sed 's/-A//g')
            
            echo -e "${YELLOW}[*] Using: $NMAP_CMD $safe_options $TARGET${NC}"
            $NMAP_CMD $safe_options $TARGET -oN "$output_file"
        fi
    else
        # No root required
        $NMAP_CMD $scan_options $TARGET -oN "$output_file"
    fi
    
    # Check if scan succeeded
    if [[ $? -eq 0 ]] && [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] Scan completed successfully!${NC}"
        echo -e "${GREEN}[✓] Results saved to: $output_file${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed or produced no output${NC}"
        echo -e "${YELLOW}[!] Check your network connection and target${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

# ================= CUSTOM SCAN MENU =================
custom_scan_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}"
        echo "╔═══════════════════════════════════════════════════╗"
        echo "║               CUSTOM SCAN MENU                    ║"
        echo "╚═══════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "${GREEN}[1]${NC} All Port Scan (1-65535)"
        echo -e "${GREEN}[2]${NC} Custom Port Scan"
        echo -e "${GREEN}[3]${NC} Service Version Detection"
        echo -e "${GREEN}[4]${NC} Quick Vulnerability Scan"
        echo -e "${GREEN}[5]${NC} OS Detection (if available)"
        echo -e "${GREEN}[6]${NC} Ping Sweep"
        echo -e "${GREEN}[7]${NC} UDP Scan (if available)"
        echo -e "${GREEN}[8]${NC} Script Scan"
        echo -e "${GREEN}[9]${NC} Advanced Scan"
        echo -e "${RED}[0]${NC} Back to Main Menu"
        
        echo ""
        echo -ne "${WHITE}Select option: ${NC}"
        read custom_choice
        
        case $custom_choice in
            1) all_port_scan_safe ;;
            2) custom_port_scan_safe ;;
            3) service_detection_safe ;;
            4) vulnerability_scan_safe ;;
            5) os_detection_safe ;;
            6) run_scan_safe "-sn" "ping_sweep" ;;
            7) udp_scan_safe ;;
            8) script_scan_safe ;;
            9) advanced_scan_safe ;;
            0) return ;;
            *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# Fixed scan functions for Termux/iSH
all_port_scan_safe() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/all_ports_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Scanning all 65535 ports...${NC}"
    echo -e "${YELLOW}[!] This may take several minutes${NC}"
    
    # Use appropriate scan type based on terminal
    if [[ $TERMINAL_TYPE == "TERMUX" || $TERMINAL_TYPE == "A_SHELL" ]]; then
        # Termux/a-Shell: Use TCP Connect scan
        echo -e "${YELLOW}[*] Using TCP Connect scan (Termux/a-Shell mode)${NC}"
        $NMAP_CMD -sT -p- --max-retries 2 $TARGET -oN "$output_file"
    elif [[ $IS_ROOT == true || $HAS_SUDO == true ]]; then
        # Root available: Use SYN scan
        if [[ $HAS_SUDO == true ]]; then
            sudo $NMAP_CMD -sS -p- --max-retries 1 $TARGET -oN "$output_file"
        else
            $NMAP_CMD -sS -p- --max-retries 1 $TARGET -oN "$output_file"
        fi
    else
        # No root: Use TCP Connect scan
        echo -e "${YELLOW}[*] Using TCP Connect scan (no root)${NC}"
        $NMAP_CMD -sT -p- --max-retries 2 $TARGET -oN "$output_file"
    fi
    
    if [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] All ports scan completed!${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed${NC}"
    fi
    read -p "Press Enter to continue..."
}

custom_port_scan_safe() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Enter port range (e.g., 1-1000 or 22,80,443):${NC}"
    read port_range
    
    if [[ -z "$port_range" ]]; then
        echo -e "${RED}[!] Port range cannot be empty${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/custom_ports_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Scanning ports: $port_range${NC}"
    
    # Use appropriate scan type
    if [[ $TERMINAL_TYPE == "TERMUX" || $TERMINAL_TYPE == "A_SHELL" ]]; then
        $NMAP_CMD -sT -p $port_range $TARGET -oN "$output_file"
    elif [[ $IS_ROOT == true || $HAS_SUDO == true ]]; then
        if [[ $HAS_SUDO == true ]]; then
            sudo $NMAP_CMD -sS -p $port_range $TARGET -oN "$output_file"
        else
            $NMAP_CMD -sS -p $port_range $TARGET -oN "$output_file"
        fi
    else
        $NMAP_CMD -sT -p $port_range $TARGET -oN "$output_file"
    fi
    
    if [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] Custom port scan completed!${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed${NC}"
    fi
    read -p "Press Enter to continue..."
}

service_detection_safe() {
    run_scan_safe "-sV -sC" "service_detection"
}

vulnerability_scan_safe() {
    run_scan_safe "--script vuln" "vulnerability"
}

os_detection_safe() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/os_detection_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Attempting OS detection...${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        $NMAP_CMD -O $TARGET -oN "$output_file"
    elif [[ $HAS_SUDO == true ]]; then
        sudo $NMAP_CMD -O $TARGET -oN "$output_file"
    else
        echo -e "${YELLOW}[!] OS detection requires root privileges${NC}"
        echo -e "${YELLOW}[*] Running TCP/IP fingerprinting instead...${NC}"
        $NMAP_CMD -sV --version-intensity 9 $TARGET -oN "$output_file"
    fi
    
    if [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] OS detection completed!${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed${NC}"
    fi
    read -p "Press Enter to continue..."
}

udp_scan_safe() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/udp_scan_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Attempting UDP scan...${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        $NMAP_CMD -sU -p53,67,68,69,123,161 $TARGET -oN "$output_file"
    elif [[ $HAS_SUDO == true ]]; then
        sudo $NMAP_CMD -sU -p53,67,68,69,123,161 $TARGET -oN "$output_file"
    else
        echo -e "${RED}[✗] UDP scan requires root privileges${NC}"
        echo -e "${YELLOW}[*] Running TCP scan on common ports instead...${NC}"
        $NMAP_CMD -sT -p21,22,23,25,53,80,110,143,443,445,993,995 $TARGET -oN "$output_file"
    fi
    
    if [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] UDP scan completed!${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed${NC}"
    fi
    read -p "Press Enter to continue..."
}

script_scan_safe() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Select script category:${NC}"
    echo -e "1. Safe scripts"
    echo -e "2. Discovery scripts"
    echo -e "3. Vulnerability scripts"
    echo -e "4. All scripts (caution)"
    read script_choice
    
    local script_option=""
    
    case $script_choice in
        1) script_option="--script safe" ;;
        2) script_option="--script discovery" ;;
        3) script_option="--script vuln" ;;
        4) script_option="--script all" ;;
        *) script_option="--script safe" ;;
    esac
    
    local output_file="$RESULTS_DIR/$SCAN_ID/script_scan_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running script scan...${NC}"
    $NMAP_CMD $script_option $TARGET -oN "$output_file"
    
    if [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] Script scan completed!${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed${NC}"
    fi
    read -p "Press Enter to continue..."
}

advanced_scan_safe() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Enter custom nmap options:${NC}"
    echo -e "${BLUE}Examples:${NC}"
    echo -e "  ${GREEN}•${NC} -sS -sV -O -T4"
    echo -e "  ${GREEN}•${NC} -sT -p 1-1000 --open"
    echo -e "  ${GREEN}•${NC} -A -T5"
    echo ""
    echo -ne "${WHITE}Options: ${NC}"
    read custom_options
    
    if [[ -z "$custom_options" ]]; then
        echo -e "${RED}[!] Options cannot be empty${NC}"
        read -p "Press Enter to continue..."
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/advanced_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running custom scan...${NC}"
    echo -e "${BLUE}Command:${NC} $NMAP_CMD $custom_options $TARGET"
    
    # Check if scan requires root
    if [[ $custom_options == *"-sS"* ]] || 
       [[ $custom_options == *"-sU"* ]] || 
       [[ $custom_options == *"-O"* ]] ||
       [[ $custom_options == *"-A"* ]]; then
        
        if [[ $IS_ROOT == true ]]; then
            $NMAP_CMD $custom_options $TARGET -oN "$output_file"
        elif [[ $HAS_SUDO == true ]]; then
            sudo $NMAP_CMD $custom_options $TARGET -oN "$output_file"
        else
            echo -e "${YELLOW}[!] Some options require root. Adjusting...${NC}"
            local safe_options=$(echo "$custom_options" | sed 's/-sS/-sT/g;s/-sU//g;s/-O//g;s/-A//g')
            echo -e "${YELLOW}[*] Using: $NMAP_CMD $safe_options $TARGET${NC}"
            $NMAP_CMD $safe_options $TARGET -oN "$output_file"
        fi
    else
        $NMAP_CMD $custom_options $TARGET -oN "$output_file"
    fi
    
    if [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] Custom scan completed!${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed${NC}"
    fi
    read -p "Press Enter to continue..."
}

# ================= PRIVILEGE SCAN MENU =================
privilege_scan_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}"
        echo "╔═══════════════════════════════════════════════════╗"
        echo "║             PRIVILEGE SCAN MENU                   ║"
        echo "╚═══════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "${RED}[⚠] Privilege & Vulnerability Scans${NC}"
        echo -e "${YELLOW}════════════════════════════════════════════${NC}"
        
        echo -e "${GREEN}[1]${NC} Comprehensive Security Audit"
        echo -e "${GREEN}[2]${NC} SMB Vulnerability Check"
        echo -e "${GREEN}[3]${NC} SSH Security Audit"
        echo -e "${GREEN}[4]${NC} FTP Security Check"
        echo -e "${GREEN}[5]${NC} Web Application Scan"
        echo -e "${GREEN}[6]${NC} Database Security Check"
        echo -e "${GREEN}[7]${NC} Quick Security Audit"
        echo -e "${GREEN}[8]${NC} Custom Security Scan"
        echo -e "${RED}[0]${NC} Back to Main Menu"
        
        echo ""
        echo -ne "${WHITE}Select option: ${NC}"
        read priv_choice
        
        case $priv_choice in
            1) comprehensive_audit ;;
            2) run_scan_safe "--script smb-vuln-* -p445,139" "smb_vuln" ;;
            3) run_scan_safe "--script ssh-* -p22" "ssh_audit" ;;
            4) run_scan_safe "--script ftp-* -p21" "ftp_audit" ;;
            5) run_scan_safe "--script http-vuln-* -p80,443,8080" "web_vuln" ;;
            6) run_scan_safe "--script mysql-*,postgres-* -p3306,5432" "db_audit" ;;
            7) quick_security_audit ;;
            8) custom_security_scan ;;
            0) return ;;
            *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

comprehensive_audit() {
    if ! get_target; then
        return
    fi
    
    echo -e "${CYAN}[*] Starting comprehensive security audit...${NC}"
    
    local timestamp=$(date +%H%M%S)
    local base_file="$RESULTS_DIR/$SCAN_ID/audit_$timestamp"
    
    # 1. Basic scan
    echo -e "${BLUE}[1/6] Basic port scan...${NC}"
    $NMAP_CMD -sT -p- --max-retries 1 $TARGET -oN "${base_file}_ports.txt"
    
    # 2. Service detection
    echo -e "${BLUE}[2/6] Service detection...${NC}"
    $NMAP_CMD -sV -sC --top-ports 100 $TARGET -oN "${base_file}_services.txt"
    
    # 3. Vulnerability scan
    echo -e "${BLUE}[3/6] Vulnerability scan...${NC}"
    $NMAP_CMD --script vuln $TARGET -oN "${base_file}_vuln.txt"
    
    # 4. SMB check
    echo -e "${BLUE}[4/6] SMB security check...${NC}"
    $NMAP_CMD --script smb-vuln-*,smb-enum-shares -p445,139 $TARGET -oN "${base_file}_smb.txt"
    
    # 5. Web check
    echo -e "${BLUE}[5/6] Web security check...${NC}"
    $NMAP_CMD --script http-vuln-*,http-headers -p80,443,8080 $TARGET -oN "${base_file}_web.txt"
    
    # 6. Summary
    echo -e "${BLUE}[6/6] Generating summary...${NC}"
    generate_audit_summary "$base_file"
    
    echo -e "${GREEN}[✓] Comprehensive audit completed!${NC}"
    echo -e "${YELLOW}[*] Check individual scan files for detailed results${NC}"
    read -p "Press Enter to continue..."
}

quick_security_audit() {
    run_scan_safe "--script safe -p21,22,23,25,53,80,110,143,443,445,993,995" "quick_audit"
}

custom_security_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Select security check type:${NC}"
    echo -e "1. Check default credentials"
    echo -e "2. Check outdated services"
    echo -e "3. Check open shares"
    echo -e "4. Check SSL/TLS vulnerabilities"
    echo -e "5. Check DNS vulnerabilities"
    read security_choice
    
    local script_name=""
    
    case $security_choice in
        1) script_name="default-credentials" ;;
        2) script_name="outdated-services" ;;
        3) script_name="smb-enum-shares" ;;
        4) script_name="ssl-*" ;;
        5) script_name="dns-*" ;;
        *) script_name="safe" ;;
    esac
    
    local output_file="$RESULTS_DIR/$SCAN_ID/security_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running security scan...${NC}"
    $NMAP_CMD --script $script_name $TARGET -oN "$output_file"
    
    if [[ -f "$output_file" ]]; then
        echo -e "${GREEN}[✓] Security scan completed!${NC}"
        show_quick_results "$output_file"
    else
        echo -e "${RED}[✗] Scan failed${NC}"
    fi
    read -p "Press Enter to continue..."
}

generate_audit_summary() {
    local base_file="$1"
    local summary_file="${base_file}_SUMMARY.txt"
    
    cat > "$summary_file" << EOF
=============================================
SECURITY AUDIT SUMMARY
=============================================
Target: $TARGET
Date: $(date)
Terminal: $TERMINAL_TYPE
=============================================

SCAN RESULTS:
-------------
EOF

    # Collect findings from all scan files
    for scan_file in "${base_file}"_*.txt; do
        if [[ -f "$scan_file" ]]; then
            echo "" >> "$summary_file"
            echo "=== $(basename "$scan_file" | sed 's/.*audit_//' | sed 's/\.txt//') ===" >> "$summary_file"
            grep -E "(open|VULNERABLE|CRITICAL|WARNING)" "$scan_file" | head -5 >> "$summary_file"
        fi
    done

    echo -e "${GREEN}[✓] Audit summary saved: $summary_file${NC}"
}

# ================= ALL SCANS MENU =================
all_scans_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}"
        echo "╔═══════════════════════════════════════════════════╗"
        echo "║             ALL NMAP SCANS MENU                   ║"
        echo "╚═══════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "${YELLOW}═══════════ DISCOVERY SCANS ═══════════${NC}"
        echo -e "${GREEN}[1]${NC}  Ping Sweep (-sn)"
        echo -e "${GREEN}[2]${NC}  ARP Discovery (-PR)"
        
        echo -e "\n${YELLOW}══════════ PORT SCANNING ══════════${NC}"
        echo -e "${GREEN}[3]${NC}  TCP SYN Scan (-sS)"
        echo -e "${GREEN}[4]${NC}  TCP Connect Scan (-sT)"
        echo -e "${GREEN}[5]${NC}  TCP FIN Scan (-sF)"
        echo -e "${GREEN}[6]${NC}  TCP Xmas Scan (-sX)"
        echo -e "${GREEN}[7]${NC}  TCP Null Scan (-sN)"
        
        echo -e "\n${YELLOW}══════════ SERVICE SCANS ══════════${NC}"
        echo -e "${GREEN}[8]${NC}  Version Detection (-sV)"
        echo -e "${GREEN}[9]${NC}  Script Scan (-sC)"
        echo -e "${GREEN}[10]${NC} Aggressive Scan (-A)"
        
        echo -e "\n${YELLOW}══════════ OUTPUT FORMATS ══════════${NC}"
        echo -e "${GREEN}[11]${NC} Normal Output (-oN)"
        echo -e "${GREEN}[12]${NC} XML Output (-oX)"
        echo -e "${GREEN}[13]${NC} Grepable Output (-oG)"
        
        echo -e "\n${YELLOW}══════════ TIMING OPTIONS ══════════${NC}"
        echo -e "${GREEN}[14]${NC} Fast Scan (-T4)"
        echo -e "${GREEN}[15]${NC} Slow Scan (-T2)"
        
        echo -e "\n${RED}[0]${NC} Back to Main Menu"
        
        echo ""
        echo -ne "${WHITE}Select scan type: ${NC}"
        read all_choice
        
        case $all_choice in
            1) run_scan_safe "-sn" "ping_sweep" ;;
            2) run_scan_safe "-PR" "arp_discovery" ;;
            3) run_scan_safe "-sS" "tcp_syn" ;;
            4) run_scan_safe "-sT" "tcp_connect" ;;
            5) run_scan_safe "-sF" "tcp_fin" ;;
            6) run_scan_safe "-sX" "tcp_xmas" ;;
            7) run_scan_safe "-sN" "tcp_null" ;;
            8) run_scan_safe "-sV" "version_detect" ;;
            9) run_scan_safe "-sC" "script_scan" ;;
            10) run_scan_safe "-A" "aggressive" ;;
            11) run_scan_safe "-sT -oN" "normal_output" ;;
            12) run_scan_safe "-sT -oX" "xml_output" ;;
            13) run_scan_safe "-sT -oG" "grepable_output" ;;
            14) run_scan_safe "-T4" "fast_scan" ;;
            15) run_scan_safe "-T2" "slow_scan" ;;
            0) return ;;
            *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ================= UTILITY FUNCTIONS =================
show_quick_results() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        echo -e "\n${YELLOW}═══════════ QUICK RESULTS ═══════════${NC}"
        
        # Count open ports
        local open_ports=$(grep -c "open" "$file" 2>/dev/null || echo "0")
        echo -e "${GREEN}Open ports found:${NC} $open_ports"
        
        # Show first few open ports
        if [[ $open_ports -gt 0 ]]; then
            echo -e "${GREEN}Top open ports:${NC}"
            grep "open" "$file" | head -5 | while read line; do
                echo "  • $line"
            done
        fi
        
        # Check for vulnerabilities
        if grep -qi "vulnerable\|VULNERABLE" "$file"; then
            echo -e "${RED}⚠ Vulnerabilities found!${NC}"
        fi
        
        echo -e "${YELLOW}════════════════════════════════════${NC}"
    else
        echo -e "${RED}[✗] No results file found${NC}"
    fi
}

view_previous_scans() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║             PREVIOUS SCANS                        ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [[ -d "$RESULTS_DIR" ]]; then
        echo -e "${YELLOW}Recent scan sessions:${NC}"
        ls -lt "$RESULTS_DIR" | head -10 | awk '{print $6,$7,$8,$9}'
        
        echo -e "\n${YELLOW}Total scan files:${NC}"
        find "$RESULTS_DIR" -name "*.txt" -type f | wc -l
        
        echo -e "\n${YELLOW}Disk usage:${NC}"
        du -sh "$RESULTS_DIR" 2>/dev/null || echo "Cannot calculate"
    else
        echo -e "${RED}No scan results found${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

system_information() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║             SYSTEM INFORMATION                    ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}Terminal Type:${NC} $TERMINAL_TYPE"
    echo -e "${GREEN}Username:${NC} $(whoami)"
    echo -e "${GREEN}Root Access:${NC} $IS_ROOT"
    echo -e "${GREEN}Sudo Available:${NC} $HAS_SUDO"
    echo -e "${GREEN}System Info:${NC} $(uname -s -r)"
    
    echo -e "\n${GREEN}Nmap Information:${NC}"
    nmap --version 2>/dev/null | head -3 || echo "Nmap not found"
    
    echo -e "\n${GREEN}Results Directory:${NC} $RESULTS_DIR"
    echo -e "${GREEN}Current Scan ID:${NC} $SCAN_ID"
    
    echo -e "\n${YELLOW}════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}TEAM HCS BY CRYPTICX${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════${NC}"
    
    read -p "Press Enter to continue..."
}

# ================= MAIN MENU =================
main_menu() {
    while true; do
        show_banner
        
        echo -e "${WHITE}══════════════════ MAIN MENU ══════════════════${NC}"
        echo ""
        echo -e "${GREEN}[1]${NC} Custom Scan Menu"
        echo -e "${GREEN}[2]${NC} Privilege Scan Menu"
        echo -e "${GREEN}[3]${NC} All Nmap Scans Menu"
        echo ""
        echo -e "${CYAN}[4]${NC} View Previous Scans"
        echo -e "${CYAN}[5]${NC} System Information"
        echo -e "${CYAN}[6]${NC} Help & About"
        echo ""
        echo -e "${RED}[0]${NC} Exit Scanner"
        echo ""
        echo -e "${WHITE}═══════════════════════════════════════════════${NC}"
        
        echo ""
        echo -ne "${WHITE}Select option: ${NC}"
        read main_choice
        
        case $main_choice in
            1) custom_scan_menu ;;
            2) privilege_scan_menu ;;
            3) all_scans_menu ;;
            4) view_previous_scans ;;
            5) system_information ;;
            6) show_help ;;
            0)
                echo -e "${GREEN}"
                echo "╔═══════════════════════════════════════════════════╗"
                echo "║                                                   ║"
                echo "║      Thank you for using Nmap Scanner Pro!       ║"
                echo "║                                                   ║"
                echo "║            TEAM HCS BY CRYPTICX                  ║"
                echo "║                                                   ║"
                echo "║   Scan results saved in: $RESULTS_DIR   ║"
                echo "║                                                   ║"
                echo "╚═══════════════════════════════════════════════════╝"
                echo -e "${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[!] Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

show_help() {
    clear
    show_banner
    
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║               HELP & INFORMATION                  ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${YELLOW}Usage Guide:${NC}"
    echo -e "${GREEN}1.${NC} Select a menu option"
    echo -e "${GREEN}2.${NC} Enter target IP/domain when prompted"
    echo -e "${GREEN}3.${NC} Scanner will automatically run the scan"
    echo -e "${GREEN}4.${NC} Results are saved automatically"
    echo -e "${GREEN}5.${NC} View quick results on screen"
    
    echo -e "\n${YELLOW}Terminal Compatibility:${NC}"
    echo -e "${GREEN}•${NC} Termux: Full support (TCP scans)"
    echo -e "${GREEN}•${NC} iSH Shell: Full support (may need root)"
    echo -e "${GREEN}•${NC} Kali Linux: Full support"
    echo -e "${GREEN}•${NC} a-Shell: Basic support"
    
    echo -e "\n${YELLOW}Important Notes:${NC}"
    echo -e "${RED}•${NC} Always scan authorized targets only"
    echo -e "${RED}•${NC} Some scans require root privileges"
    echo -e "${RED}•${NC} Results are saved in: $RESULTS_DIR"
    
    echo -e "\n${YELLOW}════════════════════════════════════════════${NC}"
    echo -e "${PURPLE}TEAM HCS BY CRYPTICX | Version: $VERSION${NC}"
    echo -e "${YELLOW}════════════════════════════════════════════${NC}"
    
    read -p "Press Enter to continue..."
}

# ================= MAIN EXECUTION =================
main() {
    detect_and_configure
    main_menu
}

# Start the script
main
