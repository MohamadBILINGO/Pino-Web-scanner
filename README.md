👨 Authored by **Mohamad**  
🌐 GitHub: [https://github.com/MohamadBILINGO](https://github.com/MohamadBILINGO)  

---

## ✨ Features
- Get **IP address** of the domain  
- Fetch **DNS records**  
- Extract **WHOIS info** (first 20 lines)  
- Test **HTTP/HTTPS status & response time** (with timeout handling)  
- Measure **Ping response**  
- Colored & user-friendly output  
- Includes **help menu (-h / --help)**  
- Auto-install dependencies on Debian/Ubuntu  

---

## 📦 Requirements
The script uses the following tools:
- `dig` (`dnsutils`)
- `whois`
- `curl`
- `ping` (`iputils-ping`)

If missing, PinoScan will ask to install them automatically (Debian/Ubuntu systems).

---

## ⚡ Installation
Clone this repository and make the script executable:
```bash
git clone https://github.com/MohamadBILINGO/PinoScan.git
cd PinoScan
chmod +x PinoScan.sh

Example usage:

=====================================
        ██████╗ ██╗███╗   ██╗ ██████╗ 
        ██╔══██╗██║████╗  ██║██╔═══██╗
        ██████╔╝██║██╔██╗ ██║██║   ██║
        ██╔═══╝ ██║██║╚██╗██║██║   ██║
        ██║     ██║██║ ╚████║╚██████╔╝
        ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ 
             PinoScan v1.0
=====================================

Authored by Mohamad
GitHub: https://github.com/MohamadBILINGO

Gathering info for google.com
[+] IP Address:
142.250.184.14

[+] DNS Records:
google.com.   300 IN A   142.250.184.14
...

[+] HTTP Status and Response Time:
HTTP Status: 200
Time: 0.142s

[+] Ping Response:
64 bytes from 142.250.184.14: icmp_seq=1 ttl=118 time=18.2 ms
...




