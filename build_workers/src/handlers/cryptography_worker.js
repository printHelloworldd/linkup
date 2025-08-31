import { generateData, encrypt, decrypt, generateSharedKey } from "./crypto_logic.ts";

self.postMessage(JSON.stringify({ status: 'ready' }));

self.addEventListener('error', (e) => {
    self.postMessage(JSON.stringify({ status: 'error', message: e.message }));
});

self.onmessage = async function (e) {
    console.log('[worker] Received message:', e.data);

    try {
        const { command, data } = e.data;

        if (command === "generate_data") {
            console.log('[worker] Command is generate_data');

            let result = await generateData(data);

            // Отправка результата в основной поток
            self.postMessage(JSON.stringify(result));

            console.log('[worker] Sent success message');

        } else if (command === "encrypt") {
            let result = encrypt(data);

            self.postMessage(JSON.stringify(result));
        } else if (command === "decrypt") {
            let result = decrypt(data);

            self.postMessage(JSON.stringify(result));
        } else if (command === "generate_shared_key") {
            let result = generateSharedKey(data);

            self.postMessage(JSON.stringify(result));
        }
    } catch (error) {
        self.postMessage(JSON.stringify({ status: 'error', message: error.message }));
    }
};