window.ff_trigger_firebase_database = async (callback) => {
    console.debug("Initializing Firebase firebase_database");
    callback(await import("https://www.gstatic.com/firebasejs/11.5.0/firebase-database.js"));
  };
