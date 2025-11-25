#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🚀 Fixed Ultimate Nmap Scanner - DNS & UDP Issues Resolved
"""

import os
import sys
import subprocess
import time
import socket
from datetime import datetime

try:
    import requests
except ImportError:
    subprocess.run([sys.executable, "-m", "pip", "install", "requests"], check=True)
    import requests

class FixedNmapScanner:
    def __init__(self):
        self.target = ""
        self.target_ip = ""
        self.scan_history = []
        
    def clear_screen(self):
        os.system('clear' if os.name == 'posix' else 'cls')
    
    def show_banner(self):
        self.clear_screen()
        print("\033[1;91m")
        print("╔╦╗┌─┐┌┬┐┌─┐  ╔═╗┌─┐┌┬┐┌─┐┬─┐┌─┐")
        print(" ║ ├┤ │││├─┘  ╚═╗│ │ │ ├┤ ├┬┘└─┐")
        print(" ╩ └─┘┴ ┴┴    ╚═╝└─┘ ┴ └─┘┴└─└─┘")
        print("\033[1;94m")
        print("╔══════════════════════════════════════════╗")
        print("║           FIXED ULTIMATE SCANNER         ║")
        print("║         DNS & UDP Issues Resolved        ║")
        print("╚══════════════════════════════════════════╝")
        print("\033[1;92m")
        print("🔰 Fixed Features:")
        print("  ✅ DNS Resolution Check  ✅ Root Permission Handling")
        print("  ✅ UDP Scan Fixed        ✅ Better Error Messages")
        print("  ✅ All Nmap Scans        ✅ Real-time Output")
        print("\033[0m")
    
    def check_nmap(self):
        try:
            subprocess.run(['nmap', '--version'], capture_output=True, check=True)
            return True
        except:
            return False
    
    def dns_resolve(self, target):
        """Resolve domain to IP address with error handling"""
        try:
            # Remove http/https if present
            if target.startswith(('http://', 'https://')):
                target = target.split('//')[1].split('/')[0]
            
            print(f"\033[1;94m🔍 Resolving DNS: {target}\033[0m")
            ip_address = socket.gethostbyname(target)
            print(f"\033[1;92m✅ Resolved: {target} → {ip_address}\033[0m")
            return ip_address
        except socket.gaierror:
            print(f"\033[1;91m❌ DNS Resolution Failed: {target}\033[0m")
            print("💡 Tips:")
            print("  • Check internet connection")
            print("  • Verify domain name spelling")
            print("  • Try with IP address instead")
            return None
    
    def get_target(self):
        """Get and validate target"""
        print("\033[1;96m🎯 TARGET SETUP\033[0m")
        print("=" * 50)
        
        while True:
            target = input("\n📍 Enter Target IP/Hostname: ").strip()
            if not target:
                print("\033[1;91m❌ Target cannot be empty!\033[0m")
                continue
            
            # If it looks like an IP address
            if target.replace('.', '').isdigit() and target.count('.') == 3:
                self.target = target
                self.target_ip = target
                break
            else:
                # Try to resolve domain
                ip = self.dns_resolve(target)
                if ip:
                    self.target = target
                    self.target_ip = ip
                    break
                else:
                    print("\033[1;91m❌ Cannot resolve target. Please try again.\033[0m")
        
        print(f"\n\033[1;92m🎯 Target Set: {self.target}\033[0m")
        print(f"\033[1;92m📡 IP Address: {self.target_ip}\033[0m")
        return True
    
    def get_ip_info(self):
        """Get target information"""
        print(f"\n\033[1;94m🌍 Gathering Information for {self.target}...\033[0m")
        print("─" * 50)
        
        try:
            response = requests.get(f"http://ip-api.com/json/{self.target_ip}", timeout=10)
            if response.status_code == 200:
                data = response.json()
                if data['status'] == 'success':
                    print(f"🌎 Country: {data.get('country', 'N/A')}")
                    print(f"🏙️  City: {data.get('city', 'N/A')}")
                    print(f"🏢 ISP: {data.get('isp', 'N/A')}")
                    print(f"📍 Org: {data.get('org', 'N/A')}")
            else:
                print("ℹ️  IP information unavailable")
        except:
            print("ℹ️  IP information service offline")
        
        print("─" * 50)
        return True
    
    def run_scan(self, scan_type, command, description, needs_root=False):
        """Run nmap scan with better error handling"""
        print(f"\n\033[1;95m🚀 Starting: {scan_type}\033[0m")
        print(f"\033[1;96m📝 {description}\033[0m")
        print(f"\033[1;93m💻 Command: nmap {command} {self.target}\033[0m")
        
        if needs_root:
            print("\033[1;93m⚠️  Note: This scan may require root privileges\033[0m")
        
        print("─" * 60)
        
        full_cmd = f"nmap {command} {self.target}"
        
        try:
            start_time = time.time()
            
            # Run the scan
            process = subprocess.Popen(
                full_cmd.split(),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Real-time output
            output_lines = []
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    line = output.strip()
                    print(line)
                    output_lines.append(line)
            
            process.wait()
            end_time = time.time()
            
            # Check for common errors
            stderr = process.stderr.read()
            if stderr:
                print(f"\033[1;91m❌ Error: {stderr}\033[0m")
            
            if process.returncode == 0:
                print(f"\n\033[1;92m✅ {scan_type} completed in {end_time - start_time:.2f}s\033[0m")
                
                self.scan_history.append({
                    'type': scan_type,
                    'command': full_cmd,
                    'timestamp': datetime.now().strftime('%H:%M:%S'),
                    'status': 'SUCCESS'
                })
                return True
            else:
                print(f"\n\033[1;91m❌ {scan_type} failed (Code: {process.returncode})\033[0m")
                
                # Provide helpful error messages
                if "Cannot assign requested address" in stderr:
                    print("💡 Try: Use IP address instead of hostname")
                elif "Name or service not known" in stderr:
                    print("💡 Try: Check DNS resolution or use IP address")
                elif "Operation not permitted" in stderr:
                    print("💡 Try: Run with root privileges for this scan")
                
                self.scan_history.append({
                    'type': scan_type,
                    'command': full_cmd,
                    'timestamp': datetime.now().strftime('%H:%M:%S'),
                    'status': 'FAILED'
                })
                return False
                
        except Exception as e:
            print(f"\n\033[1;91m❌ Scan error: {e}\033[0m")
            return False
    
    def quick_scan(self):
        return self.run_scan(
            "QUICK SCAN",
            "-T4 -F --open",
            "Fast scan of common ports (100 ports)"
        )
    
    def full_scan(self):
        return self.run_scan(
            "FULL PORT SCAN", 
            "-T4 -p- --open",
            "Scan all 65535 ports (takes longer)"
        )
    
    def stealth_scan(self):
        return self.run_scan(
            "STEALTH SCAN",
            "-sS -T2 -f",
            "Stealth SYN scan with fragmentation",
            needs_root=True
        )
    
    def os_detection(self):
        return self.run_scan(
            "OS DETECTION",
            "-O -T4",
            "Operating system detection",
            needs_root=True
        )
    
    def service_scan(self):
        return self.run_scan(
            "SERVICE DETECTION",
            "-sV -T4 --version-intensity 5",
            "Service version detection"
        )
    
    def vulnerability_scan(self):
        return self.run_scan(
            "VULNERABILITY SCAN", 
            "--script vuln --script-args safe=1",
            "Vulnerability detection using NSE scripts"
        )
    
    def udp_scan_fixed(self):
        """Fixed UDP scan with better handling"""
        print("\033[1;93m🔧 UDP Scan Notes:\033[0m")
        print("  • UDP scans are slower than TCP")
        print("  • May require root privileges")
        print("  • Scanning top 50 UDP ports for speed")
        
        return self.run_scan(
            "UDP SCAN (FIXED)",
            "-sU -T4 --top-ports 50 --open",
            "UDP port scan (top 50 ports)",
            needs_root=True
        )
    
    def aggressive_scan(self):
        return self.run_scan(
            "AGGRESSIVE SCAN",
            "-A -T4",
            "Aggressive scan with OS and version detection"
        )
    
    def script_scan(self):
        return self.run_scan(
            "SCRIPT SCAN",
            "-sC -T4",
            "Default NSE script scan"
        )
    
    def firewall_evasion(self):
        return self.run_scan(
            "FIREWALL EVASION",
            "-f -T2 -D RND:5",
            "Firewall evasion techniques",
            needs_root=True
        )
    
    def run_all_scans(self):
        """Run all scans with proper ordering"""
        print("\033[1;95m🎯 STARTING COMPLETE SCAN SUITE\033[0m")
        print("\033[1;96m📡 Running optimized scan sequence...\033[0m")
        print("═" * 60)
        
        # Optimized scan order
        scans = [
            ("Quick Scan", self.quick_scan, False),
            ("Service Detection", self.service_scan, False),
            ("OS Detection", self.os_detection, True),
            ("Script Scan", self.script_scan, False),
            ("Vulnerability Scan", self.vulnerability_scan, False),
            ("UDP Scan", self.udp_scan_fixed, True),
            ("Stealth Scan", self.stealth_scan, True),
        ]
        
        successful = 0
        for name, scan_func, needs_root in scans:
            if needs_root:
                print(f"\033[1;93m⚠️  {name} may require root privileges\033[0m")
            
            if scan_func():
                successful += 1
            
            print("\n" + "─" * 50)
            time.sleep(1)
        
        print(f"\n\033[1;92m✅ Completed {successful}/{len(scans)} scans successfully!\033[0m")
        self.show_scan_history()
    
    def show_scan_history(self):
        if not self.scan_history:
            print("\n\033[1;93m📊 No scans performed yet\033[0m")
            return
        
        print("\n\033[1;95m📋 SCAN HISTORY\033[0m")
        print("═" * 70)
        for i, scan in enumerate(self.scan_history, 1):
            status_color = "\033[1;92m" if scan['status'] == 'SUCCESS' else "\033[1;91m"
            print(f"{i:2d}. {scan['type']:20} | {scan['timestamp']} | {status_color}{scan['status']}\033[0m")
        print("═" * 70)
    
    def show_menu(self):
        print("\n\033[1;96m📋 MAIN MENU - FIXED VERSION\033[0m")
        print("═" * 50)
        print("\033[1;97m01   Quick Scan (Fast common ports)")
        print("02   Full Port Scan (All 65535 ports)")
        print("03   Stealth Scan (Firewall evasion) ⚠️")
        print("04   OS Detection (Operating system) ⚠️")
        print("05   Service Detection (Version detection)")
        print("06   Vulnerability Scan (Security checks)")
        print("07   UDP Scan (UDP services) ⚠️")
        print("08   Aggressive Scan (All-in-one)")
        print("09   Script Scan (NSE scripts)")
        print("10   Firewall Evasion (Bypass firewalls) ⚠️")
        print("11   RUN ALL SCANS (Optimized sequence)")
        print("12   Scan History")
        print("13   Change Target")
        print("0️⃣   Exit\033[0m")
        print("═" * 50)
        print("\033[1;93m⚠️  = May require root privileges\033[0m")
    
    def main_loop(self):
        if not self.check_nmap():
            print("\033[1;91m❌ Nmap not found!\033[0m")
            if input("Install nmap? (y/n): ").lower() == 'y':
                os.system('apk update && apk add nmap')
            else:
                return
        
        self.show_banner()
        self.get_target()
        self.get_ip_info()
        
        while True:
            self.show_banner()
            print(f"\033[1;92m🎯 Target: {self.target} ({self.target_ip})\033[0m")
            self.show_menu()
            
            choice = input("\n\033[1;93m👉 Select option (0-13): \033[0m").strip()
            
            if choice == '0':
                print("\n\033[1;92m👋 Thank you for using Fixed Nmap Scanner!\033[0m")
                break
            elif choice == '1':
                self.quick_scan()
            elif choice == '2':
                self.full_scan()
            elif choice == '3':
                self.stealth_scan()
            elif choice == '4':
                self.os_detection()
            elif choice == '5':
                self.service_scan()
            elif choice == '6':
                self.vulnerability_scan()
            elif choice == '7':
                self.udp_scan_fixed()
            elif choice == '8':
                self.aggressive_scan()
            elif choice == '9':
                self.script_scan()
            elif choice == '10':
                self.firewall_evasion()
            elif choice == '11':
                self.run_all_scans()
            elif choice == '12':
                self.show_scan_history()
            elif choice == '13':
                self.get_target()
                self.get_ip_info()
            else:
                print("\033[1;91m❌ Invalid choice!\033[0m")
                time.sleep(1)
                continue
            
            if choice not in ['0', '12', '13']:
                input("\n\033[1;94m🔁 Press Enter to continue...\033[0m")

def main():
    try:
        scanner = FixedNmapScanner()
        scanner.main_loop()
    except KeyboardInterrupt:
        print("\n\n\033[1;93m👋 Program interrupted by user\033[0m")
    except Exception as e:
        print(f"\n\033[1;91m💥 Error: {e}\033[0m")

if __name__ == "__main__":
    main()
