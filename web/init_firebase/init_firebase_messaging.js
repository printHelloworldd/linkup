window.ff_trigger_firebase_messaging = async (callback) => {
    console.debug("Initializing Firebase firebase_messaging");
    callback(await import("https://www.gstatic.com/firebasejs/11.5.0/firebase-messaging.js"));
  };
