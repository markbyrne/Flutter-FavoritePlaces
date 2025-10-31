const { onDocumentDeleted } = require('firebase-functions/v2/firestore');
const { initializeApp } = require('firebase-admin/app');
const { getStorage } = require('firebase-admin/storage');

initializeApp();

exports.deleteImages = onDocumentDeleted(
  {
    document: 'place_lists/{uid}/places/{placeId}',
  },
  async (event) => {
    const data = event.data.data();
    const imagePath = data?.imagePath;
    
    if (!imagePath) {
      console.log('No image path found');
      return;
    }
    
    try {
      const bucket = getStorage().bucket();
      await bucket.file(imagePath).delete();
      console.log('Image deleted successfully:', imagePath);
    } catch (error) {
      console.error('Error deleting image:', error);
    }
  }
);