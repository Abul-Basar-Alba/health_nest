#!/usr/bin/env python3
"""
Create Firestore composite indexes programmatically
"""

import subprocess
import json
import sys

def run_command(cmd):
    """Run shell command and return output"""
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        return result.stdout.strip(), result.stderr.strip(), result.returncode
    except Exception as e:
        return "", str(e), 1

def get_access_token():
    """Get Firebase access token"""
    # Try to get token from firebase CLI
    cmd = "firebase login:ci --no-localhost 2>&1 | tail -1"
    stdout, stderr, code = run_command(cmd)
    
    if code == 0 and stdout:
        return stdout.strip()
    
    # Alternative: use gcloud
    cmd = "gcloud auth print-access-token 2>/dev/null"
    stdout, stderr, code = run_command(cmd)
    
    if code == 0 and stdout:
        return stdout.strip()
    
    return None

def create_index(collection_group, fields, project_id="healthnest-ae7bb"):
    """Create a Firestore composite index"""
    
    # Build fields JSON
    fields_json = []
    for field in fields:
        field_config = {"fieldPath": field["path"]}
        if field.get("order"):
            field_config["order"] = field["order"]
        if field.get("arrayConfig"):
            field_config["arrayConfig"] = field["arrayConfig"]
        fields_json.append(field_config)
    
    index_data = {
        "fields": fields_json
    }
    
    # Use firebase CLI to deploy
    print(f"\n📝 Creating index for {collection_group}...")
    print(f"   Fields: {', '.join([f'{f['path']} ({f.get('order', 'N/A')})' for f in fields])}")
    
    # We'll use the firestore.indexes.json file
    return True

def main():
    """Main function"""
    print("=" * 70)
    print("🔥 Firestore Composite Index Creator")
    print("=" * 70)
    
    # Define indexes
    indexes = [
        {
            "collection": "bump_photos",
            "fields": [
                {"path": "userId", "order": "ASCENDING"},
                {"path": "pregnancyId", "order": "ASCENDING"},
                {"path": "week", "order": "ASCENDING"}
            ]
        },
        {
            "collection": "symptom_logs",
            "fields": [
                {"path": "pregnancyId", "order": "ASCENDING"},
                {"path": "logDate", "order": "DESCENDING"}
            ]
        },
        {
            "collection": "kick_counts",
            "fields": [
                {"path": "pregnancyId", "order": "ASCENDING"},
                {"path": "startTime", "order": "DESCENDING"}
            ]
        },
        {
            "collection": "contractions",
            "fields": [
                {"path": "pregnancyId", "order": "ASCENDING"},
                {"path": "startTime", "order": "DESCENDING"}
            ]
        }
    ]
    
    print("\n📋 Indexes to create:")
    for idx in indexes:
        print(f"   • {idx['collection']}")
        for field in idx['fields']:
            print(f"     - {field['path']} ({field['order']})")
    
    print("\n" + "=" * 70)
    print("⚠️  IMPORTANT INSTRUCTIONS:")
    print("=" * 70)
    print("""
Since Firebase CLI has conflicts, please create indexes manually:

METHOD 1 - Firebase Console (EASIEST):
1. Open: https://console.firebase.google.com/project/healthnest-ae7bb/firestore/indexes

2. Click "Create Index" button

3. For bump_photos index, configure:
   - Collection ID: bump_photos
   - Add fields:
     * userId → Ascending
     * pregnancyId → Ascending  
     * week → Ascending
   - Query scope: Collection
   - Click CREATE

4. Repeat for other indexes (symptom_logs, kick_counts, contractions)

METHOD 2 - From Error URL (FASTEST):
1. Run the Flutter app
2. Go to Pregnancy Tracker → Bump Photos
3. The console will show an error with a clickable URL
4. Click the URL → it auto-creates the index
5. Wait 1-2 minutes

Current firestore.indexes.json file is already updated with all indexes.
The issue is that some indexes already exist in Firebase, causing 409 conflicts.

""")
    
    print("=" * 70)
    print("✅ Index configuration is ready in firestore.indexes.json")
    print("📖 Full guide available in: FIRESTORE_INDEX_SETUP.md")
    print("=" * 70)

if __name__ == "__main__":
    main()
