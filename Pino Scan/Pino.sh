#!/bin/bash
#
# BingScan - Domain Information Gathering Script
# Authored by Mohamad
# GitHub: https://github.com/MohamadBILINGO
#

# رنگ‌ها
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # بدون رنگ

# بنر
banner() {
  echo -e "${CYAN}"
  echo "====================================="
  echo "        ██████╗ ██╗███╗   ██╗ ██████╗ "
  echo "        ██╔══██╗██║████╗  ██║██╔═══██╗"
  echo "        ██████╔╝██║██╔██╗ ██║██║   ██║"
  echo "        ██╔═══╝ ██║██║╚██╗██║██║   ██║"
  echo "        ██║     ██║██║ ╚████║╚██████╔╝"
  echo "        ╚═╝     ╚═╝╚═╝  ╚═══╝ ╚═════╝ "
  echo "             PinoScan v1.0"
  echo "====================================="
  echo -e "${NC}"
  echo -e "Authored by ${GREEN}Mohamad${NC}"
  echo -e "GitHub: ${YELLOW}https://github.com/MohamadBILINGO${NC}"
  echo ""
}

# نمایش راهنما
show_help() {
  echo -e "Usage: $0 [OPTIONS] domain.com"
  echo ""
  echo "Options:"
  echo "  -h, --help        Show this help message"
  echo ""
  echo "Example:"
  echo "  $0 example.com"
  echo ""
  echo "The script collects:"
  echo "  - Domain IP address"
  echo "  - DNS records"
  echo "  - WHOIS information"
  echo "  - HTTP/HTTPS status and response time"
  echo "  - Ping response"
  exit 0
}

# بررسی پارامترها
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  show_help
fi

if [ -z "$1" ]; then
  echo -e "${RED}Error: No domain specified.${NC}"
  echo "Use -h for help."
  exit 1
fi

DOMAIN=$1
OUTPUT_FILE="${DOMAIN}_info.txt"

# تابع نصب ابزار در Debian/Ubuntu
install_command() {
  echo -e "${YELLOW}[?] $1 not found. Do you want to install it? (y/n)${NC}"
  read -r choice
  if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    sudo apt update && sudo apt install -y "$2"
  else
    echo -e "${RED}[-] $1 is required. Exiting.${NC}"
    exit 1
  fi
}

# تابع چک کردن ابزار
check_command() {
  if ! command -v "$1" &>/dev/null; then
    case "$1" in
      dig) install_command "dig" "dnsutils" ;;
      whois) install_command "whois" "whois" ;;
      curl) install_command "curl" "curl" ;;
      ping) install_command "ping" "iputils-ping" ;;
    esac
  fi
}

# چک کردن ابزارهای لازم
for cmd in dig whois curl ping; do
  check_command "$cmd"
done

# تابع تست HTTP/HTTPS
check_http() {
  proto="$1"
  url="${proto}://$DOMAIN"
  CONNECT_TIMEOUT=5
  MAX_TIME=15

  echo -e "${YELLOW}[+] ${proto^^} Status and Response Time:${NC}" | tee -a "$OUTPUT_FILE"

  result=$(curl -I -L --connect-timeout $CONNECT_TIMEOUT --max-time $MAX_TIME -s -o /dev/null -w "HTTP Status: %{http_code}\nTime: %{time_total}s\n" "$url" 2>&1)
  exit_code=$?

  if [ $exit_code -eq 0 ]; then
    echo "$result" | tee -a "$OUTPUT_FILE"
  else
    echo -e "${RED}[-] $proto request failed or timed out.${NC}" | tee -a "$OUTPUT_FILE"
  fi
  echo "" >> "$OUTPUT_FILE"
}

# اجرای بنر
banner

echo "Gathering info for $DOMAIN"
echo "===========================" > "$OUTPUT_FILE"

# گرفتن IP
echo -e "${YELLOW}[+] IP Address:${NC}" | tee -a "$OUTPUT_FILE"
dig +short "$DOMAIN" | tee -a "$OUTPUT_FILE" || echo "Failed" | tee -a "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# رکوردهای DNS
echo -e "${YELLOW}[+] DNS Records:${NC}" | tee -a "$OUTPUT_FILE"
dig "$DOMAIN" ANY +noall +answer | tee -a "$OUTPUT_FILE" || echo "Failed" | tee -a "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# WHOIS
echo -e "${YELLOW}[+] WHOIS Info:${NC}" | tee -a "$OUTPUT_FILE"
whois "$DOMAIN" 2>/dev/null | head -n 20 | tee -a "$OUTPUT_FILE" || echo "Failed" | tee -a "$OUTPUT_FILE"
echo "" >> "$OUTPUT_FILE"

# وضعیت HTTP و HTTPS
check_http http
check_http https

# پینگ
echo -e "${YELLOW}[+] Ping Response:${NC}" | tee -a "$OUTPUT_FILE"
ping -c 4 "$DOMAIN" | tee -a "$OUTPUT_FILE" || echo "Ping failed" | tee -a "$OUTPUT_FILE"

echo "===========================" >> "$OUTPUT_FILE"
echo -e "${GREEN}Info gathered and saved in $OUTPUT_FILE${NC}"
