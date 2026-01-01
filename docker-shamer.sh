#!/usr/bin/env bash
# Docker Image Shamer - Because your images are embarrassing
# Usage: ./docker-shamer.sh [image_name]

set -e

# Color codes for maximum shame visibility
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Check if Docker is even installed (it probably isn't on your prod server)
if ! command -v docker &> /dev/null; then
    echo -e "${RED}Docker not found. Are you running this on a toaster?${NC}"
    exit 1
fi

# Did you forget to provide an image? Typical.
if [ $# -eq 0 ]; then
    echo -e "${YELLOW}Usage: $0 [image_name]${NC}"
    echo -e "${YELLOW}Example: $0 nginx:latest${NC}"
    echo -e "${RED}Or just keep running bloated images, I don't care.${NC}"
    exit 1
fi

IMAGE="$1"

# Pull the image (if it exists, which it probably doesn't in your cache)
echo -e "${YELLOW}Pulling $IMAGE...${NC}"
if ! docker pull "$IMAGE" > /dev/null 2>&1; then
    echo -e "${RED}Failed to pull $IMAGE. Did you make it up?${NC}"
    exit 1
fi

# Get image size (prepare for shame)
echo -e "\n${YELLOW}=== IMAGE SHAMING IN PROGRESS ===${NC}"

SIZE=$(docker image inspect "$IMAGE" --format='{{.Size}}')
SIZE_MB=$((SIZE / 1024 / 1024))

# Size shaming logic
if [ $SIZE_MB -gt 1000 ]; then
    echo -e "${RED}🚨 OBESE: ${SIZE_MB}MB - Did you package the entire OS?${NC}"
elif [ $SIZE_MB -gt 500 ]; then
    echo -e "${YELLOW}📦 CHONKY: ${SIZE_MB}MB - Did you forget to .dockerignore node_modules?${NC}"
else
    echo -e "${GREEN}✅ ACCEPTABLE: ${SIZE_MB}MB - Not terrible, but could be better${NC}"
fi

# Check for outdated images (because you never update anything)
CREATED=$(docker image inspect "$IMAGE" --format='{{.Created}}' | cut -d'T' -f1)
TODAY=$(date +%Y-%m-%d)
DAYS_OLD=$(( ($(date -d "$TODAY" +%s) - $(date -d "$CREATED" +%s)) / 86400 ))

if [ $DAYS_OLD -gt 365 ]; then
    echo -e "${RED}🦖 ANCIENT: ${DAYS_OLD} days old - This image remembers dial-up${NC}"
elif [ $DAYS_OLD -gt 180 ]; then
    echo -e "${YELLOW}📅 DUSTY: ${DAYS_OLD} days old - Time for an update, grandpa${NC}"
else
    echo -e "${GREEN}📅 FRESH: ${DAYS_OLD} days old - Actually maintained, surprising${NC}"
fi

# Quick vulnerability check (because security is optional, right?)
echo -e "\n${YELLOW}Running trivial security check...${NC}"
if docker image inspect "$IMAGE" --format='{{.Config.User}}' | grep -q 'root'; then
    echo -e "${RED}🔓 RUNS AS ROOT - Because privilege escalation is a feature${NC}"
else
    echo -e "${GREEN}🔒 NOT ROOT - Someone actually read security docs${NC}"
fi

# Final verdict
echo -e "\n${YELLOW}=== SHAME LEVEL ASSESSMENT ===${NC}"
SHAME_SCORE=0
[ $SIZE_MB -gt 500 ] && SHAME_SCORE=$((SHAME_SCORE + 1))
[ $DAYS_OLD -gt 180 ] && SHAME_SCORE=$((SHAME_SCORE + 1))
docker image inspect "$IMAGE" --format='{{.Config.User}}' | grep -q 'root' && SHAME_SCORE=$((SHAME_SCORE + 1))

case $SHAME_SCORE in
    0) echo -e "${GREEN}🌟 SHAME-FREE - Almost suspiciously good${NC}";;
    1) echo -e "${YELLOW}😐 MILD SHAME - Could be worse, but shouldn't be${NC}";;
    2) echo -e "${YELLOW}🤨 MODERATE SHAME - Your colleagues are judging you${NC}";;
    3) echo -e "${RED}🔥 MAXIMUM SHAME - Delete this and start over${NC}";;
esac

echo -e "\n${YELLOW}Remember: Shame is the first step toward improvement. Maybe.${NC}"
