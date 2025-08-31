window.ff_trigger_firebase_app_check = async (callback) => {
    console.debug("Initializing Firebase firebase_app_check");
    callback(await import("https://www.gstatic.com/firebasejs/11.5.0/firebase-app-check.js"));
  };
