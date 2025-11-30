#!/bin/bash
set -e

PROJECT_ID="healthnest-ae7bb"

echo "🔥 Creating Firestore Indexes for HealthNest"
echo "============================================="
echo ""

# Get Firebase access token
echo "🔐 Getting Firebase access token..."
ACCESS_TOKEN=$(firebase login:ci --no-localhost 2>&1 | tail -1)

if [ -z "$ACCESS_TOKEN" ]; then
    echo "❌ Could not get access token. Please run: firebase login"
    exit 1
fi

echo "✅ Got access token"
echo ""

# Function to create index
create_index() {
    local collection=$1
    local fields=$2
    
    echo "📝 Creating index for: $collection"
    
    RESPONSE=$(curl -s -X POST \
        "https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/collectionGroups/${collection}/indexes" \
        -H "Authorization: Bearer ${ACCESS_TOKEN}" \
        -H "Content-Type: application/json" \
        -d "${fields}")
    
    if echo "$RESPONSE" | grep -q "error"; then
        ERROR_MSG=$(echo "$RESPONSE" | grep -o '"message":"[^"]*"' | cut -d'"' -f4)
        if echo "$ERROR_MSG" | grep -q "already exists"; then
            echo "   ⚠️  Index already exists (skipping)"
        else
            echo "   ❌ Error: $ERROR_MSG"
        fi
    else
        echo "   ✅ Index created successfully"
    fi
    echo ""
}

# Create bump_photos index
create_index "bump_photos" '{
  "fields": [
    {"fieldPath": "userId", "order": "ASCENDING"},
    {"fieldPath": "pregnancyId", "order": "ASCENDING"},
    {"fieldPath": "week", "order": "ASCENDING"}
  ]
}'

# Create symptom_logs index
create_index "symptom_logs" '{
  "fields": [
    {"fieldPath": "pregnancyId", "order": "ASCENDING"},
    {"fieldPath": "logDate", "order": "DESCENDING"}
  ]
}'

# Create kick_counts index
create_index "kick_counts" '{
  "fields": [
    {"fieldPath": "pregnancyId", "order": "ASCENDING"},
    {"fieldPath": "startTime", "order": "DESCENDING"}
  ]
}'

# Create contractions index
create_index "contractions" '{
  "fields": [
    {"fieldPath": "pregnancyId", "order": "ASCENDING"},
    {"fieldPath": "startTime", "order": "DESCENDING"}
  ]
}'

echo "============================================="
echo "✅ All indexes created/verified!"
echo "⏳ Please wait 1-2 minutes for indexes to build"
echo "============================================="
