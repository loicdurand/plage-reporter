// migrate_beaches.js
const admin = require('firebase-admin');

// Remplace par ton fichier JSON de service account (voir Étape 3)
const serviceAccount = require('./serviceAccountKey.json');

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

const db = admin.firestore();
const reports = db.collection('reports');

async function migrateReports() {
  try {
    const snapshot = await reports.get();
    for (const doc of snapshot.docs) {
      const data = doc.data();
      await reports.doc(doc.id).update({
        imagePath: 'placeholder_beach.jpg',
        sargassesLevel: data.hasSargasses === true ? 2 : 0,
        wavesLevel: data.hasWaves === true ? 2 : 0,
        crowdLevel: data.isCrowded === true ? 2 : 0,
        noiseLevel: data.isNoisy === true ? 2 : 0,
        // Supprime les anciens champs
        hasSargasses: admin.firestore.FieldValue.delete(),
        hasWaves: admin.firestore.FieldValue.delete(),
        isCrowded: admin.firestore.FieldValue.delete(),
        isNoisy: admin.firestore.FieldValue.delete(),
      });
      console.log(`Migré : ${data.beachName}`);
    }
    console.log('Migration terminée !');
  } catch (error) {
    console.error('Erreur :', error);
  }
}

migrateReports().then(() => process.exit());