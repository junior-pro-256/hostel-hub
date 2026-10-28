// Uploads hostels.json to the Firestore `hostels` collection in safe 500-item batches.
// Needs backend/seed/serviceAccountKey.json
const fs = require('fs');
const path = require('path');
const admin = require('firebase-admin');
const hostels = require('./hostels.json');

const keyPath = path.join(__dirname, 'serviceAccountKey.json');
if (!fs.existsSync(keyPath)) {
  console.error(
    'Missing backend/seed/serviceAccountKey.json\n' +
      'Firebase console -> Project settings -> Service accounts -> Generate new private key,\n' +
      'then save the downloaded file with that exact name in this folder.'
  );
  process.exit(1);
}

const serviceAccount = require(keyPath);
admin.initializeApp({ credential: admin.credential.cert(serviceAccount) });
console.log('Using Firebase project:', serviceAccount.project_id);
const db = admin.firestore();

async function main() {
  const BATCH_LIMIT = 500;
  let batch = db.batch();
  let operationCount = 0;
  let totalCommitted = 0;

  for (let index = 0; index < hostels.length; index++) {
    const hostel = hostels[index];
    const { id, ...data } = hostel;
    // Use a custom ID if provided, otherwise auto-generate one
    const docRef = id ? db.collection('hostels').doc(id) : db.collection('hostels').doc();
    batch.set(docRef, { ...data, order: index });

    operationCount++;
    totalCommitted++;

    // When batch hits 500, commit it and start a new one
    if (operationCount === BATCH_LIMIT) {
      await batch.commit();
      batch = db.batch();
      operationCount = 0;
    }
  }

  // Commit any remaining operations in the final batch
  if (operationCount > 0) {
    await batch.commit();
  }

  console.log(`Successfully seeded ${totalCommitted} hostels.`);
}

main().catch((err) => {
  console.error(err.message || err);
  process.exit(1);
});
