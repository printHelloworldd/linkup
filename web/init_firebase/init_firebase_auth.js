window.ff_trigger_firebase_auth = async (callback) => {
    console.debug("Initializing Firebase firebase_auth");
    callback(await import("https://www.gstatic.com/firebasejs/11.5.0/firebase-auth.js"));
  };
