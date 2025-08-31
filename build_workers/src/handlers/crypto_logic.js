import { x25519, ed25519 } from '@noble/curves/ed25519';
import * as bip39 from 'bip39';
import _sha256 from 'sha256';
import forge from 'node-forge';
import { hkdf } from '@noble/hashes/hkdf.js';
import { sha256 } from '@noble/hashes/sha2.js';
import * as utils from '@noble/hashes/utils';
import { Buffer } from 'buffer';
globalThis.Buffer = Buffer;

const forgeEd25519 = forge.pki.ed25519;

export async function generateData(data) {
    const userID = data.userID;

    let mnemonic = data.seedPhrase;
    let mnemonicEntropy = "";
    if (mnemonic == null) {
        // Generate mnemonic
        const generatedMnemonicData = generateMnemonicData(128);
        mnemonic = generatedMnemonicData.mnemonic;
        mnemonicEntropy = generatedMnemonicData.entropy;
    } else {
        mnemonicEntropy = bip39.mnemonicToEntropy(mnemonic);
    }

    // Генерация ключей
    const xKeypair = generateXKeyPair(mnemonicEntropy, userID);
    const edKeypair = await generateEdKeyPair(mnemonicEntropy, userID);

    // Шифрование сид фразы
    const key = generateSharedAesKey(xKeypair.privateKey, xKeypair.publicKey, userID);

    const signedMnemonic = signData(mnemonic, edKeypair.privateKey);
    const encryptedMnemonic = encryptData(signedMnemonic, key);

    var pinHash;
    if (data.pin != null) {
        pinHash = hashData(data.pin);
    }

    return {
        status: "success",
        command: "data_generated",
        result: {
            edPrivateKey: edKeypair.privateKey,
            edPublicKey: edKeypair.publicKey,
            xPrivateKey: xKeypair.privateKey,
            xPublicKey: xKeypair.publicKey,
            encryptedMnemonic: encryptedMnemonic,
            pinHash: pinHash
        }
    }
}

export function encrypt(data) {
    let key = data.key;
    if (data.key === null || data.key === undefined) {
        key = generateSharedAesKey(data.xPrivateKey, data.xPublicKey, data.userID);
    }

    // Подпись
    const signedMessage = signData(data.message, data.privateKey);

    // Шифрование
    const encrypted = encryptData(signedMessage, key);

    return {
        status: "success",
        command: "encrypted",
        result: {
            encrypted: encrypted,
        },
    }
}

export function decrypt(data) {
    let key = data.key;
    if (data.key === null || data.key === undefined) {
        key = generateSharedAesKey(data.xPrivateKey, data.xPublicKey, data.userID);
    }

    // Дешифрование
    const decrypted = decryptData(data.encrypted, key);

    // Верификация
    let isVerified = false;
    if (data.edPublicKey !== null) {
        isVerified = verifyData(decrypted.signature, decrypted.message, data.edPublicKey);
    }

    return {
        status: "success",
        command: "decrypted",
        result: {
            decrypted: decrypted.message,
            isVerified: isVerified,
        },
    }
}

export function generateSharedKey(data) {
    const userIDs = data.userIDs;

    const sharedSecret = getSharedSecret(data.privateKey, data.publicKey);

    const sharedKey = generateSharedAesKey(sharedSecret, userIDs);

    return {
        status: "success",
        command: "generated_shared_key",
        result: {
            sharedKey: sharedKey,
        },
    }
}

function deriveSaltFromUserId(saltData) {
    if (typeof saltData !== "string") {
        console.log(saltData + "is not string type");
        return;
    }
    return new Uint8Array(_sha256(saltData, { asBytes: true })).subarray(0, 32);
}

function generateMnemonicData(strength) {
    const mnemonic = bip39.generateMnemonic(strength);

    const entropyHex = bip39.mnemonicToEntropy(mnemonic);

    return { mnemonic: mnemonic, entropy: entropyHex };
}

function generatePRNG(entropy, saltData, info) {
    const salt = deriveSaltFromUserId(saltData);
    const seedBinary = utils.hexToBytes(entropy);

    const hk1 = hkdf(sha256, seedBinary, salt, info, 32);

    return utils.bytesToHex(hk1);
}

async function generateEdKeyPair(entropy, userID) {
    const privateKey = generatePRNG(entropy, userID, "signing");
    const publicKey = ed25519.getPublicKey(privateKey);

    const data = {
        privateKey: privateKey,
        publicKey: utils.bytesToHex(publicKey),
    }

    return data;
}

function generateXKeyPair(entropy, userID) {
    const privateKey = generatePRNG(entropy, userID, "key exchange");
    const publicKey = x25519.getPublicKey(privateKey);

    const data = {
        privateKey: privateKey,
        publicKey: utils.bytesToHex(publicKey),
    };

    return data;
}

function generateSharedAesKey(privateKey, publicKey, sharedID) {
    const sharedSecret = getSharedSecret(privateKey, publicKey);
    const key = generatePRNG(sharedSecret, sharedID, "shared encryption");

    return key;
}

function getSharedSecret(privateKey, publicKey) {
    const secret = x25519.getSharedSecret(privateKey, publicKey);

    return utils.bytesToHex(secret);
}

function signData(message, privateKey) {
    const privateKeyBinary = forge.util.hexToBytes(privateKey);

    // sign a UTF-8 message
    const signature = forgeEd25519.sign({
        message: message,
        // also accepts `binary` if you want to pass a binary string
        encoding: 'utf8',
        // node.js Buffer, Uint8Array, forge ByteBuffer, binary string
        privateKey: privateKeyBinary
    });
    // `signature` is a node.js Buffer or Uint8Array

    const signedData = message + "::" + forge.util.bytesToHex(signature);

    return signedData;
}

function verifyData(signature, message, publicKey) {
    const signatureBinary = forge.util.hexToBytes(signature);
    const publicKeyBinary = forge.util.hexToBytes(publicKey);

    // verify a signature on a UTF-8 message
    const verified = forgeEd25519.verify({
        message: message,
        encoding: 'utf8',
        // node.js Buffer, Uint8Array, forge ByteBuffer, or binary string
        signature: signatureBinary,
        // node.js Buffer, Uint8Array, forge ByteBuffer, or binary string
        publicKey: publicKeyBinary
    });
    // `verified` is true/false

    return verified;
}

function encryptData(signedMessage, key) {
    const iv = forge.random.getBytesSync(16);

    // encrypt some bytes using GCM mode
    let cipher = forge.cipher.createCipher('AES-GCM', forge.util.hexToBytes(key));
    cipher.start({
        iv: iv, // should be a 12-byte binary-encoded string or byte buffer
        // additionalData: 'binary-encoded string', // optional
        tagLength: 128 // optional, defaults to 128 bits
    });
    cipher.update(forge.util.createBuffer(signedMessage));
    cipher.finish();

    const encrypted = cipher.output.getBytes();
    const tag = cipher.mode.tag.getBytes();

    const data = `${forge.util.bytesToHex(iv)}:${forge.util.bytesToHex(tag)}:${forge.util.bytesToHex(encrypted)}`;

    return data;
}

function decryptData(rawData, key) {
    const data = rawData.split(":");

    const iv = forge.util.hexToBytes(data[0]);
    const tag = forge.util.hexToBytes(data[1]);
    const encrypted = forge.util.hexToBytes(data[2]);

    // decrypt some bytes using GCM mode
    let decipher = forge.cipher.createDecipher('AES-GCM', forge.util.hexToBytes(key));
    decipher.start({
        iv: iv,
        // additionalData: 'binary-encoded string', // optional
        tagLength: 128, // optional, defaults to 128 bits
        tag: tag // authentication tag from encryption
    });
    decipher.update(forge.util.createBuffer(encrypted));
    const pass = decipher.finish();

    // pass is false if there was a failure (eg: authentication tag didn't match)
    if (pass) {
        const decryptedBinary = decipher.output.getBytes(); // это бинарная строка
        const decryptedUint8 = Uint8Array.from(decryptedBinary, ch => ch.charCodeAt(0));
        const decryptedData = new TextDecoder().decode(decryptedUint8); // возвращаем UTF-8 строку

        const dataParts = decryptedData.split("::");
        const signature = dataParts.at(-1);
        const message = dataParts.at(0);

        const data = {
            signature: signature,
            message: message,
        }

        return data;
    } else {
        console.log("Decryption is not passed");
    }
}

export function hashData(data) {
    const hashedData = new Uint8Array(_sha256(data, { asBytes: true })).subarray(0, 32); //? subarray is useless

    return utils.bytesToHex(hashedData);
}