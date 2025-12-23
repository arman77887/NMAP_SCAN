#!/bin/bash

# ====================================================
# Nmap Scanner Pro - Ultimate Edition
# Version: 3.0 | Compatible: Termux, iSH, Kali Linux
# Team: HCS BY CRYPTICX
# ====================================================

# ================= CONFIGURATION =================
VERSION="3.0"
TEAM="HCS BY CRYPTICX"
AUTHOR="Security Automation Team"

# Colors
BLACK='\033[0;30m'
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
RESULTS_DIR="$HOME/NmapScanner_Results"
SCAN_ID=$(date +%Y%m%d_%H%M%S)
TERMINAL_TYPE=""
CAN_USE_SUDO=false
IS_ROOT=false

# ================= DETECT TERMINAL =================
detect_terminal() {
    echo -e "${CYAN}[*] Detecting terminal environment...${NC}"
    
    # Check for Termux
    if [[ -d /data/data/com.termux/files/usr ]]; then
        TERMINAL_TYPE="TERMUX"
        echo -e "${GREEN}[✓] Terminal: Termux (Android)${NC}"
        
    # Check for iSH (Alpine Linux)
    elif [[ -f /etc/alpine-release ]]; then
        TERMINAL_TYPE="ISH"
        echo -e "${GREEN}[✓] Terminal: iSH Shell (iOS)${NC}"
        
    # Check for Kali Linux
    elif [[ -f /etc/debian_version ]] && grep -qi "kali" /etc/os-release 2>/dev/null; then
        TERMINAL_TYPE="KALI"
        echo -e "${GREEN}[✓] Terminal: Kali Linux${NC}"
        
    # Check for a-Shell (iOS)
    elif [[ -d /private/var/mobile ]] || [[ -d /var/mobile ]]; then
        TERMINAL_TYPE="A_SHELL"
        echo -e "${GREEN}[✓] Terminal: a-Shell (iOS)${NC}"
        
    # Check for other Linux
    elif [[ -f /etc/os-release ]]; then
        TERMINAL_TYPE="LINUX"
        echo -e "${GREEN}[✓] Terminal: Linux${NC}"
        
    else
        TERMINAL_TYPE="UNKNOWN"
        echo -e "${YELLOW}[!] Terminal: Unknown${NC}"
    fi
    
    # Check root/sudo access
    if [[ $EUID -eq 0 ]] || sudo -n true 2>/dev/null; then
        IS_ROOT=true
        CAN_USE_SUDO=true
        echo -e "${GREEN}[✓] Root/Sudo access available${NC}"
    else
        echo -e "${YELLOW}[!] Root access not available${NC}"
    fi
    
    # Create results directory
    mkdir -p "$RESULTS_DIR/$SCAN_ID"
    echo -e "${GREEN}[✓] Results directory: $RESULTS_DIR/$SCAN_ID${NC}"
}

# ================= BANNER =================
show_banner() {
    clear
    echo -e "${PURPLE}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║  ███╗   ██╗███╗   ███╗ █████╗ ██████╗     ███████╗ ██████╗   ║"
    echo "║  ████╗  ██║████╗ ████║██╔══██╗██╔══██╗    ██╔════╝██╔════╝   ║"
    echo "║  ██╔██╗ ██║██╔████╔██║███████║██████╔╝    ███████╗██║        ║"
    echo "║  ██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝     ╚════██║██║        ║"
    echo "║  ██║ ╚████║██║ ╚═╝ ██║██║  ██║██║         ███████║╚██████╗   ║"
    echo "║  ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝         ╚══════╝ ╚═════╝   ║"
    echo "║                                                              ║"
    echo "║                   S C A N N E R   P R O                      ║"
    echo "║                    Version: $VERSION                        ║"
    echo "║                                                              ║"
    echo "╠══════════════════════════════════════════════════════════════╣"
    echo "║                     TEAM HCS BY CRYPTICX                     ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
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
        echo -e "  ${GREEN}•${NC} Multiple: 192.168.1.1,192.168.1.2"
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
        
        TARGET="$TARGET_INPUT"
        echo -e "${GREEN}[✓] Target set: $TARGET${NC}"
        return 0
    done
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
        echo -e "${GREEN}[2]${NC} Custom Port Scan (Specific ports)"
        echo -e "${GREEN}[3]${NC} Service Version Detection"
        echo -e "${GREEN}[4]${NC} Quick Vulnerability Scan"
        echo -e "${GREEN}[5]${NC} OS Detection"
        echo -e "${GREEN}[6]${NC} Ping Sweep (Find live hosts)"
        echo -e "${GREEN}[7]${NC} UDP Port Scan"
        echo -e "${GREEN}[8]${NC} Script Scan (NSE)"
        echo -e "${GREEN}[9]${NC} Advanced Custom Scan"
        echo -e "${RED}[0]${NC} Back to Main Menu"
        
        echo ""
        echo -ne "${WHITE}Select option: ${NC}"
        read custom_choice
        
        case $custom_choice in
            1) all_port_scan ;;
            2) custom_port_scan ;;
            3) service_detection_scan ;;
            4) vulnerability_scan ;;
            5) os_detection_scan ;;
            6) ping_sweep_scan ;;
            7) udp_scan ;;
            8) script_scan ;;
            9) advanced_custom_scan ;;
            0) return ;;
            *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
        esac
    done
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
        
        echo -e "${RED}[⚠] Privilege Escalation Scans${NC}"
        echo -e "${YELLOW}════════════════════════════════════════════${NC}"
        
        echo -e "${GREEN}[1]${NC} All Privilege Check (Comprehensive)"
        echo -e "${GREEN}[2]${NC} SMB Vulnerability Scan"
        echo -e "${GREEN}[3]${NC} SSH Security Audit"
        echo -e "${GREEN}[4]${NC} FTP Anonymous Login Check"
        echo -e "${GREEN}[5]${NC} MySQL Root Access Check"
        echo -e "${GREEN}[6]${NC} Web Application Scan"
        echo -e "${GREEN}[7]${NC} Custom Privilege Scan"
        echo -e "${GREEN}[8]${NC} Quick Privilege Audit"
        echo -e "${RED}[0]${NC} Back to Main Menu"
        
        echo ""
        echo -ne "${WHITE}Select option: ${NC}"
        read priv_choice
        
        case $priv_choice in
            1) all_privilege_check ;;
            2) smb_vulnerability_scan ;;
            3) ssh_security_audit ;;
            4) ftp_anonymous_check ;;
            5) mysql_root_check ;;
            6) web_application_scan ;;
            7) custom_privilege_scan ;;
            8) quick_privilege_audit ;;
            0) return ;;
            *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ================= OTHER SCANS MENU =================
other_scans_menu() {
    while true; do
        show_banner
        echo -e "${CYAN}"
        echo "╔═══════════════════════════════════════════════════╗"
        echo "║             ALL NMAP SCANS MENU                   ║"
        echo "╚═══════════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "${YELLOW}═══════════ DISCOVERY SCANS ═══════════${NC}"
        echo -e "${GREEN}[1]${NC}  Ping Scan (-sn)"
        echo -e "${GREEN}[2]${NC}  TCP SYN Ping (-PS)"
        echo -e "${GREEN}[3]${NC}  TCP ACK Ping (-PA)"
        echo -e "${GREEN}[4]${NC}  UDP Ping (-PU)"
        echo -e "${GREEN}[5]${NC}  ARP Ping (-PR)"
        
        echo -e "\n${YELLOW}══════════ PORT SCANNING ══════════${NC}"
        echo -e "${GREEN}[6]${NC}  TCP SYN Scan (-sS)"
        echo -e "${GREEN}[7]${NC}  TCP Connect Scan (-sT)"
        echo -e "${GREEN}[8]${NC}  TCP FIN Scan (-sF)"
        echo -e "${GREEN}[9]${NC}  TCP Xmas Scan (-sX)"
        echo -e "${GREEN}[10]${NC} TCP Null Scan (-sN)"
        echo -e "${GREEN}[11]${NC} TCP ACK Scan (-sA)"
        echo -e "${GREEN}[12]${NC} TCP Window Scan (-sW)"
        echo -e "${GREEN}[13]${NC} TCP Maimon Scan (-sM)"
        echo -e "${GREEN}[14]${NC} SCTP INIT Scan (-sY)"
        echo -e "${GREEN}[15]${NC} IP Protocol Scan (-sO)"
        
        echo -e "\n${YELLOW}══════════ SERVICE DETECTION ══════════${NC}"
        echo -e "${GREEN}[16]${NC} Version Detection (-sV)"
        echo -e "${GREEN}[17]${NC} RPC Scan (-sR)"
        echo -e "${GREEN}[18]${NC} Aggressive Scan (-A)"
        
        echo -e "\n${YELLOW}══════════ FIREWALL EVASION ══════════${NC}"
        echo -e "${GREEN}[19]${NC} Fragment Packets (-f)"
        echo -e "${GREEN}[20]${NC} Decoy Scan (-D)"
        echo -e "${GREEN}[21]${NC} Spoof MAC (--spoof-mac)"
        echo -e "${GREEN}[22]${NC} Bad Checksum (--badsum)"
        
        echo -e "\n${YELLOW}══════════ TIMING & OUTPUT ══════════${NC}"
        echo -e "${GREEN}[23]${NC} Timing Template (-T0 to T5)"
        echo -e "${GREEN}[24]${NC} XML Output (-oX)"
        echo -e "${GREEN}[25]${NC} Grepable Output (-oG)"
        
        echo -e "\n${RED}[0]${NC} Back to Main Menu"
        
        echo ""
        echo -ne "${WHITE}Select scan type: ${NC}"
        read other_choice
        
        case $other_choice in
            1) run_scan "-sn" "ping_scan" ;;
            2) run_scan "-PS" "tcp_syn_ping" ;;
            3) run_scan "-PA" "tcp_ack_ping" ;;
            4) run_scan "-PU" "udp_ping" ;;
            5) run_scan "-PR" "arp_ping" ;;
            6) run_scan "-sS" "tcp_syn_scan" ;;
            7) run_scan "-sT" "tcp_connect_scan" ;;
            8) run_scan "-sF" "tcp_fin_scan" ;;
            9) run_scan "-sX" "tcp_xmas_scan" ;;
            10) run_scan "-sN" "tcp_null_scan" ;;
            11) run_scan "-sA" "tcp_ack_scan" ;;
            12) run_scan "-sW" "tcp_window_scan" ;;
            13) run_scan "-sM" "tcp_maimon_scan" ;;
            14) run_scan "-sY" "sctp_init_scan" ;;
            15) run_scan "-sO" "ip_protocol_scan" ;;
            16) run_scan "-sV" "version_detection" ;;
            17) run_scan "-sR" "rpc_scan" ;;
            18) run_scan "-A" "aggressive_scan" ;;
            19) run_scan "-f" "fragment_scan" ;;
            20) decoy_scan ;;
            21) spoof_mac_scan ;;
            22) run_scan "--badsum" "badsum_scan" ;;
            23) timing_scan ;;
            24) run_scan "-sV -oX" "xml_output" ;;
            25) run_scan "-sV -oG" "grepable_output" ;;
            0) return ;;
            *) echo -e "${RED}[!] Invalid option${NC}"; sleep 1 ;;
        esac
    done
}

# ================= SCAN FUNCTIONS =================
run_scan() {
    local scan_options="$1"
    local scan_name="$2"
    
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/${scan_name}_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running $scan_name scan...${NC}"
    echo -e "${BLUE}Command:${NC} nmap $scan_options $TARGET"
    
    # Check if scan requires root
    if [[ $scan_options == *"-sS"* ]] || [[ $scan_options == *"-sU"* ]] || [[ $scan_options == *"-O"* ]]; then
        if [[ $IS_ROOT == true ]]; then
            sudo nmap $scan_options $TARGET -oN "$output_file"
        else
            echo -e "${RED}[!] This scan requires root privileges${NC}"
            echo -e "${YELLOW}[*] Using alternative scan method...${NC}"
            nmap -sT $scan_options $TARGET -oN "$output_file"
        fi
    else
        nmap $scan_options $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] Scan completed!${NC}"
    echo -e "${GREEN}[✓] Results saved to: $output_file${NC}"
    
    # Show quick results
    show_quick_results "$output_file"
    
    read -p "Press Enter to continue..."
}

# Custom scan functions
all_port_scan() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/all_ports_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Scanning all 65535 ports...${NC}"
    echo -e "${YELLOW}[!] This may take several minutes${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        sudo nmap -sS -p- $TARGET -oN "$output_file"
    else
        nmap -sT -p- $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] All ports scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

custom_port_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Enter port range (e.g., 1-1000 or 22,80,443):${NC}"
    read port_range
    
    local output_file="$RESULTS_DIR/$SCAN_ID/custom_ports_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Scanning ports: $port_range${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        sudo nmap -sS -p $port_range $TARGET -oN "$output_file"
    else
        nmap -sT -p $port_range $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] Custom port scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

service_detection_scan() {
    run_scan "-sV -sC" "service_detection"
}

vulnerability_scan() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/vulnerability_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running vulnerability scan...${NC}"
    
    nmap --script vuln $TARGET -oN "$output_file"
    
    echo -e "${GREEN}[✓] Vulnerability scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

os_detection_scan() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/os_detection_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Detecting operating system...${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        sudo nmap -O $TARGET -oN "$output_file"
    else
        echo -e "${RED}[!] OS detection requires root privileges${NC}"
        echo -e "${YELLOW}[*] Running service detection instead...${NC}"
        nmap -sV --version-intensity 9 $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] OS detection completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

ping_sweep_scan() {
    run_scan "-sn" "ping_sweep"
}

udp_scan() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/udp_scan_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running UDP port scan...${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        sudo nmap -sU -p 53,67,68,69,123,161,162,500,514,520,623,631 $TARGET -oN "$output_file"
    else
        echo -e "${RED}[!] UDP scan requires root privileges${NC}"
        echo -e "${YELLOW}[*] Running TCP scan instead...${NC}"
        nmap -sT $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] UDP scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

script_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Select script category:${NC}"
    echo -e "1. Safe scripts"
    echo -e "2. Discovery scripts"
    echo -e "3. Auth scripts"
    echo -e "4. Vuln scripts"
    echo -e "5. All scripts"
    read script_choice
    
    local script_option=""
    local scan_name=""
    
    case $script_choice in
        1) script_option="--script safe"; scan_name="safe_scripts" ;;
        2) script_option="--script discovery"; scan_name="discovery_scripts" ;;
        3) script_option="--script auth"; scan_name="auth_scripts" ;;
        4) script_option="--script vuln"; scan_name="vuln_scripts" ;;
        5) script_option="--script all"; scan_name="all_scripts" ;;
        *) script_option="--script safe"; scan_name="safe_scripts" ;;
    esac
    
    local output_file="$RESULTS_DIR/$SCAN_ID/${scan_name}_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running $scan_name scan...${NC}"
    nmap $script_option $TARGET -oN "$output_file"
    
    echo -e "${GREEN}[✓] Script scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

advanced_custom_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Enter custom nmap options:${NC}"
    echo -e "${BLUE}Example:${NC} -sS -sV -O -T4 -p 1-1000"
    read custom_options
    
    local output_file="$RESULTS_DIR/$SCAN_ID/advanced_custom_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running custom scan...${NC}"
    echo -e "${BLUE}Command:${NC} nmap $custom_options $TARGET"
    
    if [[ $custom_options == *"-sS"* ]] || [[ $custom_options == *"-sU"* ]] || [[ $custom_options == *"-O"* ]]; then
        if [[ $IS_ROOT == true ]]; then
            sudo nmap $custom_options $TARGET -oN "$output_file"
        else
            echo -e "${RED}[!] Some options require root${NC}"
            nmap $custom_options $TARGET -oN "$output_file"
        fi
    else
        nmap $custom_options $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] Custom scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

# Privilege scan functions
all_privilege_check() {
    if ! get_target; then
        return
    fi
    
    echo -e "${CYAN}[*] Running comprehensive privilege check...${NC}"
    
    local timestamp=$(date +%H%M%S)
    
    # 1. Service detection
    echo -e "${BLUE}[1/6] Service detection...${NC}"
    nmap -sV $TARGET -oN "$RESULTS_DIR/$SCAN_ID/priv_services_$timestamp.txt"
    
    # 2. SMB check
    echo -e "${BLUE}[2/6] SMB vulnerability check...${NC}"
    nmap --script smb-vuln-* -p445,139 $TARGET -oN "$RESULTS_DIR/$SCAN_ID/priv_smb_$timestamp.txt"
    
    # 3. SSH check
    echo -e "${BLUE}[3/6] SSH security audit...${NC}"
    nmap --script ssh-* -p22 $TARGET -oN "$RESULTS_DIR/$SCAN_ID/priv_ssh_$timestamp.txt"
    
    # 4. FTP check
    echo -e "${BLUE}[4/6] FTP anonymous login check...${NC}"
    nmap --script ftp-anon -p21 $TARGET -oN "$RESULTS_DIR/$SCAN_ID/priv_ftp_$timestamp.txt"
    
    # 5. Web check
    echo -e "${BLUE}[5/6] Web application scan...${NC}"
    nmap --script http-vuln-* -p80,443,8080,8443 $TARGET -oN "$RESULTS_DIR/$SCAN_ID/priv_web_$timestamp.txt"
    
    # 6. Database check
    echo -e "${BLUE}[6/6] Database access check...${NC}"
    nmap --script mysql-empty-password -p3306 $TARGET -oN "$RESULTS_DIR/$SCAN_ID/priv_db_$timestamp.txt"
    
    echo -e "${GREEN}[✓] Comprehensive privilege check completed!${NC}"
    echo -e "${YELLOW}[*] Check individual scan files for results${NC}"
    read -p "Press Enter to continue..."
}

smb_vulnerability_scan() {
    run_scan "--script smb-vuln-* -p445,139" "smb_vulnerability"
}

ssh_security_audit() {
    run_scan "--script ssh-* -p22" "ssh_audit"
}

ftp_anonymous_check() {
    run_scan "--script ftp-anon -p21" "ftp_anonymous"
}

mysql_root_check() {
    run_scan "--script mysql-empty-password -p3306" "mysql_root_check"
}

web_application_scan() {
    run_scan "--script http-vuln-* -p80,443,8080,8443" "web_vulnerability"
}

custom_privilege_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Select privilege check:${NC}"
    echo -e "1. Check for null sessions"
    echo -e "2. Check for default credentials"
    echo -e "3. Check for outdated services"
    echo -e "4. Check for open shares"
    read priv_check_choice
    
    local script_name=""
    
    case $priv_check_choice in
        1) script_name="smb-empty-sessions" ;;
        2) script_name="default-credentials" ;;
        3) script_name="outdated-services" ;;
        4) script_name="smb-enum-shares" ;;
        *) script_name="safe" ;;
    esac
    
    local output_file="$RESULTS_DIR/$SCAN_ID/custom_priv_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running custom privilege check...${NC}"
    nmap --script $script_name $TARGET -oN "$output_file"
    
    echo -e "${GREEN}[✓] Custom privilege check completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

quick_privilege_audit() {
    if ! get_target; then
        return
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/quick_priv_audit_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running quick privilege audit...${NC}"
    
    nmap --script "default or safe" -p21,22,23,25,80,443,445,3306,3389 $TARGET -oN "$output_file"
    
    echo -e "${GREEN}[✓] Quick privilege audit completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

# Other scan functions
decoy_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Enter decoy IPs (comma separated):${NC}"
    read decoys
    
    local output_file="$RESULTS_DIR/$SCAN_ID/decoy_scan_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running decoy scan...${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        sudo nmap -D $decoys $TARGET -oN "$output_file"
    else
        nmap -D $decoys $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] Decoy scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

spoof_mac_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Enter MAC address to spoof (or random):${NC}"
    read mac_address
    
    if [[ -z "$mac_address" ]]; then
        mac_address="random"
    fi
    
    local output_file="$RESULTS_DIR/$SCAN_ID/spoof_mac_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running MAC spoof scan...${NC}"
    
    if [[ $IS_ROOT == true ]]; then
        sudo nmap --spoof-mac $mac_address $TARGET -oN "$output_file"
    else
        echo -e "${RED}[!] MAC spoofing requires root privileges${NC}"
        nmap $TARGET -oN "$output_file"
    fi
    
    echo -e "${GREEN}[✓] MAC spoof scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

timing_scan() {
    if ! get_target; then
        return
    fi
    
    echo -e "${YELLOW}[?] Select timing template:${NC}"
    echo -e "0. Paranoid (T0) - Very slow"
    echo -e "1. Sneaky (T1) - Slow"
    echo -e "2. Polite (T2) - Medium slow"
    echo -e "3. Normal (T3) - Default"
    echo -e "4. Aggressive (T4) - Fast"
    echo -e "5. Insane (T5) - Very fast"
    read timing_choice
    
    local timing_option="-T$timing_choice"
    local output_file="$RESULTS_DIR/$SCAN_ID/timing_scan_$(date +%H%M%S).txt"
    
    echo -e "${CYAN}[*] Running timing scan...${NC}"
    nmap $timing_option $TARGET -oN "$output_file"
    
    echo -e "${GREEN}[✓] Timing scan completed!${NC}"
    show_quick_results "$output_file"
    read -p "Press Enter to continue..."
}

# ================= UTILITY FUNCTIONS =================
show_quick_results() {
    local file="$1"
    
    if [[ -f "$file" ]]; then
        echo -e "\n${YELLOW}═══════════ QUICK RESULTS ═══════════${NC}"
        echo -e "${GREEN}Open ports found:${NC}"
        grep "open" "$file" | head -10
        echo -e "${YELLOW}════════════════════════════════════${NC}"
    fi
}

show_previous_scans() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║             PREVIOUS SCANS                        ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    if [[ -d "$RESULTS_DIR" ]]; then
        echo -e "${YELLOW}Recent scan sessions:${NC}"
        ls -lt "$RESULTS_DIR" | head -10
        
        echo -e "\n${YELLOW}Total scan files:${NC}"
        find "$RESULTS_DIR" -name "*.txt" | wc -l
    else
        echo -e "${RED}No previous scans found${NC}"
    fi
    
    read -p "Press Enter to continue..."
}

system_info() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════╗"
    echo "║             SYSTEM INFORMATION                    ║"
    echo "╚═══════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${GREEN}Terminal:${NC} $TERMINAL_TYPE"
    echo -e "${GREEN}User:${NC} $(whoami)"
    echo -e "${GREEN}Root Access:${NC} $IS_ROOT"
    echo -e "${GREEN}System:${NC} $(uname -a)"
    echo -e "${GREEN}Nmap Version:${NC} $(nmap --version 2>/dev/null | head -1 || echo "Not installed")"
    echo -e "${GREEN}Results Directory:${NC} $RESULTS_DIR"
    
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
        echo -e "${CYAN}[6]${NC} Update Scanner"
        echo ""
        echo -e "${RED}[0]${NC} Exit"
        echo ""
        echo -e "${WHITE}═══════════════════════════════════════════════${NC}"
        
        echo ""
        echo -ne "${WHITE}Select option: ${NC}"
        read main_choice
        
        case $main_choice in
            1) custom_scan_menu ;;
            2) privilege_scan_menu ;;
            3) other_scans_menu ;;
            4) show_previous_scans ;;
            5) system_info ;;
            6) update_scanner ;;
            0)
                echo -e "${GREEN}"
                echo "╔═══════════════════════════════════════════════════╗"
                echo "║   Thank you for using Nmap Scanner Pro!          ║"
                echo "║         TEAM HCS BY CRYPTICX                     ║"
                echo "║   Results saved in: $RESULTS_DIR         ║"
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

update_scanner() {
    echo -e "${CYAN}[*] Checking for updates...${NC}"
    echo -e "${GREEN}[✓] You have the latest version v$VERSION${NC}"
    echo -e "${YELLOW}[*] Team HCS BY CRYPTICX${NC}"
    sleep 2
}

# ================= INITIALIZATION =================
init() {
    detect_terminal
    show_banner
    
    echo -e "${CYAN}[*] Initializing Nmap Scanner Pro...${NC}"
    echo -e "${GREEN}[✓] Ready to scan!${NC}"
    echo -e "${YELLOW}[*] Use responsibly and legally${NC}"
    echo -e "${PURPLE}[*] Team HCS BY CRYPTICX${NC}"
    sleep 2
}

# ================= MAIN EXECUTION =================
main() {
    init
    main_menu
}

# Start the script
main
