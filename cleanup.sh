#!/bin/bash

# AI Music Generation System Cleanup Script

# Set color codes
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}============================================================${NC}"
echo -e "${BLUE}      AI Music Generation System - Cleanup Tool             ${NC}"
echo -e "${BLUE}============================================================${NC}"
echo

# Default values
DAYS_OLD=7
KEEP_FAVORITES=true
BACKUP=false
DELETE_UPLOADS=false
DRY_RUN=false

# Parse command line options
while [[ $# -gt 0 ]]; do
  case $1 in
    --days=*)
      DAYS_OLD="${1#*=}"
      shift
      ;;
    --no-favorites)
      KEEP_FAVORITES=false
      shift
      ;;
    --backup)
      BACKUP=true
      shift
      ;;
    --delete-uploads)
      DELETE_UPLOADS=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    --help)
      echo "Usage: $0 [options]"
      echo "Options:"
      echo "  --days=N             Delete files older than N days (default: 7)"
      echo "  --no-favorites       Also delete files marked as favorites"
      echo "  --backup             Create a backup before deletion"
      echo "  --delete-uploads     Also delete uploaded files"
      echo "  --dry-run            Show what would be deleted without actually deleting"
      echo "  --help               Show this help message"
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      echo "Use --help for usage information."
      exit 1
      ;;
  esac
done

# Ensure the system is running
if ! docker-compose ps | grep -q "Up"; then
  echo -e "${YELLOW}[WARNING] AI Music Generation System does not appear to be running.${NC}"
  echo -e "${YELLOW}[WARNING] Database operations may fail, but file cleanup can proceed.${NC}"

  read -p "Continue anyway? (y/n) " -n 1 -r
  echo
  if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${RED}[ERROR] Cleanup aborted.${NC}"
    exit 1
  fi
fi

# Show current disk usage
echo -e "${BLUE}Current Disk Usage:${NC}"
echo -e "-------------------"
echo -e "Output Directory: $(du -sh output | cut -f1) ($(find output -type f | wc -l) files)"
echo -e "Uploads Directory: $(du -sh uploads | cut -f1) ($(find uploads -type f | wc -l) files)"
echo -e "Docker Data: $(docker system df --format '{{.Size}}' | head -n 1)"
echo

# Create backup if requested
if [ "$BACKUP" = true ]; then
  echo -e "${YELLOW}[INFO] Creating backup before cleanup...${NC}"
  BACKUP_FILE="music_backup_$(date +%Y%m%d_%H%M%S).tar.gz"

  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would create backup: $BACKUP_FILE${NC}"
  else
    tar -czf "$BACKUP_FILE" output uploads
    echo -e "${GREEN}[SUCCESS] Backup created: $BACKUP_FILE${NC}"
  fi
  echo
fi

# Get list of files to delete from the database (excluding favorites if requested)
if docker-compose ps | grep -q "Up"; then
  echo -e "${YELLOW}[INFO] Finding tracks to clean up from database...${NC}"

  FAVORITES_CLAUSE=""
  if [ "$KEEP_FAVORITES" = true ]; then
    FAVORITES_CLAUSE="AND favorite: false"
  fi

  MONGO_QUERY="db.tracks.find({createdAt: {\$lt: new Date(Date.now() - ${DAYS_OLD} * 24 * 60 * 60 * 1000)} $FAVORITES_CLAUSE}, {filePath: 1}).toArray()"

  FILES_TO_DELETE=$(docker-compose exec -T mongodb mongosh music_generation --quiet --eval "$MONGO_QUERY" | grep filePath | sed 's/.*filePath: "\(.*\)".*/\1/')

  # Count files to delete
  FILE_COUNT=$(echo "$FILES_TO_DELETE" | grep -v "^$" | wc -l)

  echo -e "${YELLOW}[INFO] Found $FILE_COUNT database tracks older than $DAYS_OLD days to delete.${NC}"

  # Delete database entries
  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would delete $FILE_COUNT database entries.${NC}"
  else
    if [ $FILE_COUNT -gt 0 ]; then
      DELETE_QUERY="db.tracks.deleteMany({createdAt: {\$lt: new Date(Date.now() - ${DAYS_OLD} * 24 * 60 * 60 * 1000)} $FAVORITES_CLAUSE})"
      DELETE_RESULT=$(docker-compose exec -T mongodb mongosh music_generation --quiet --eval "$DELETE_QUERY")
      echo -e "${GREEN}[SUCCESS] Deleted entries from database: $DELETE_RESULT${NC}"
    fi
  fi
else
  echo -e "${YELLOW}[WARNING] Database not accessible. Only performing file cleanup.${NC}"
  # Find files by date instead
  FILES_TO_DELETE=$(find output -type f -mtime +$DAYS_OLD)
  FILE_COUNT=$(echo "$FILES_TO_DELETE" | grep -v "^$" | wc -l)
  echo -e "${YELLOW}[INFO] Found $FILE_COUNT files older than $DAYS_OLD days to delete.${NC}"
fi

# Delete actual files
echo -e "${YELLOW}[INFO] Cleaning up output files...${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}[DRY RUN] Would delete the following files:${NC}"
  echo "$FILES_TO_DELETE"
else
  echo "$FILES_TO_DELETE" | while read file; do
    if [ ! -z "$file" ] && [ -f "$file" ]; then
      rm -f "$file"
      echo -e "${GREEN}[DELETED] $file${NC}"
    fi
  done
fi

# Clean up upload files if requested
if [ "$DELETE_UPLOADS" = true ]; then
  echo -e "${YELLOW}[INFO] Cleaning up uploaded files...${NC}"
  UPLOAD_FILES=$(find uploads -type f -mtime +$DAYS_OLD)
  UPLOAD_COUNT=$(echo "$UPLOAD_FILES" | grep -v "^$" | wc -l)

  echo -e "${YELLOW}[INFO] Found $UPLOAD_COUNT uploaded files older than $DAYS_OLD days to delete.${NC}"

  if [ "$DRY_RUN" = true ]; then
    echo -e "${YELLOW}[DRY RUN] Would delete $UPLOAD_COUNT uploaded files.${NC}"
  else
    echo "$UPLOAD_FILES" | while read file; do
      if [ ! -z "$file" ] && [ -f "$file" ]; then
        rm -f "$file"
        echo -e "${GREEN}[DELETED] $file${NC}"
      fi
    done
  fi
fi

# Clean up Docker resources
echo -e "${YELLOW}[INFO] Cleaning up Docker resources...${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}[DRY RUN] Would clean up Docker resources.${NC}"
else
  docker system prune -f > /dev/null
  echo -e "${GREEN}[SUCCESS] Docker resources cleaned up.${NC}"
fi

# Show new disk usage
echo -e "\n${BLUE}New Disk Usage:${NC}"
echo -e "---------------"
echo -e "Output Directory: $(du -sh output | cut -f1) ($(find output -type f | wc -l) files)"
echo -e "Uploads Directory: $(du -sh uploads | cut -f1) ($(find uploads -type f | wc -l) files)"
echo -e "Docker Data: $(docker system df --format '{{.Size}}' | head -n 1)"

echo -e "\n${BLUE}============================================================${NC}"
if [ "$DRY_RUN" = true ]; then
  echo -e "${YELLOW}Dry run completed. No files were deleted.${NC}"
else
  echo -e "${GREEN}Cleanup completed successfully.${NC}"
fi
echo -e "${BLUE}============================================================${NC}"
