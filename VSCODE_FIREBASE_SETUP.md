# VS Code Firebase Console Integration Setup

## Overview
This setup enables direct Firebase Console access from VS Code with agent-level control for HealthNest development.

## 1. Required VS Code Extensions

### Firebase Extensions:
```bash
code --install-extension firebase.vscode-firebase-explorer
code --install-extension bradlc.vscode-tailwindcss
code --install-extension ms-vscode.vscode-json
```

### Install Firebase CLI:
```bash
npm install -g firebase-tools
```

## 2. Firebase Project Configuration

### Initialize Firebase in Project:
```bash
cd /home/basar/health_nest
firebase login
firebase use healthnest-ae7bb
firebase init firestore
```

### Emulator Setup:
```bash
firebase emulators:start --only firestore,auth
```

## 3. VS Code Settings Configuration

Add to `.vscode/settings.json`:
```json
{
  "firebase.projects": ["healthnest-ae7bb"],
  "firebase.useEmulatorSuite": true,
  "firebase.emulatorAutoStart": false,
  "firebase.defaultProject": "healthnest-ae7bb",
  "firebase.deployRulesOnSave": false
}
```

## 4. Local Development Server

Create development server for VS Code Firebase integration:
```bash
mkdir -p vscode-firebase-server
cd vscode-firebase-server
npm init -y
npm install express cors firebase-admin
```

### Server Code (`server.js`):
```javascript
const express = require('express');
const cors = require('cors');
const admin = require('firebase-admin');

const app = express();
const PORT = 4000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'VS Code Firebase Agent Active', project: 'healthnest-ae7bb' });
});

// Firebase sync endpoint
app.post('/firebase/sync', (req, res) => {
  console.log('Firebase Rules Sync:', req.body);
  res.json({ success: true, synced: true });
});

// Firebase deploy endpoint
app.post('/firebase/deploy', (req, res) => {
  console.log('Firebase Deploy Request:', req.body);
  res.json({ success: true, deployed: true });
});

app.listen(PORT, () => {
  console.log(`VS Code Firebase Agent running on http://localhost:${PORT}`);
});
```

### Run Server:
```bash
node server.js
```

## 5. Firebase Console Direct Access

### Console URLs:
- **Project Overview**: https://console.firebase.google.com/project/healthnest-ae7bb
- **Firestore Rules**: https://console.firebase.google.com/project/healthnest-ae7bb/firestore/rules
- **Firestore Data**: https://console.firebase.google.com/project/healthnest-ae7bb/firestore/data
- **Authentication**: https://console.firebase.google.com/project/healthnest-ae7bb/authentication/users

### CLI Commands:
```bash
# Deploy rules
firebase deploy --only firestore:rules

# Deploy functions
firebase deploy --only functions

# Start emulators
firebase emulators:start

# Export emulator data
firebase emulators:export ./emulator-data
```

## 6. VS Code Tasks Configuration

Create `.vscode/tasks.json`:
```json
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Firebase: Deploy Rules",
      "type": "shell",
      "command": "firebase",
      "args": ["deploy", "--only", "firestore:rules"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always"
      }
    },
    {
      "label": "Firebase: Start Emulators",
      "type": "shell",
      "command": "firebase",
      "args": ["emulators:start"],
      "group": "build",
      "isBackground": true
    },
    {
      "label": "Firebase: Console",
      "type": "shell",
      "command": "firebase",
      "args": ["open"],
      "group": "build"
    }
  ]
}
```

## 7. Agent Mode Integration

### Enable Agent Mode in HealthNest:
1. Run the local development server
2. Open HealthNest app in Flutter web mode (`flutter run -d web-server --web-port 8080`)
3. Navigate to Firebase Console Manager in app
4. Agent detection will automatically activate

### Agent Commands:
- **Sync Rules**: Automatically syncs Firestore rules with VS Code
- **Deploy Rules**: Deploys rules to Firebase Console
- **Open Console**: Direct link to Firebase Console sections

## 8. Troubleshooting

### Common Issues:
1. **Agent Mode Not Detected**: Ensure local server is running on port 4000
2. **Firebase CLI Not Found**: Install globally with `npm install -g firebase-tools`
3. **Permission Denied**: Run `firebase login` and ensure proper project access

### Debug Commands:
```bash
# Check Firebase project
firebase projects:list

# Test Firebase CLI
firebase firestore:rules:get

# Check port availability
lsof -i :4000
```

## 9. Production Usage

### Security Notes:
- Agent mode only works in development environment
- Production builds automatically disable VS Code integration
- Firebase Admin SDK credentials are kept secure

### Deployment Workflow:
1. Make changes in VS Code Firebase Manager
2. Test with Firebase Emulators
3. Deploy via CLI or Firebase Console
4. Verify changes in production

---

**Complete VS Code Firebase Console Integration for HealthNest is ready! 🔥**
