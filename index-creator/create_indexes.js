const admin = require('firebase-admin');
const { execSync } = require('child_process');

// Initialize Firebase Admin SDK
const PROJECT_ID = 'healthnest-ae7bb';

console.log('🔥 Firestore Index Creator for HealthNest');
console.log('='.repeat(50));
console.log('');

// Get service account from Firebase CLI
try {
  console.log('🔐 Initializing Firebase Admin SDK...');
  
  // Use application default credentials
  admin.initializeApp({
    projectId: PROJECT_ID,
    credential: admin.credential.applicationDefault()
  });
  
  console.log('✅ Firebase Admin initialized');
} catch (error) {
  console.log('⚠️  Could not use application default credentials');
  console.log('   Trying alternative method...');
  
  try {
    // Alternative: use refresh token from Firebase CLI
    const firebaseConfig = require('../firebase.json');
    admin.initializeApp({
      projectId: PROJECT_ID
    });
    console.log('✅ Firebase Admin initialized');
  } catch (err) {
    console.error('❌ Error initializing Firebase Admin:', err.message);
    console.log('');
    console.log('Please run: firebase login');
    process.exit(1);
  }
}

const firestore = admin.firestore();

async function createIndexes() {
  console.log('');
  console.log('📋 Indexes to create:');
  console.log('');
  
  const indexes = [
    {
      collection: 'bump_photos',
      fields: [
        { fieldPath: 'userId', order: 'ASCENDING' },
        { fieldPath: 'pregnancyId', order: 'ASCENDING' },
        { fieldPath: 'week', order: 'ASCENDING' }
      ]
    },
    {
      collection: 'symptom_logs',
      fields: [
        { fieldPath: 'pregnancyId', order: 'ASCENDING' },
        { fieldPath: 'logDate', order: 'DESCENDING' }
      ]
    },
    {
      collection: 'kick_counts',
      fields: [
        { fieldPath: 'pregnancyId', order: 'ASCENDING' },
        { fieldPath: 'startTime', order: 'DESCENDING' }
      ]
    },
    {
      collection: 'contractions',
      fields: [
        { fieldPath: 'pregnancyId', order: 'ASCENDING' },
        { fieldPath: 'startTime', order: 'DESCENDING' }
      ]
    }
  ];

  for (const index of indexes) {
    console.log(`📝 ${index.collection}`);
    for (const field of index.fields) {
      console.log(`   - ${field.fieldPath} (${field.order})`);
    }
  }

  console.log('');
  console.log('='.repeat(50));
  console.log('⚠️  MANUAL STEPS REQUIRED:');
  console.log('='.repeat(50));
  console.log('');
  console.log('Unfortunately, Firebase Admin SDK cannot create indexes programmatically.');
  console.log('You must create them via Firebase Console.');
  console.log('');
  console.log('OPTION 1 - Direct Link (RECOMMENDED):');
  console.log('---------------------------------------');
  console.log('1. Run your Flutter app');
  console.log('2. Navigate to: Pregnancy Tracker → Bump Photos');
  console.log('3. The error message will contain a clickable URL');
  console.log('4. Click the URL to auto-create the index');
  console.log('');
  console.log('OPTION 2 - Firebase Console:');
  console.log('---------------------------------------');
  console.log('Go to: https://console.firebase.google.com/project/healthnest-ae7bb/firestore/indexes');
  console.log('');
  console.log('Create each index manually:');
  console.log('');
  
  for (let i = 0; i < indexes.length; i++) {
    const index = indexes[i];
    console.log(`${i + 1}. Collection: ${index.collection}`);
    console.log(`   Fields:`);
    for (const field of index.fields) {
      console.log(`   • ${field.fieldPath} → ${field.order}`);
    }
    console.log('');
  }
  
  console.log('='.repeat(50));
  console.log('✅ firestore.indexes.json is already configured');
  console.log('📖 See FIRESTORE_INDEX_SETUP.md for detailed guide');
  console.log('='.repeat(50));
}

createIndexes().then(() => {
  process.exit(0);
}).catch(error => {
  console.error('Error:', error);
  process.exit(1);
});
