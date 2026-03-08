#!/bin/bash
# HealthNest Backup Script

BACKUP_DIR="/run/media/basar/Others/health_nest_backups"
DATE=$(date +%Y%m%d_%H%M%S)

mkdir -p "$BACKUP_DIR"

echo "🔄 Creating backup..."

# Backup important files
cp /home/basar/health_nest/.env "$BACKUP_DIR/.env_$DATE"
cp /home/basar/health_nest/pubspec.yaml "$BACKUP_DIR/pubspec_$DATE.yaml"
cp /home/basar/health_nest/firebase.json "$BACKUP_DIR/firebase_$DATE.json"

# Create full project backup (without build folders)
tar -czf "$BACKUP_DIR/health_nest_full_$DATE.tar.gz" \
  --exclude='build' \
  --exclude='node_modules' \
  --exclude='.dart_tool' \
  /home/basar/health_nest

echo "✅ Backup completed at: $BACKUP_DIR"
ls -lh "$BACKUP_DIR" | tail -5
