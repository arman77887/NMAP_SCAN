#!/bin/bash

# ====================================================
# AUTO-NMAP - Fully Automatic Nmap Scanner
# Version: 5.0 | Auto-Detect & Auto-Scan
# ====================================================

# ================= AUTO CONFIGURATION =================
auto_detect_and_configure() {
    echo -e "${CYAN}[*] AUTO-CONFIG: Detecting system...${NC}"
    sleep 1
    
    # Detect OS/Terminal
    if [[ -d /data/data/com.termux/files/usr ]]; then
        SYSTEM="TERMUX"
        echo -e "${GREEN}[✓] Detected: Termux (Android)${NC}"
        
    elif [[ -f /etc/alpine-release ]]; then
        SYSTEM="ISH"
        echo -e "${GREEN}[✓] Detected: iSH Shell (iOS)${NC}"
        
    elif [[ -f /etc/debian_version ]]; then
        if grep -qi "kali" /etc/os-release 2>/dev/null; then
            SYSTEM="KALI"
            echo -e "${GREEN}[✓] Detected: Kali Linux${NC}"
        else
            SYSTEM="DEBIAN"
            echo -e "${GREEN}[✓] Detected: Debian/Ubuntu${NC}"
        fi
        
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        SYSTEM="MACOS"
        echo -e "${GREEN}[✓] Detected: macOS${NC}"
        
    elif [[ -d /private/var/mobile ]] || [[ -d /var/mobile ]]; then
        SYSTEM="A_SHELL"
        echo -e "${GREEN}[✓] Detected: a-Shell (iOS)${NC}"
        
    else
        SYSTEM="UNKNOWN"
        echo -e "${YELLOW}[!] Detected: Unknown Linux${NC}"
    fi
    
    # Auto-configure paths
    configure_paths
    # Auto-install dependencies
    auto_install_deps
    # Auto-set scan profile
    set_auto_profile
}

configure_paths() {
    case $SYSTEM in
        "TERMUX")
            NMAP_CMD="nmap"
            RESULTS="/sdcard/AutoNmap"
            LOG_FILE="/sdcard/AutoNmap/scan.log"
            ;;
        "ISH")
            NMAP_CMD="nmap"
            RESULTS="$HOME/AutoNmap"
            LOG_FILE="$HOME/AutoNmap/scan.log"
            ;;
        "KALI"|"DEBIAN")
            NMAP_CMD="sudo nmap"
            RESULTS="/var/log/autonmap"
            LOG_FILE="/var/log/autonmap/scan.log"
            ;;
        "MACOS")
            NMAP_CMD="nmap"
            RESULTS="$HOME/AutoNmap"
            LOG_FILE="$HOME/AutoNmap/scan.log"
            ;;
        "A_SHELL")
            NMAP_CMD="nmap"
            RESULTS="$HOME/Documents/AutoNmap"
            LOG_FILE="$HOME/Documents/AutoNmap/scan.log"
            ;;
        *)
            NMAP_CMD="nmap"
            RESULTS="$HOME/AutoNmap"
            LOG_FILE="$HOME/AutoNmap/scan.log"
            ;;
    esac
    
    mkdir -p "$RESULTS"
    echo -e "${GREEN}[✓] Results directory: $RESULTS${NC}"
}

auto_install_deps() {
    echo -e "${CYAN}[*] AUTO-CONFIG: Checking dependencies...${NC}"
    
    # Check if nmap is installed
    if ! command -v nmap &> /dev/null; then
        echo -e "${YELLOW}[!] Nmap not found. Auto-installing...${NC}"
        
        case $SYSTEM in
            "TERMUX")
                pkg update -y && pkg install nmap -y
                ;;
            "ISH")
                apk update && apk add nmap
                ;;
            "KALI"|"DEBIAN")
                sudo apt update && sudo apt install nmap -y
                ;;
            "MACOS")
                brew update && brew install nmap
                ;;
            "A_SHELL")
                pkg install nmap
                ;;
            *)
                echo -e "${RED}[✗] Cannot auto-install on this system${NC}"
                echo -e "${YELLOW}[!] Please install nmap manually${NC}"
                ;;
        esac
    else
        echo -e "${GREEN}[✓] Nmap is installed${NC}"
    fi
    
    # Install additional tools based on system
    install_additional_tools
}

install_additional_tools() {
    case $SYSTEM in
        "KALI")
            echo -e "${CYAN}[*] Installing Kali extras...${NC}"
            sudo apt install -y nikto sqlmap gobuster dirb wpscan
            ;;
        "TERMUX")
            echo -e "${CYAN}[*] Installing Termux extras...${NC}"
            pkg install -y curl wget python python-pip
            pip install requests
            ;;
        "ISH")
            echo -e "${CYAN}[*] Installing iSH extras...${NC}"
            apk add curl wget python3
            ;;
    esac
}

set_auto_profile() {
    echo -e "${CYAN}[*] AUTO-CONFIG: Setting optimal scan profile...${NC}"
    
    case $SYSTEM in
        "TERMUX"|"A_SHELL")
            # Limited systems - use connect scans
            SCAN_TYPE="-sT"
            TIMING="-T4"
            PORTS="--top-ports 100"
            ;;
        "ISH")
            # iSH with possible root
            if [[ $EUID -eq 0 ]]; then
                SCAN_TYPE="-sS"
                TIMING="-T4"
                PORTS="--top-ports 1000"
            else
                SCAN_TYPE="-sT"
                TIMING="-T4"
                PORTS="--top-ports 500"
            fi
            ;;
        "KALI")
            # Kali - full power
            SCAN_TYPE="-sS"
            TIMING="-T5"
            PORTS="-p-"
            ;;
        *)
            # Default for other systems
            SCAN_TYPE="-sT"
            TIMING="-T4"
            PORTS="--top-ports 500"
            ;;
    esac
    
    echo -e "${GREEN}[✓] Auto-profile set: $SCAN_TYPE $TIMING $PORTS${NC}"
}

# ================= AUTO TARGET DISCOVERY =================
auto_discover_targets() {
    echo -e "${CYAN}[*] AUTO-DISCOVER: Finding scan targets...${NC}"
    
    TARGETS=()
    
    # Method 1: Network interface detection
    auto_detect_network
    
    # Method 2: ARP scan (if possible)
    auto_arp_scan
    
    # Method 3: Previous scan results
    auto_load_previous_targets
    
    # Method 4: User input fallback
    if [[ ${#TARGETS[@]} -eq 0 ]]; then
        auto_get_user_targets
    fi
    
    echo -e "${GREEN}[✓] Found ${#TARGETS[@]} targets${NC}"
}

auto_detect_network() {
    echo -e "${CYAN}[*] Scanning network interfaces...${NC}"
    
    # Get local IP and network
    if command -v ip &> /dev/null; then
        LOCAL_IP=$(ip addr show | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | head -1)
        NETWORK=$(echo $LOCAL_IP | cut -d. -f1-3).0/24
        TARGETS+=("$NETWORK")
        echo -e "${GREEN}[✓] Local network: $NETWORK${NC}"
    elif command -v ifconfig &> /dev/null; then
        LOCAL_IP=$(ifconfig | grep -oP 'inet \K[\d.]+' | grep -v '127.0.0.1' | head -1)
        NETWORK=$(echo $LOCAL_IP | cut -d. -f1-3).0/24
        TARGETS+=("$NETWORK")
        echo -e "${GREEN}[✓] Local network: $NETWORK${NC}"
    fi
}

auto_arp_scan() {
    echo -e "${CYAN}[*] Performing ARP discovery...${NC}"
    
    if [[ $SYSTEM == "KALI" ]] || [[ $EUID -eq 0 ]]; then
        # Try arp-scan if available
        if command -v arp-scan &> /dev/null; then
            echo -e "${CYAN}[*] Running arp-scan...${NC}"
            sudo arp-scan -l | grep -oP '\d+\.\d+\.\d+\.\d+' | while read ip; do
                TARGETS+=("$ip")
            done
        fi
    fi
}

auto_load_previous_targets() {
    if [[ -f "$RESULTS/previous_targets.txt" ]]; then
        echo -e "${CYAN}[*] Loading previous targets...${NC}"
        while IFS= read -r line; do
            TARGETS+=("$line")
        done < "$RESULTS/previous_targets.txt"
    fi
}

auto_get_user_targets() {
    echo -e "${YELLOW}[!] No auto-targets found${NC}"
    echo -e "${CYAN}[?] Enter target (IP/CIDR/domain) or press Enter for local network:${NC}"
    read -p "> " USER_TARGET
    
    if [[ -z "$USER_TARGET" ]]; then
        # Default to local network
        if [[ -n "$NETWORK" ]]; then
            TARGETS+=("$NETWORK")
        else
            TARGETS+=("192.168.1.0/24")
        fi
    else
        TARGETS+=("$USER_TARGET")
    fi
}

# ================= AUTO SCAN PROTOCOLS =================
auto_scan_all_protocols() {
    echo -e "${CYAN}[*] AUTO-SCAN: Starting comprehensive scan...${NC}"
    
    for TARGET in "${TARGETS[@]}"; do
        echo -e "${PURPLE}=========================================${NC}"
        echo -e "${WHITE}Scanning: $TARGET${NC}"
        echo -e "${PURPLE}=========================================${NC}"
        
        # Generate unique filename based on target and timestamp
        FILENAME=$(echo "$TARGET" | tr '/.' '_')
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        
        # 1. DISCOVERY SCAN
        auto_discovery_scan "$TARGET" "$FILENAME"_discovery_"$TIMESTAMP"
        
        # 2. PORT SCAN
        auto_port_scan "$TARGET" "$FILENAME"_ports_"$TIMESTAMP"
        
        # 3. SERVICE SCAN
        auto_service_scan "$TARGET" "$FILENAME"_services_"$TIMESTAMP"
        
        # 4. VULNERABILITY SCAN
        auto_vuln_scan "$TARGET" "$FILENAME"_vuln_"$TIMESTAMP"
        
        # 5. OS DETECTION (if possible)
        auto_os_detection "$TARGET" "$FILENAME"_os_"$TIMESTAMP"
        
        # 6. SCRIPT SCAN
        auto_script_scan "$TARGET" "$FILENAME"_scripts_"$TIMESTAMP"
        
        # Generate combined report
        auto_generate_report "$FILENAME" "$TIMESTAMP"
    done
}

auto_discovery_scan() {
    local target=$1
    local filename=$2
    
    echo -e "${CYAN}[1/6] Discovery Scan...${NC}"
    
    case $SYSTEM in
        "TERMUX"|"A_SHELL")
            $NMAP_CMD -sn "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
            ;;
        *)
            $NMAP_CMD -sn -PE -PS21,22,23,25,80,443 "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
            ;;
    esac
    
    # Extract live hosts
    grep -oP '\d+\.\d+\.\d+\.\d+' "$RESULTS/$filename.txt" > "$RESULTS/${filename}_hosts.txt"
    LIVE_HOSTS=$(wc -l < "$RESULTS/${filename}_hosts.txt")
    echo -e "${GREEN}[✓] Found $LIVE_HOSTS live hosts${NC}"
}

auto_port_scan() {
    local target=$1
    local filename=$2
    
    echo -e "${CYAN}[2/6] Port Scan...${NC}"
    
    # Read live hosts if available
    if [[ -f "$RESULTS/${1}_discovery_*_hosts.txt" ]]; then
        LIVE_FILE=$(ls "$RESULTS" | grep "${1}_discovery.*_hosts.txt" | tail -1)
        if [[ -n "$LIVE_FILE" ]]; then
            echo -e "${CYAN}[*] Scanning live hosts from discovery${NC}"
            $NMAP_CMD $SCAN_TYPE $TIMING $PORTS -iL "$RESULTS/$LIVE_FILE" -oN "$RESULTS/$filename.txt" 2>/dev/null
            return
        fi
    fi
    
    # Fallback to direct scan
    $NMAP_CMD $SCAN_TYPE $TIMING $PORTS "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
}

auto_service_scan() {
    local target=$1
    local filename=$2
    
    echo -e "${CYAN}[3/6] Service Detection...${NC}"
    
    # Get open ports from previous scan
    PORT_FILE=$(ls "$RESULTS" | grep "${1}_ports.*.txt" | tail -1)
    if [[ -n "$PORT_FILE" ]]; then
        # Extract open ports
        OPEN_PORTS=$(grep -E '^[0-9]+/tcp.*open' "$RESULTS/$PORT_FILE" | cut -d'/' -f1 | tr '\n' ',' | sed 's/,$//')
        
        if [[ -n "$OPEN_PORTS" ]]; then
            echo -e "${CYAN}[*] Scanning open ports: $OPEN_PORTS${NC}"
            $NMAP_CMD -sV -sC -p "$OPEN_PORTS" "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
            return
        fi
    fi
    
    # Fallback to top ports
    $NMAP_CMD -sV -sC --top-ports 100 "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
}

auto_vuln_scan() {
    local target=$1
    local filename=$2
    
    echo -e "${CYAN}[4/6] Vulnerability Scan...${NC}"
    
    # Check if NSE scripts are available
    if [[ -d /usr/share/nmap/scripts ]] || [[ -d /data/data/com.termux/files/usr/share/nmap/scripts ]]; then
        # Get services from previous scan
        SERVICE_FILE=$(ls "$RESULTS" | grep "${1}_services.*.txt" | tail -1)
        
        if [[ -n "$SERVICE_FILE" ]]; then
            # Run targeted vuln scans based on services found
            if grep -qi "http" "$RESULTS/$SERVICE_FILE"; then
                echo -e "${CYAN}[*] HTTP services found, running web vuln scan${NC}"
                $NMAP_CMD --script http-vuln* -p80,443,8080,8443 "$target" -oN "$RESULTS/${filename}_web.txt" 2>/dev/null
            fi
            
            if grep -qi "smb\|microsoft-ds" "$RESULTS/$SERVICE_FILE"; then
                echo -e "${CYAN}[*] SMB services found, running SMB vuln scan${NC}"
                $NMAP_CMD --script smb-vuln* -p139,445 "$target" -oN "$RESULTS/${filename}_smb.txt" 2>/dev/null
            fi
            
            if grep -qi "ssh" "$RESULTS/$SERVICE_FILE"; then
                echo -e "${CYAN}[*] SSH services found, running SSH audit${NC}"
                $NMAP_CMD --script ssh-* -p22 "$target" -oN "$RESULTS/${filename}_ssh.txt" 2>/dev/null
            fi
        fi
        
        # Run general vuln scan
        $NMAP_CMD --script vuln "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
    else
        echo -e "${YELLOW}[!] NSE scripts not available, skipping vulnerability scan${NC}"
    fi
}

auto_os_detection() {
    local target=$1
    local filename=$2
    
    echo -e "${CYAN}[5/6] OS Detection...${NC}"
    
    if [[ $SYSTEM == "KALI" ]] || [[ $EUID -eq 0 ]]; then
        $NMAP_CMD -O "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
    else
        echo -e "${YELLOW}[!] OS detection requires root privileges${NC}"
        # Fallback to TCP/IP fingerprinting
        $NMAP_CMD -sV --version-intensity 9 "$target" -oN "$RESULTS/${filename}_fingerprint.txt" 2>/dev/null
    fi
}

auto_script_scan() {
    local target=$1
    local filename=$2
    
    echo -e "${CYAN}[6/6] Script Scanning...${NC}"
    
    # Run safe scripts by default
    $NMAP_CMD --script safe "$target" -oN "$RESULTS/$filename.txt" 2>/dev/null
    
    # Additional script categories based on system capability
    if [[ $SYSTEM == "KALI" ]]; then
        $NMAP_CMD --script discovery "$target" -oN "$RESULTS/${filename}_discovery.txt" 2>/dev/null
        $NMAP_CMD --script auth "$target" -oN "$RESULTS/${filename}_auth.txt" 2>/dev/null
    fi
}

# ================= AUTO REPORT GENERATION =================
auto_generate_report() {
    local filename=$1
    local timestamp=$2
    
    echo -e "${CYAN}[*] Generating automated report...${NC}"
    
    REPORT_FILE="$RESULTS/${filename}_REPORT_${timestamp}.html"
    
    cat > "$REPORT_FILE" << EOF
<!DOCTYPE html>
<html>
<head>
    <title>AutoNmap Scan Report - $timestamp</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        .header { background: #2c3e50; color: white; padding: 20px; }
        .section { margin: 20px 0; border: 1px solid #ddd; padding: 15px; }
        .critical { color: #e74c3c; }
        .warning { color: #f39c12; }
        .info { color: #3498db; }
        .success { color: #2ecc71; }
        pre { background: #f5f5f5; padding: 10px; overflow: auto; }
    </style>
</head>
<body>
    <div class="header">
        <h1>🔍 AutoNmap Scan Report</h1>
        <p>Generated: $(date)</p>
        <p>System: $SYSTEM | Target: $filename</p>
    </div>
    
    <div class="section">
        <h2>📊 Scan Summary</h2>
        <p><strong>Total Scans Performed:</strong> 6</p>
        <p><strong>Scan Duration:</strong> $(date -d@$SECONDS -u +%H:%M:%S)</p>
    </div>
EOF

    # Add each scan result to report
    for scan_type in discovery ports services vuln os scripts; do
        local scan_file=$(ls "$RESULTS" | grep "${filename}_${scan_type}.*.txt" | tail -1)
        
        if [[ -n "$scan_file" ]]; then
            cat >> "$REPORT_FILE" << EOF
    <div class="section">
        <h3>$(echo $scan_type | tr '[:lower:]' '[:upper:]') Scan Results</h3>
        <pre>$(head -50 "$RESULTS/$scan_file")</pre>
        <p><a href="$scan_file">View Full Results</a></p>
    </div>
EOF
        fi
    done

    # Add findings summary
    cat >> "$REPORT_FILE" << EOF
    <div class="section">
        <h2>⚠️ Security Findings</h2>
EOF

    # Check for critical findings
    check_critical_findings "$filename" >> "$REPORT_FILE"
    
    cat >> "$REPORT_FILE" << EOF
    </div>
    
    <div class="section">
        <h2>🔧 Recommendations</h2>
        <ul>
            <li>Close unnecessary open ports</li>
            <li>Update services to latest versions</li>
            <li>Implement firewall rules</li>
            <li>Regular security scanning</li>
        </ul>
    </div>
    
    <footer>
        <p>Report generated by AutoNmap v5.0</p>
    </footer>
</body>
</html>
EOF

    echo -e "${GREEN}[✓] Report generated: $REPORT_FILE${NC}"
    
    # Also generate text summary
    generate_text_summary "$filename" "$timestamp"
}

check_critical_findings() {
    local filename=$1
    
    echo "<ul>"
    
    # Check for open high-risk ports
    for port_file in $(ls "$RESULTS" | grep "${filename}_ports.*.txt"); do
        while read line; do
            if echo "$line" | grep -qE '(22/tcp.*open|23/tcp.*open|21/tcp.*open|25/tcp.*open)'; then
                echo "<li class='critical'>🛑 Open high-risk port: $line</li>"
            fi
        done < "$RESULTS/$port_file"
    done
    
    # Check for vulnerable services
    for vuln_file in $(ls "$RESULTS" | grep "${filename}_vuln.*.txt"); do
        if grep -qi "VULNERABLE" "$RESULTS/$vuln_file"; then
            echo "<li class='critical'>🛑 Vulnerable service detected</li>"
        fi
    done
    
    echo "</ul>"
}

generate_text_summary() {
    local filename=$1
    local timestamp=$2
    
    SUMMARY_FILE="$RESULTS/${filename}_SUMMARY_${timestamp}.txt"
    
    cat > "$SUMMARY_FILE" << EOF
==============================================
AUTONMAP SCAN SUMMARY
==============================================
Scan Date: $(date)
Target: $filename
System: $SYSTEM
==============================================

SCAN RESULTS:
-------------
EOF

    # Collect all findings
    for scan_file in $(ls "$RESULTS" | grep "${filename}_.*\.txt" | grep -v "SUMMARY\|REPORT\|hosts"); do
        echo "" >> "$SUMMARY_FILE"
        echo "=== $(echo $scan_file | sed 's/.*_//' | sed 's/\.txt//' | tr '_' ' ') ===" >> "$SUMMARY_FILE"
        grep -E "(open|VULNERABLE|CVE|CRITICAL)" "$RESULTS/$scan_file" | head -10 >> "$SUMMARY_FILE"
    done

    echo -e "${GREEN}[✓] Text summary: $SUMMARY_FILE${NC}"
}

# ================= AUTO CLEANUP =================
auto_cleanup() {
    echo -e "${CYAN}[*] Performing auto-cleanup...${NC}"
    
    # Remove temporary files
    find "$RESULTS" -name "*_temp*" -delete 2>/dev/null
    find "$RESULTS" -name "*_hosts.txt" -delete 2>/dev/null
    
    # Compress old logs (older than 7 days)
    find "$RESULTS" -name "*.txt" -mtime +7 -exec gzip {} \; 2>/dev/null
    
    # Limit total files (keep latest 100)
    ls -t "$RESULTS"/*.txt 2>/dev/null | tail -n +101 | xargs rm -f 2>/dev/null
    
    echo -e "${GREEN}[✓] Cleanup completed${NC}"
}

# ================= AUTO SCHEDULING =================
auto_schedule_scans() {
    echo -e "${CYAN}[*] Checking for scheduled scans...${NC}"
    
    if [[ -f "$RESULTS/autoscan.cron" ]]; then
        echo -e "${GREEN}[✓] Scheduled scan detected${NC}"
        source "$RESULTS/autoscan.cron"
        
        if [[ "$AUTO_SCAN_ENABLED" == "true" ]]; then
            echo -e "${CYAN}[*] Running scheduled scan...${NC}"
            auto_scan_all_protocols
        fi
    else
        # Create default schedule
        create_auto_schedule
    fi
}

create_auto_schedule() {
    cat > "$RESULTS/autoscan.cron" << EOF
# AutoNmap Schedule Configuration
AUTO_SCAN_ENABLED=true
SCAN_FREQUENCY="daily"  # daily, weekly, monthly
NEXT_SCAN=$(date -d "+1 day" +%Y-%m-%d)
LAST_SCAN=$(date +%Y-%m-%d)
EOF
    
    echo -e "${GREEN}[✓] Default schedule created${NC}"
}

# ================= MAIN EXECUTION =================
main() {
    # Colors
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    PURPLE='\033[0;35m'
    CYAN='\033[0;36m'
    WHITE='\033[1;37m'
    NC='\033[0m'
    
    clear
    echo -e "${PURPLE}"
    cat << "EOF"
    █████╗ ██╗   ██╗████████╗ ██████╗      ███╗   ██╗███╗   ███╗ █████╗ ██████╗ 
   ██╔══██╗██║   ██║╚══██╔══╝██╔═══██╗     ████╗  ██║████╗ ████║██╔══██╗██╔══██╗
   ███████║██║   ██║   ██║   ██║   ██║     ██╔██╗ ██║██╔████╔██║███████║██████╔╝
   ██╔══██║██║   ██║   ██║   ██║   ██║     ██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝ 
   ██║  ██║╚██████╔╝   ██║   ╚██████╔╝     ██║ ╚████║██║ ╚═╝ ██║██║  ██║██║     
   ╚═╝  ╚═╝ ╚═════╝    ╚═╝    ╚═════╝      ╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     
                                                                                 
                   Fully Automatic Nmap Scanner v5.0
EOF
    echo -e "${NC}"
    
    # Start timing
    SECONDS=0
    
    # Auto-configure everything
    auto_detect_and_configure
    
    # Check for scheduled scans
    auto_schedule_scans
    
    # Auto-discover targets
    auto_discover_targets
    
    # Run comprehensive auto-scan
    auto_scan_all_protocols
    
    # Auto-cleanup
    auto_cleanup
    
    # Show completion message
    echo -e "${PURPLE}=========================================${NC}"
    echo -e "${GREEN}[✓] AUTO-SCAN COMPLETED SUCCESSFULLY!${NC}"
    echo -e "${WHITE}Total time: $(date -d@$SECONDS -u +%H:%M:%S)${NC}"
    echo -e "${WHITE}Results saved in: $RESULTS${NC}"
    echo -e "${PURPLE}=========================================${NC}"
    
    # Show quick summary
    echo -e "${CYAN}[*] Quick Summary:${NC}"
    find "$RESULTS" -name "*SUMMARY*.txt" -type f -exec tail -20 {} \; 2>/dev/null | head -20
    
    # Ask for next action
    echo -e "\n${YELLOW}[?] What would you like to do next?${NC}"
    echo -e "${GREEN}[1]${NC} View full report"
    echo -e "${GREEN}[2]${NC} Run another scan"
    echo -e "${GREEN}[3]${NC} Schedule automatic scans"
    echo -e "${GREEN}[4]${NC} Exit"
    
    read -p "> " choice
    
    case $choice in
        1)
            # Find and display latest report
            latest_report=$(ls -t "$RESULTS"/*REPORT*.html 2>/dev/null | head -1)
            if [[ -n "$latest_report" ]]; then
                if command -v lynx &> /dev/null; then
                    lynx "$latest_report"
                else
                    echo -e "${YELLOW}[!] Install lynx to view HTML report${NC}"
                    echo -e "${CYAN}[*] Report file: $latest_report${NC}"
                fi
            fi
            ;;
        2)
            # Restart scan
            exec "$0"
            ;;
        3)
            # Edit schedule
            nano "$RESULTS/autoscan.cron"
            echo -e "${GREEN}[✓] Schedule updated${NC}"
            ;;
    esac
    
    echo -e "${GREEN}[✓] AutoNmap finished. Goodbye!${NC}"
}

# Run main function
main "$@"
