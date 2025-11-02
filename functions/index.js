// const { onDocumentDeleted } = require('firebase-functions/v2/firestore');
// const { initializeApp } = require('firebase-admin/app');
// const { getStorage } = require('firebase-admin/storage');
const {onSchedule} = require('firebase-functions/v2/scheduler');
const admin = require('firebase-admin');

// exports.deleteImages = onDocumentDeleted(
//   {
//     document: 'place_lists/{uid}/places/{placeId}',
//   },
//   async (event) => {
//     const data = event.data.data();
//     const imagePath = data?.imagePath;
    
//     if (!imagePath) {
//       console.log('No image path found');
//       return;
//     }
    
//     try {
//       const bucket = getStorage().bucket();
//       await bucket.file(imagePath).delete();
//       console.log('Image deleted successfully:', imagePath);
//     } catch (error) {
//       console.error('Error deleting image:', error);
//     }
//   }
// );


admin.initializeApp();

const db = admin.firestore();
const storage = admin.storage();

// Run every night at 2 AM
exports.cleanupOrphanedImages = onSchedule(
  {
    schedule: '0 2 * * *', // Cron format: minute hour day month dayOfWeek
    timeZone: 'America/Chicago', // Set your timezone
  },
  async (event) => {
    console.log('Starting orphaned image cleanup...');
    
    try {
      // Get all users
      const usersSnapshot = await db.collection('place_lists').get();
      
      for (const userDoc of usersSnapshot.docs) {
        const uid = userDoc.id;
        console.log(`Checking user: ${uid}`);
        
        // Get all place documents for this user
        const placesSnapshot = await db
          .collection('place_lists')
          .doc(uid)
          .collection('places')
          .get();
        
        // Collect all valid image paths from Firestore
        const validImagePaths = new Set();
        placesSnapshot.forEach(doc => {
          const imagePath = doc.data().imagePath;
          if (imagePath) {
            validImagePaths.add(imagePath);
          }
        });
        
        console.log(`Found ${validImagePaths.size} valid images for user ${uid}`);
        
        // List all files in storage for this user
        const bucket = storage.bucket();
        const [files] = await bucket.getFiles({
          prefix: `place_images/${uid}/`
        });
        
        // Check each file in storage
        for (const file of files) {
          const filePath = file.name;
          
          // Skip if it's just the folder itself
          if (filePath.endsWith('/')) continue;
          
          // If the file is not in our valid set, delete it
          if (!validImagePaths.has(filePath)) {
            console.log(`Deleting orphaned image: ${filePath}`);
            await file.delete();
          }
        }
      }
      
      console.log('Cleanup completed successfully');
      return null;
      
    } catch (error) {
      console.error('Error during cleanup:', error);
      throw error;
    }
  }
);