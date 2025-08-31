importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/9.10.0/firebase-messaging-compat.js");

firebase.initializeApp({
    //   apiKey: 'xxx',
    //   appId: 'xxx,
    //   messagingSenderId: 'xxx',
    //   projectId: 'xxx',
    //   authDomain: 'xxx',
    //   databaseURL:'xxx',
    //   storageBucket: 'xxx',
    //   measurementId: 'xxx',
    apiKey: "AIzaSyAJLU1P4B6vkkJXXAmxYM0omz570e7-mTs",
    authDomain: "social-network-90106.firebaseapp.com",
    databaseURL: "https://social-network-90106-default-rtdb.firebaseio.com",
    projectId: "social-network-90106",
    storageBucket: "social-network-90106.firebasestorage.app",
    messagingSenderId: "496738673476",
    appId: "1:496738673476:web:2096ee374b5424b83fed11",
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
    console.log("onBackgroundMessage", m);
});