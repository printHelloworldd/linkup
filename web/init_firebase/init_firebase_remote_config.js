window.ff_trigger_firebase_remote_config = async (callback) => {
    console.debug("Initializing Firebase firebase_remote_config");
    callback(await import("https://www.gstatic.com/firebasejs/11.5.0/firebase-remote-config.js"));
  };
