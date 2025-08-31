// main.js (или используешь из Dart через ссылку)
import CryptographyWorker from './handlers/cryptography_worker?worker';

const worker = new CryptographyWorker();

worker.onmessage = (e) => {
  console.log('Worker result:', e.data);
};

// worker.postMessage({
//   command: 'hash_data',
//   data: "1111",
// });

worker.postMessage({
  command: 'generate_data',
  data: { pin: '1234', userID: 'some_id' },
});

// worker.postMessage({
//   command: 'decrypt',
//   data: {
//     encrypted: "1fb13922f872e2afd82046c70631af16:a390040620352e21202e158b895d20fc:880b284d3cae71668869df26252d6ee04e8264a4bad9c89332acc22fc207f1f99fc8731d78dba0fb25bb045936a4bf11f9c25592190721dcd6ae2a65a593e398c2b8432eee88c92cb5a84389cf3fc1abf0350bfcc481d2ba5bc37644d711267d13c4da8127fedc586dfb4660c626e4629d6e181dbe110e793e99d22eafb3c212cb93655c8f2eb1248815726280e618a22cfeb28f571baf00842d9a6920a39f239e072eceb8cb74a226db0e1ee32a7708b76db5f3fc7177518a1a6087319a3e252cf6a87c9c09d91d70362e",
//     edPublicKey: "5fb67dcb99089b3c4b900d23bc044fb7a48b0a63530161cf9c6c3e9fdd7e0600",
//     xPrivateKey: "d7de4f6367ac3e4984ac50c6d1db69707175404c42dd84875bbf9b84454003d4",
//     xPublicKey: "4971c88fd7b597956f1e1dd7882b07d9b2fb10d66e6db3668381f4e224f4ef51",
//     // userID: "t30ds4UFe5OvjWpBwt3DX91L5tw1",
//     key: null,
//   },
// });

worker.postMessage({
  command: 'generate_data',
  data: {
    seedPhrase: "hungry similar swing damp lobster also suspect cry share swap river drill",
    pin: "1234",
    userID: "U0sZd0fHzWcgb1zHAjNFLijV3Tp1",
  },
});

worker.postMessage({
  command: 'encrypt',
  data: {
    message: 'hungry similar swing damp lobster also suspect cry share swap river drill',
    privateKey: "cd192d961017fe61120f977b117dd19d015af92faecf08e32898555428891207",
    key: null,
    xPrivateKey: "d7de4f6367ac3e4984ac50c6d1db69707175404c42dd84875bbf9b84454003d4",
    xPublicKey: "4971c88fd7b597956f1e1dd7882b07d9b2fb10d66e6db3668381f4e224f4ef51",
    userID: "U0sZd0fHzWcgb1zHAjNFLijV3Tp1",
  },
});

// worker.postMessage({
//   command: 'decrypt',
//   data: {
//     encrypted: {
//       iv: 'afb7dbac6c0cb77832a5bb2237dbe532',
//       tag: '9046ad372c62b55828af8d4d11609cd6',
//       encrypted: '4df9eea24d2bf1aedb19fc622bd81dd39a967023b0cc5b5ecf515f2189933155d8877010469e25d61d6d9fd6bcc1639c8bb86fa635a11ba1eb98de7d400e0861610aa37d0c97d11f1821423652d18e86bb4a78a35c95102dbbbf3773563029445e8f9c784e99a42a390b9c8922f573761ca912a654b8df735247384a70c809f42dab98275913ac893ccc33643108',
//     },
//     publicKey: "9bff77f18255342fb626918481ba39e43844c6b9e6cb1dc67fe56e12ba1b28a0",
//     key: "03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4",
//   },
// });

worker.postMessage({
  command: 'generate_shared_key',
  data: {
    userIDs: "U0sZd0fHzWcgb1zHAjNFLijV3Tp1_2hH1cwCBp3MYbCzOqtn86X3xV572",
    publicKey: "7eb875598a3f5895a63c96b73d8a17848a5225aa544a59884b5f5066c4ed5e6e",
    privateKey: "6a47aaaddb0b36f41e366f6b0a47069e06fbe1b927459c54896cef098eea677f",
  },
});
