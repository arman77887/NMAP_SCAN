# 🔍 NMAP SCAN - Ultimate Network Scanner

**Fixed Ultimate Scanner with DNS & UDP Issues Resolved**  
*Android, iPhone, Windows, Linux, macOS - সকল ডিভাইসে ব্যবহারযোগ্য*

![Banner](https://img.shields.io/badge/Version-Fixed_Ultimate_Scanner-green)
![Platform](https://img.shields.io/badge/Platform-Android_iOS_Win_Linux_Mac-blue)
![Python](https://img.shields.io/badge/Python-3.6%2B-yellow)

## 📱 **সকল ডিভাইসে ব্যবহারের নিয়ম**

### **🟢 Android (Termux)**
```bash
# 1. Termux ইনস্টল করুন (Play Store থেকে)
# 2. কমান্ড লাইন ওপেন করুন

pkg update && pkg upgrade
pkg install python git nmap
git clone https://github.com/arman77887/NMAP_SCAN.git
cd NMAP_SCAN
python nmap_scanner.py
# 🍎 iPhone/iOS (iSH Shell)
# 1. App Store থেকে iSH Shell ইনস্টল করুন
# 2. কমান্ড লাইন ওপেন করুন

apk update
apk add python3 git nmap
git clone https://github.com/arman77887/NMAP_SCAN.git
cd NMAP_SCAN
python3 nmap_scanner.py
# 🪟 Windows
git clone https://github.com/arman77887/NMAP_SCAN.git
cd NMAP_SCAN
python nmap_scanner.py

# 🐧 Linux/macOS
# Ubuntu/Debian
sudo apt install nmap python3

# macOS
brew install nmap python

git clone https://github.com/arman77887/NMAP_SCAN.git
cd NMAP_SCAN
python3 nmap_scanner.py

# 📊 স্ক্যান অপশনসমূহ
অপশন	স্ক্যান টাইপ	সময়	রুট প্রয়োজন
01	Quick Scan	1-2 মিনিট	❌ না
02	Full Port Scan	10-30 মিনিট	❌ না
03	Stealth Scan	2-5 মিনিট	✅ হ্যাঁ
04	OS Detection	3-7 মিনিট	✅ হ্যাঁ
05	Service Detection	2-4 মিনিট	❌ না
06	Vulnerability Scan	5-10 মিনিট	❌ না
07	UDP Scan	5-15 মিনিট	✅ হ্যাঁ
08	Aggressive Scan	5-10 মিনিট	✅ হ্যাঁ
09	Script Scan	3-8 মিনিট	❌ না
10	Firewall Evasion	4-9 মিনিট	✅ হ্যাঁ
11	ALL SCANS	30-60 মিনিট	✅ হ্যাঁ
🎯 ফিচারসমূহ

✅ ফিক্সড ফিচারস:

DNS Resolution Check
UDP Scan Fixed
All Nmap Scans Working
✅ রুট পারমিশন হ্যান্ডলিং:

Better Error Messages
Real-time Output
✅ এডভান্সড ফিচারস:

Scan History Save
Multiple Target Support
Web Interface Option
