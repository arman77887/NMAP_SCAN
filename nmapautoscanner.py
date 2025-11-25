#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
🚀 Ultimate Nmap Auto Scanner - All in One
🔧 Automated Complete Network Scanning Tool
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
    print("Installing requests module...")
    subprocess.run([sys.executable, "-m", "pip", "install", "requests"], check=True)
    import requests

class AutoNmapScanner:
    def __init__(self):
        self.target = ""
        self.results = {}
        self.scan_history = []
        
    def clear_screen(self):
        os.system('clear' if os.name == 'posix' else 'cls')
    
    def show_banner(self):
        self.clear_screen()
        print("\033[1;91m")  # Red color
        print("███╗   ██╗███╗   ███╗ █████╗ ██████╗ ")
        print("████╗  ██║████╗ ████║██╔══██╗██╔══██╗")
        print("██╔██╗ ██║██╔████╔██║███████║██████╔╝")
        print("██║╚██╗██║██║╚██╔╝██║██╔══██║██╔═══╝ ")
        print("██║ ╚████║██║ ╚═╝ ██║██║  ██║██║     ")
        print("╚═╝  ╚═══╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝     ")
        print("\033[1;94m")  # Blue color
        print("╔══════════════════════════════════════════╗")
        print("║           ULTIMATE SCANNER              ║")
        print("║    Automated Network Discovery Tool     ║")
        print("╚══════════════════════════════════════════╝")
        print("\033[1;92m")  # Green color
        print("🔰 Features:")
        print("  ✅ Quick Scan        ✅ Full Port Scan")
        print("  ✅ OS Detection      ✅ Service Detection") 
        print("  ✅ Vulnerability     ✅ Stealth Scan")
        print("  ✅ UDP Scan          ✅ Aggressive Scan")
        print("  ✅ Script Scanning   ✅ Firewall Evasion")
        print("\033[0m")
    
    def check_nmap(self):
        """Check if nmap is installed"""
        try:
            subprocess.run(['nmap', '--version'], capture_output=True, check=True)
            return True
        except:
            return False
    
    def install_nmap(self):
        """Install nmap"""
        print("\033[1;93m📦 Installing Nmap...\033[0m")
        try:
            if sys.platform.startswith('linux'):
                if os.path.exists('/etc/alpine-release'):
                    subprocess.run(['apk', 'add', 'nmap'], check=True)
                else:
                    subprocess.run(['apt', 'update', '&&', 'apt', 'install', 'nmap', '-y'], shell=True)
            print("\033[1;92m✅ Nmap installed successfully!\033[0m")
            time.sleep(2)
            return True
        except:
            print("\033[1;91m❌ Failed to install Nmap\033[0m")
            return False
    
    def get_target(self):
        """Get target from user"""
        print("\033[1;96m" + "🎯 TARGET SETUP" + "\033[0m")
        print("=" * 40)
        while True:
            self.target = input("\n📍 Enter Target IP/Hostname/URL: ").strip()
            if self.target:
                # Remove http/https if present
                if self.target.startswith(('http://', 'https://')):
                    self.target = self.target.split('//')[1].split('/')[0]
                break
            print("\033[1;91m❌ Target cannot be empty!\033[0m")
        
        print(f"\n\033[1;92m✅ Target set: {self.target}\033[0m")
        return self.target
    
    def get_ip_info(self):
        """Get target IP information"""
        print(f"\n\033[1;94m🌍 Gathering IP Information for {self.target}...\033[0m")
        print("─" * 50)
        
        try:
            # Get IP address
            ip_addr = socket.gethostbyname(self.target)
            print(f"📡 IP Address: \033[1;92m{ip_addr}\033[0m")
            
            # Get geolocation info
            try:
                response = requests.get(f"http://ip-api.com/json/{ip_addr}", timeout=10)
                if response.status_code == 200:
                    data = response.json()
                    if data['status'] == 'success':
                        print(f"🌎 Country: {data.get('country', 'N/A')}")
                        print(f"🏙️  City: {data.get('city', 'N/A')}")
                        print(f"🏢 ISP: {data.get('isp', 'N/A')}")
                        print(f"📍 Organization: {data.get('org', 'N/A')}")
            except:
                print("ℹ️  Geolocation info unavailable")
                
        except socket.gaierror:
            print("\033[1;91m❌ Cannot resolve hostname\033[0m")
            return False
        
        print("─" * 50)
        return True
    
    def run_scan(self, scan_type, command, description):
        """Run a single nmap scan"""
        print(f"\n\033[1;95m🚀 Starting: {scan_type}\033[0m")
        print(f"\033[1;96m📝 {description}\033[0m")
        print(f"\033[1;93m💻 Command: nmap {command} {self.target}\033[0m")
        print("─" * 60)
        
        full_cmd = f"nmap {command} {self.target}"
        
        try:
            # Run the scan
            start_time = time.time()
            process = subprocess.Popen(
                full_cmd.split(),
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                text=True
            )
            
            # Print output in real-time
            while True:
                output = process.stdout.readline()
                if output == '' and process.poll() is not None:
                    break
                if output:
                    print(output.strip())
            
            process.wait()
            end_time = time.time()
            
            if process.returncode == 0:
                print(f"\n\033[1;92m✅ {scan_type} completed in {end_time - start_time:.2f} seconds\033[0m")
                
                # Save to history
                self.scan_history.append({
                    'type': scan_type,
                    'command': full_cmd,
                    'timestamp': datetime.now().strftime('%Y-%m-%d %H:%M:%S'),
                    'duration': f"{end_time - start_time:.2f}s"
                })
                
                return True
            else:
                print(f"\n\033[1;91m❌ {scan_type} failed\033[0m")
                return False
                
        except Exception as e:
            print(f"\n\033[1;91m❌ Error in {scan_type}: {e}\033[0m")
            return False
    
    def quick_scan(self):
        """Quick basic scan"""
        return self.run_scan(
            "QUICK SCAN",
            "-T4 -F",
            "Fast scan of most common ports (100 most common ports)"
        )
    
    def full_scan(self):
        """Full comprehensive scan"""
        return self.run_scan(
            "FULL COMPREHENSIVE SCAN",
            "-sS -sU -T4 -A -v -p-",
            "Complete TCP SYN + UDP scan with OS detection, version detection, and script scanning"
        )
    
    def stealth_scan(self):
        """Stealth scan"""
        return self.run_scan(
            "STEALTH SCAN",
            "-sS -T2 -f --mtu 24",
            "Stealth SYN scan with fragmentation to evade firewalls"
        )
    
    def os_detection(self):
        """OS detection scan"""
        return self.run_scan(
            "OS DETECTION",
            "-O --osscan-limit",
            "Operating system detection and fingerprinting"
        )
    
    def service_scan(self):
        """Service version detection"""
        return self.run_scan(
            "SERVICE DETECTION", 
            "-sV -T4 --version-intensity 5",
            "Service version detection with maximum intensity"
        )
    
    def vulnerability_scan(self):
        """Vulnerability scan"""
        return self.run_scan(
            "VULNERABILITY SCAN",
            "--script vuln --script-args safe=1",
            "Vulnerability detection using NSE scripts"
        )
    
    def udp_scan(self):
        """UDP scan"""
        return self.run_scan(
            "UDP SCAN",
            "-sU -T4 --top-ports 100",
            "UDP port scan of top 100 ports"
        )
    
    def aggressive_scan(self):
        """Aggressive scan"""
        return self.run_scan(
            "AGGRESSIVE SCAN",
            "-A -T4 -v",
            "Aggressive scan with OS detection, version detection, script scanning"
        )
    
    def script_scan(self):
        """NSE script scan"""
        return self.run_scan(
            "SCRIPT SCAN",
            "-sC -T4",
            "Default script scan using Nmap Scripting Engine"
        )
    
    def firewall_evasion(self):
        """Firewall evasion scan"""
        return self.run_scan(
            "FIREWALL EVASION",
            "-f -T2 -D RND:10 --data-length 200",
            "Firewall evasion using fragmentation, decoys, and random data"
        )
    
    def run_all_scans(self):
        """Run all available scans automatically"""
        print("\033[1;95m\n🎯 STARTING COMPLETE SCAN SUITE\033[0m")
        print("\033[1;96m📡 Scanning target with all methods...\033[0m")
        print("═" * 60)
        
        scans = [
            ("Quick Scan", self.quick_scan),
            ("Stealth Scan", self.stealth_scan), 
            ("OS Detection", self.os_detection),
            ("Service Detection", self.service_scan),
            ("UDP Scan", self.udp_scan),
            ("Script Scan", self.script_scan),
            ("Vulnerability Scan", self.vulnerability_scan),
            ("Firewall Evasion", self.firewall_evasion),
            ("Aggressive Scan", self.aggressive_scan),
        ]
        
        successful = 0
        total = len(scans)
        
        for name, scan_func in scans:
            if scan_func():
                successful += 1
            print("\n" + "─" * 50)
            time.sleep(1)  # Brief pause between scans
        
        print(f"\n\033[1;92m✅ Completed {successful}/{total} scans successfully!\033[0m")
        self.show_scan_history()
    
    def show_scan_history(self):
        """Show scan history"""
        if not self.scan_history:
            print("\n\033[1;93m📊 No scans performed yet\033[0m")
            return
        
        print("\n\033[1;95m📋 SCAN HISTORY\033[0m")
        print("═" * 70)
        for i, scan in enumerate(self.scan_history, 1):
            print(f"{i:2d}. {scan['type']:20} | {scan['timestamp']} | {scan['duration']}")
        print("═" * 70)
    
    def show_menu(self):
        """Show main menu"""
        print("\n\033[1;96m" + "📋 MAIN MENU" + "\033[0m")
        print("═" * 50)
        print("\033[1;97m1️⃣   Quick Scan (Fast common ports)")
        print("2️⃣   Full Comprehensive Scan (All ports + services)")
        print("3️⃣   Stealth Scan (Firewall evasion)")
        print("4️⃣   OS Detection (Operating system)")
        print("5️⃣   Service Detection (Version detection)")
        print("6️⃣   Vulnerability Scan (Security checks)")
        print("7️⃣   UDP Scan (UDP services)")
        print("8️⃣   Aggressive Scan (All-in-one)")
        print("9️⃣   Script Scan (NSE scripts)")
        print("🔟   Firewall Evasion (Bypass firewalls)")
        print("🔄   RUN ALL SCANS (Complete automation)")
        print("📊   Scan History")
        print("🎯   Change Target")
        print("0️⃣   Exit\033[0m")
        print("═" * 50)
    
    def main_loop(self):
        """Main program loop"""
        # Check nmap
        if not self.check_nmap():
            print("\033[1;91m❌ Nmap is not installed!\033[0m")
            if input("Install Nmap automatically? (y/n): ").lower() == 'y':
                if not self.install_nmap():
                    print("Please install nmap manually: apk add nmap")
                    return
            else:
                return
        
        # Show banner and get target
        self.show_banner()
        self.get_target()
        
        while True:
            self.show_banner()
            print(f"\033[1;92m🎯 Current Target: {self.target}\033[0m")
            self.show_menu()
            
            choice = input("\n\033[1;93m👉 Select option (0-13): \033[0m").strip()
            
            if choice == '0':
                print("\n\033[1;92m👋 Thank you for using Ultimate Nmap Scanner!\033[0m")
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
                self.udp_scan()
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
                print("\033[1;91m❌ Invalid choice! Please select 0-13\033[0m")
                time.sleep(1)
                continue
            
            if choice not in ['0', '12', '13']:
                input("\n\033[1;94m🔁 Press Enter to continue...\033[0m")

def main():
    """Main function"""
    try:
        scanner = AutoNmapScanner()
        scanner.main_loop()
    except KeyboardInterrupt:
        print("\n\n\033[1;93m👋 Program interrupted by user. Goodbye!\033[0m")
    except Exception as e:
        print(f"\n\033[1;91m💥 Unexpected error: {e}\033[0m")

if __name__ == "__main__":
    main()
