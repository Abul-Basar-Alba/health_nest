#!/bin/bash

# Get Firebase token
echo "Getting Firebase auth token..."
TOKEN=$(firebase login:ci --no-localhost 2>&1 | grep -oP '1//[^ ]+' | head -1)

if [ -z "$TOKEN" ]; then
  echo "Using existing firebase login..."
  TOKEN=$(cat ~/.config/firebase/token 2>/dev/null)
fi

PROJECT_ID="healthnest-ae7bb"

# Create bump_photos index
echo "Creating bump_photos index..."
curl -X POST \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/collectionGroups/bump_photos/indexes" \
  -H "Authorization: Bearer $(firebase login:ci --no-localhost 2>&1 | tail -1)" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": [
      {"fieldPath": "userId", "order": "ASCENDING"},
      {"fieldPath": "pregnancyId", "order": "ASCENDING"},
      {"fieldPath": "week", "order": "ASCENDING"}
    ]
  }'

echo ""
echo "Creating symptom_logs index..."
curl -X POST \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/collectionGroups/symptom_logs/indexes" \
  -H "Authorization: Bearer $(firebase login:ci --no-localhost 2>&1 | tail -1)" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": [
      {"fieldPath": "pregnancyId", "order": "ASCENDING"},
      {"fieldPath": "logDate", "order": "DESCENDING"}
    ]
  }'

echo ""
echo "Creating kick_counts index..."
curl -X POST \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/collectionGroups/kick_counts/indexes" \
  -H "Authorization: Bearer $(firebase login:ci --no-localhost 2>&1 | tail -1)" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": [
      {"fieldPath": "pregnancyId", "order": "ASCENDING"},
      {"fieldPath": "startTime", "order": "DESCENDING"}
    ]
  }'

echo ""
echo "Creating contractions index..."
curl -X POST \
  "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/collectionGroups/contractions/indexes" \
  -H "Authorization: Bearer $(firebase login:ci --no-localhost 2>&1 | tail -1)" \
  -H "Content-Type: application/json" \
  -d '{
    "fields": [
      {"fieldPath": "pregnancyId", "order": "ASCENDING"},
      {"fieldPath": "startTime", "order": "DESCENDING"}
    ]
  }'

echo ""
echo "Done! Indexes are being created. This may take 1-2 minutes."
