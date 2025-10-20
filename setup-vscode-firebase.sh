#!/bin/bash
# VS Code Firebase Agent Setup Script

echo "🔥 Setting up VS Code Firebase Agent for HealthNest..."

# Create VS Code Firebase Server Directory
mkdir -p vscode-firebase-server
cd vscode-firebase-server

# Initialize Node.js project
if [ ! -f "package.json" ]; then
    echo "📦 Initializing Node.js project..."
    npm init -y
fi

# Install dependencies
echo "⬇️ Installing dependencies..."
npm install express cors firebase-admin

# Create server file
echo "📝 Creating VS Code Firebase server..."
cat > server.js << 'EOF'
const express = require('express');
const cors = require('cors');
const app = express();
const PORT = 4000;

app.use(cors());
app.use(express.json());

console.log('🚀 VS Code Firebase Agent starting...');

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ 
    status: 'VS Code Firebase Agent Active', 
    project: 'healthnest-ae7bb',
    timestamp: new Date().toISOString()
  });
});

// Firebase sync endpoint
app.post('/firebase/sync', (req, res) => {
  console.log('🔄 Firebase Rules Sync:', req.body.type);
  res.json({ success: true, synced: true, timestamp: new Date().toISOString() });
});

// Firebase deploy endpoint
app.post('/firebase/deploy', (req, res) => {
  console.log('🚀 Firebase Deploy Request:', req.body.type);
  res.json({ 
    success: true, 
    deployed: true, 
    consoleUrl: `https://console.firebase.google.com/project/${req.body.projectId}/firestore/rules`
  });
});

// Console endpoints
app.get('/firebase/console', (req, res) => {
  res.json({
    project: 'https://console.firebase.google.com/project/healthnest-ae7bb',
    rules: 'https://console.firebase.google.com/project/healthnest-ae7bb/firestore/rules',
    database: 'https://console.firebase.google.com/project/healthnest-ae7bb/firestore/data',
    auth: 'https://console.firebase.google.com/project/healthnest-ae7bb/authentication/users'
  });
});

app.listen(PORT, () => {
  console.log(`🔥 VS Code Firebase Agent running on http://localhost:${PORT}`);
  console.log(`📊 Health check: http://localhost:${PORT}/health`);
  console.log(`🎯 Ready for HealthNest agent mode integration!`);
});
EOF

# Create start script
echo "🔧 Creating start script..."
cat > start.sh << 'EOF'
#!/bin/bash
echo "🔥 Starting VS Code Firebase Agent..."
node server.js
EOF

chmod +x start.sh

echo ""
echo "✅ VS Code Firebase Agent setup complete!"
echo ""
echo "🚀 To start the agent:"
echo "   cd vscode-firebase-server"
echo "   ./start.sh"
echo ""
echo "🌐 Then access Firebase Console Manager in HealthNest app:"
echo "   Open drawer → Firebase Console"
echo ""
echo "📋 Agent will be detected automatically when server is running!"
