window.ff_trigger_firebase_firestore = async (callback) => {
    console.debug("Initializing Firebase firebase_firestore");
    callback(await import("https://www.gstatic.com/firebasejs/11.5.0/firebase-firestore.js"));
  };
