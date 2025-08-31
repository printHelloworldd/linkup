window.ff_trigger_firebase_core = async (callback) => {
    console.debug("Initializing Firebase firebase_core");
    callback(await import("https://www.gstatic.com/firebasejs/11.5.0/firebase-app.js"));
};