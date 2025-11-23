#!/usr/bin/env bash
#
# 🥚 Kubernetes Easter Egg Hunt
# Run this script to discover a surprise!
#

set -euo pipefail

# Colors for fun output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
NC='\033[0m' # No Color

clear

echo -e "${CYAN}"
cat << "EOF"
K   K  U   U  B B   E E E E  R R R   N   N  E E E E  T T T  E E E E  SSS 
K  K   U   U  B  B  E        R   R   NN  N  E        T       E        S   
KKK    U   U  BBB   EEE      RRR     N N N  EEE      TTT     EEE      SSS 
K  K   U   U  B  B  E        R  R    N  NN  E        T       E           S
K   K   UUU   B B   E E E E  R   R   N   N  E E E E  T       E E E E  SSS 
EOF
echo -e "${NC}"

echo -e "${YELLOW}🎉 Congratulations! You found the Easter Egg! 🎉${NC}\n"

sleep 1

echo -e "${GREEN}Checking cluster status...${NC}"
sleep 0.5

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${WHITE}Pod Status:${NC}"
echo -e "${GREEN}  ✅ All pods are running perfectly!${NC}"
echo -e "${WHITE}Node Status:${NC}"
echo -e "${GREEN}  ✅ All nodes are healthy and ready!${NC}"
echo -e "${WHITE}Deployment Status:${NC}"
echo -e "${GREEN}  ✅ All deployments are up-to-date!${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

sleep 1

echo -e "${MAGENTA}🐳 Here's a special message from your cluster:${NC}\n"

echo -e "${CYAN}    \"Containers may contain things,${NC}"
echo -e "${CYAN}     but they'll never contain our spirits!\"${NC}\n"

sleep 1

echo -e "${YELLOW}💡 Fun Kubernetes Fact:${NC}"
FACTS=(
  "Kubernetes comes from the Greek word 'κυβερνήτης' meaning 'helmsman' or 'pilot'"
  "The original codename for Kubernetes was 'Project Seven' - named after Star Trek's Borg character Seven of Nine"
  "Kubernetes was originally designed by Google based on their internal system called 'Borg'"
  "The first version of Kubernetes was released in 2015, and it was 15,000+ lines of Go code"
  "The Kubernetes logo has 7 sides because of the 'Project Seven' reference"
)

RANDOM_FACT=${FACTS[$RANDOM % ${#FACTS[@]}]}
echo -e "${WHITE}  ${RANDOM_FACT}${NC}\n"

sleep 1

echo -e "${GREEN}🎁 Special Commands to Try:${NC}"
echo -e "${CYAN}  kubectl get pods --all-namespaces | grep -i egg${NC}"
echo -e "${CYAN}  kubectl describe node $(hostname) | grep -i chocolate${NC}"
echo -e "${CYAN}  kubectl logs -n kube-system -l k8s-app=kube-proxy | tail -1${NC}\n"

echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${YELLOW}         Have a wonderful day! 🌟${NC}"
echo -e "${RED}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}\n"

# Animated "deploying" message
echo -e "${GREEN}Deploying smiles..."
for i in {1..3}; do
  echo -n "."
  sleep 0.3
done
echo -e " ${GREEN}✅ Successfully deployed!${NC}\n"

echo -e "${MAGENTA}💝 Made with ❤️  by the team${NC}"
echo -e "${CYAN}   Keep calm and kubectl on! 🚀${NC}\n"

