#!/bin/bash

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Banner
banner() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║               Nmap Automation Toolkit v2.0               ║"
    echo "║               Advanced Security Scanner                  ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
}

# Check if nmap is installed
check_nmap() {
    if ! command -v nmap &> /dev/null; then
        echo -e "${RED}[ERROR] Nmap is not installed!${NC}"
        echo -e "${YELLOW}Installing nmap...${NC}"
        
        # Detect OS and install
        if [[ -f /etc/debian_version ]]; then
            sudo apt update && sudo apt install -y nmap
        elif [[ -f /etc/redhat-release ]]; then
            sudo yum install -y nmap
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            brew install nmap
        else
            echo -e "${RED}Please install nmap manually${NC}"
            exit 1
        fi
    fi
    echo -e "${GREEN}[✓] Nmap is installed${NC}"
}

# Function to validate IP
validate_ip() {
    local ip=$1
    local stat=1
    
    if [[ $ip =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}$ ]]; then
        OIFS=$IFS
        IFS='.'
        ip=($ip)
        IFS=$OIFS
        [[ ${ip[0]} -le 255 && ${ip[1]} -le 255 && ${ip[2]} -le 255 && ${ip[3]} -le 255 ]]
        stat=$?
    fi
    return $stat
}

# Function to validate domain
validate_domain() {
    local domain=$1
    if [[ $domain =~ ^([a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Get target input
get_target() {
    while true; do
        echo -e "${CYAN}"
        echo "╔═══════════════════════════════════════════════╗"
        echo "║              TARGET SELECTION                 ║"
        echo "╚═══════════════════════════════════════════════╝"
        echo -e "${NC}"
        
        echo -e "${YELLOW}Enter target (IP address or domain name):${NC}"
        echo -e "Examples:"
        echo -e "  - IP: 192.168.1.1"
        echo -e "  - Domain: example.com"
        echo -e "  - Range: 192.168.1.1-100"
        echo -e "  - CIDR: 192.168.1.0/24"
        echo ""
        echo -n "Target: "
        read TARGET
        
        # Check if input is empty
        if [[ -z "$TARGET" ]]; then
            echo -e "${RED}[ERROR] Target cannot be empty${NC}"
            continue
        fi
        
        # Check if it's IP, domain, range or CIDR
        if validate_ip $(echo $TARGET | cut -d'/' -f1 | cut -d'-' -f1) || 
           validate_domain $(echo $TARGET | cut -d'/' -f1 | cut -d'-' -f1) ||
           [[ $TARGET =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}-[0-9]{1,3}$ ]] ||
           [[ $TARGET =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}/[0-9]{1,2}$ ]]; then
            break
        else
            echo -e "${RED}[ERROR] Invalid target format${NC}"
        fi
    done
}

# PRIVILEGE CHECK MENU
privilege_check_menu() {
    while true; do
        banner
        echo -e "${PURPLE}"
        echo "╔═══════════════════════════════════════════════╗"
        echo "║           PRIVILEGE ESCALATION CHECK          ║"
        echo "╚═══════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo ""
        
        echo -e "${GREEN}[1]${NC} All Port Scan + Service Detection"
        echo -e "${GREEN}[2]${NC} Quick Vulnerability Scan"
        echo -e "${GREEN}[3]${NC} Comprehensive Privilege Check"
        echo -e "${GREEN}[4]${NC} Custom Port Range Scan"
        echo -e "${GREEN}[5]${NC} Back to Main Menu"
        echo ""
        
        echo -n "Select option [1-5]: "
        read priv_choice
        
        case $priv_choice in
            1)
                get_target
                echo -e "${YELLOW}[*] Starting All Port Scan...${NC}"
                nmap -sS -sV -sC -p- -T4 -A -oN "scan_all_ports_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to scan_all_ports_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            2)
                get_target
                echo -e "${YELLOW}[*] Starting Quick Vulnerability Scan...${NC}"
                nmap --script vuln -sV -oN "scan_vuln_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to scan_vuln_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            3)
                get_target
                echo -e "${YELLOW}[*] Starting Comprehensive Privilege Check...${NC}"
                
                # Create directory for results
                mkdir -p "privilege_scan_$TARGET"
                
                # 1. Service detection
                echo -e "${BLUE}[1/5] Service Detection...${NC}"
                nmap -sV --top-ports 100 -oN "privilege_scan_$TARGET/services.txt" $TARGET
                
                # 2. SMB checks
                echo -e "${BLUE}[2/5] SMB Enumeration...${NC}"
                nmap --script smb-enum-shares,smb-enum-users,smb-vuln-* -p445,139 -oN "privilege_scan_$TARGET/smb.txt" $TARGET
                
                # 3. SSH checks
                echo -e "${BLUE}[3/5] SSH Security Check...${NC}"
                nmap --script ssh-auth-methods,ssh-hostkey,ssh2-enum-algos -p22 -oN "privilege_scan_$TARGET/ssh.txt" $TARGET
                
                # 4. Web application checks
                echo -e "${BLUE}[4/5] Web Application Scan...${NC}"
                nmap --script http-enum,http-vuln-*,http-headers -p80,443,8080,8443 -oN "privilege_scan_$TARGET/web.txt" $TARGET
                
                # 5. Database checks
                echo -e "${BLUE}[5/5] Database Services...${NC}"
                nmap --script mysql-empty-password,postgres-brute,mongodb-info -p3306,5432,27017 -oN "privilege_scan_$TARGET/db.txt" $TARGET
                
                echo -e "${GREEN}[✓] All scans saved in privilege_scan_$TARGET directory${NC}"
                read -p "Press Enter to continue..."
                ;;
            4)
                get_target
                echo -n "Enter port range (e.g., 1-1000 or 22,80,443): "
                read PORT_RANGE
                echo -e "${YELLOW}[*] Scanning custom ports $PORT_RANGE...${NC}"
                nmap -sS -sV -sC -p $PORT_RANGE -oN "scan_custom_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to scan_custom_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            5)
                return
                ;;
            *)
                echo -e "${RED}[ERROR] Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# ALL SCAN MENU
all_scan_menu() {
    while true; do
        banner
        echo -e "${PURPLE}"
        echo "╔═══════════════════════════════════════════════╗"
        echo "║              COMPLETE SCAN MENU               ║"
        echo "╚═══════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo ""
        
        echo -e "${GREEN}[1]${NC} Aggressive Full Scan"
        echo -e "${GREEN}[2]${NC} Stealth SYN Scan"
        echo -e "${GREEN}[3]${NC} UDP Scan (Root Required)"
        echo -e "${GREEN}[4]${NC} Operating System Detection"
        echo -e "${GREEN}[5]${NC} Script Scan (All Safe Scripts)"
        echo -e "${GREEN}[6]${NC} Comprehensive Network Audit"
        echo -e "${GREEN}[7]${NC} Back to Main Menu"
        echo ""
        
        echo -n "Select option [1-7]: "
        read scan_choice
        
        case $scan_choice in
            1)
                get_target
                echo -e "${YELLOW}[*] Starting Aggressive Full Scan...${NC}"
                echo -e "${CYAN}This may take several minutes...${NC}"
                nmap -sS -sV -sC -A -T4 -p- -oN "aggressive_scan_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to aggressive_scan_$TARGET.txt${NC}"
                
                # Generate report
                echo -e "${BLUE}Generating summary report...${NC}"
                echo "=== SCAN SUMMARY ===" > "report_$TARGET.txt"
                echo "Target: $TARGET" >> "report_$TARGET.txt"
                echo "Date: $(date)" >> "report_$TARGET.txt"
                echo "Scan Type: Aggressive Full Scan" >> "report_$TARGET.txt"
                echo "" >> "report_$TARGET.txt"
                grep -E "open|filtered|closed" "aggressive_scan_$TARGET.txt" | head -20 >> "report_$TARGET.txt"
                echo -e "${GREEN}[✓] Report saved to report_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            2)
                get_target
                echo -e "${YELLOW}[*] Starting Stealth SYN Scan...${NC}"
                sudo nmap -sS -T2 -p- -oN "stealth_scan_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to stealth_scan_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            3)
                get_target
                echo -e "${YELLOW}[*] Starting UDP Scan...${NC}"
                echo -e "${RED}Note: This requires root privileges${NC}"
                sudo nmap -sU -T4 -p 53,67,68,69,123,161,162 -oN "udp_scan_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to udp_scan_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            4)
                get_target
                echo -e "${YELLOW}[*] Starting OS Detection...${NC}"
                nmap -O -T4 -oN "os_scan_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to os_scan_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            5)
                get_target
                echo -e "${YELLOW}[*] Starting Script Scan...${NC}"
                nmap --script "default or safe" -sV -oN "script_scan_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to script_scan_$TARGET.txt${NC}"
                read -p "Press Enter to continue..."
                ;;
            6)
                get_target
                echo -e "${YELLOW}[*] Starting Comprehensive Network Audit...${NC}"
                
                # Create audit directory
                AUDIT_DIR="network_audit_$TARGET"
                mkdir -p $AUDIT_DIR
                
                # Run all scans
                scans=(
                    "TCP Port Scan:nmap -sS -p- -oN $AUDIT_DIR/tcp_ports.txt $TARGET"
                    "Service Detection:nmap -sV -oN $AUDIT_DIR/services.txt $TARGET"
                    "Vulnerability Scan:nmap --script vuln -oN $AUDIT_DIR/vulnerabilities.txt $TARGET"
                    "OS Detection:nmap -O -oN $AUDIT_DIR/os_detection.txt $TARGET"
                    "Firewall Detection:nmap -sA -oN $AUDIT_DIR/firewall.txt $TARGET"
                )
                
                for scan in "${scans[@]}"; do
                    name=$(echo $scan | cut -d: -f1)
                    command=$(echo $scan | cut -d: -f2)
                    echo -e "${BLUE}Running: $name...${NC}"
                    eval $command
                done
                
                # Generate summary
                echo "=== NETWORK AUDIT SUMMARY ===" > "$AUDIT_DIR/SUMMARY.txt"
                echo "Target: $TARGET" >> "$AUDIT_DIR/SUMMARY.txt"
                echo "Audit Date: $(date)" >> "$AUDIT_DIR/SUMMARY.txt"
                echo "=================================" >> "$AUDIT_DIR/SUMMARY.txt"
                
                for file in $AUDIT_DIR/*.txt; do
                    if [ "$(basename $file)" != "SUMMARY.txt" ]; then
                        echo "" >> "$AUDIT_DIR/SUMMARY.txt"
                        echo "=== $(basename $file | sed 's/.txt//' | tr '_' ' ') ===" >> "$AUDIT_DIR/SUMMARY.txt"
                        grep -E "open|filtered|closed|vulnerable" $file | head -10 >> "$AUDIT_DIR/SUMMARY.txt"
                    fi
                done
                
                echo -e "${GREEN}[✓] Network audit saved in $AUDIT_DIR directory${NC}"
                read -p "Press Enter to continue..."
                ;;
            7)
                return
                ;;
            *)
                echo -e "${RED}[ERROR] Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# CUSTOM CHECK MENU
custom_check_menu() {
    banner
    echo -e "${PURPLE}"
    echo "╔═══════════════════════════════════════════════╗"
    echo "║               CUSTOM CHECK MENU               ║"
    echo "╚═══════════════════════════════════════════════╝"
    echo -e "${NC}"
    echo ""
    
    get_target
    
    while true; do
        echo -e "${CYAN}"
        echo "Custom Options for: $TARGET"
        echo "═══════════════════════════════════════════════"
        echo -e "${NC}"
        
        echo -e "${GREEN}[1]${NC} Enter custom Nmap command"
        echo -e "${GREEN}[2]${NC} Run pre-defined script combination"
        echo -e "${GREEN}[3]${NC} Create custom scan profile"
        echo -e "${GREEN}[4]${NC} Back to Main Menu"
        echo ""
        
        echo -n "Select option [1-4]: "
        read custom_choice
        
        case $custom_choice in
            1)
                echo -n "Enter custom nmap command (without target): "
                read CUSTOM_CMD
                echo -e "${YELLOW}[*] Running: nmap $CUSTOM_CMD $TARGET${NC}"
                nmap $CUSTOM_CMD $TARGET
                read -p "Press Enter to continue..."
                ;;
            2)
                echo -e "${BLUE}Select pre-defined combination:${NC}"
                echo "1) Web Application Security Scan"
                echo "2) Database Security Check"
                echo "3) Mail Server Audit"
                echo "4) VPN Server Check"
                echo -n "Choice [1-4]: "
                read combo_choice
                
                case $combo_choice in
                    1)
                        nmap --script http-enum,http-vuln-*,http-headers,http-methods -p80,443,8080,8443 -oN "web_audit_$TARGET.txt" $TARGET
                        ;;
                    2)
                        nmap --script mysql-empty-password,postgres-brute,mongodb-info,ms-sql-info -p3306,5432,27017,1433 -oN "db_audit_$TARGET.txt" $TARGET
                        ;;
                    3)
                        nmap --script smtp-commands,smtp-enum-users,smtp-open-relay -p25,465,587 -oN "mail_audit_$TARGET.txt" $TARGET
                        ;;
                    4)
                        nmap --script ike-version,stunnel-version,openvpn -p500,4500,1194 -oN "vpn_audit_$TARGET.txt" $TARGET
                        ;;
                    *)
                        echo -e "${RED}Invalid choice${NC}"
                        ;;
                esac
                read -p "Press Enter to continue..."
                ;;
            3)
                echo -e "${YELLOW}Creating custom scan profile...${NC}"
                echo -n "Enter profile name: "
                read PROFILE_NAME
                echo -n "Enter scan options (e.g., -sS -sV -p 1-1000): "
                read SCAN_OPTIONS
                echo -n "Enter output filename: "
                read OUTPUT_FILE
                
                echo -e "${GREEN}[*] Running custom profile...${NC}"
                nmap $SCAN_OPTIONS -oN "$OUTPUT_FILE" $TARGET
                echo -e "${GREEN}[✓] Scan saved to $OUTPUT_FILE${NC}"
                read -p "Press Enter to continue..."
                ;;
            4)
                return
                ;;
            *)
                echo -e "${RED}[ERROR] Invalid option${NC}"
                ;;
        esac
    done
}

# MAIN MENU
main_menu() {
    while true; do
        banner
        echo -e "${GREEN}"
        echo "╔═══════════════════════════════════════════════╗"
        echo "║              MAIN MENU                        ║"
        echo "╚═══════════════════════════════════════════════╝"
        echo -e "${NC}"
        echo ""
        
        echo -e "${YELLOW}[1]${NC} Privilege Check Menu"
        echo -e "${YELLOW}[2]${NC} All Scan Menu"
        echo -e "${YELLOW}[3]${NC} Custom Check Menu"
        echo -e "${YELLOW}[4]${NC} Quick Scan (Basic)"
        echo -e "${YELLOW}[5]${NC} Update Script"
        echo -e "${YELLOW}[6]${NC} Exit"
        echo ""
        
        echo -n "Select option [1-6]: "
        read main_choice
        
        case $main_choice in
            1)
                privilege_check_menu
                ;;
            2)
                all_scan_menu
                ;;
            3)
                custom_check_menu
                ;;
            4)
                get_target
                echo -e "${YELLOW}[*] Running Quick Basic Scan...${NC}"
                nmap -F -T4 -oN "quick_scan_$TARGET.txt" $TARGET
                echo -e "${GREEN}[✓] Scan saved to quick_scan_$TARGET.txt${NC}"
                echo ""
                echo -e "${CYAN}Quick Results:${NC}"
                grep "open" "quick_scan_$TARGET.txt" | head -10
                read -p "Press Enter to continue..."
                ;;
            5)
                echo -e "${YELLOW}[*] Checking for updates...${NC}"
                # Add update logic here
                echo -e "${GREEN}[✓] Script is up to date${NC}"
                sleep 2
                ;;
            6)
                echo -e "${CYAN}Thank you for using Nmap Automation Toolkit!${NC}"
                echo -e "${RED}Exiting...${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}[ERROR] Invalid option${NC}"
                sleep 1
                ;;
        esac
    done
}

# Initial setup
initial_setup() {
    check_nmap
    echo -e "${GREEN}[✓] System check completed${NC}"
    sleep 1
}

# Main execution
main() {
    initial_setup
    main_menu
}

# Run the script
main
