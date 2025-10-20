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
