import { x25519, ed25519 } from '@noble/curves/ed25519';
import * as bip39 from 'bip39';
import _sha256 from 'sha256';
import forge from 'node-forge';
import { hkdf } from '@noble/hashes/hkdf.js';
import { sha256 } from '@noble/hashes/sha2.js';
import * as utils from '@noble/hashes/utils';
import { pbkdf2 } from '@noble/hashes/pbkdf2';
import { Buffer } from 'buffer';
globalThis.Buffer = Buffer;

const forgeEd25519 = forge.pki.ed25519;

interface GenerationData {
    userID: string;
    mnemonic: string;
    pin: string;
}

interface SharedKeyData {
    userIDs: string,
    publicKey: string,
    privateKey: string,
}

interface DecryptionData {
    encrypted: string,
    edPublicKey: string,
    xPrivateKey: string,
    xPublicKey: string,
    userID: string,
    key: string,
}

interface EncryptionData {
    message: string,
    privateKey: string,
    key: string,
    xPrivateKey: string,
    xPublicKey: string,
    userID: string,
}

/**
 * Generates deterministic key pairs (X25519 for ECDH and Ed25519 for signing)
 * based on mnemonic entropy and user identifier.
 * 
 * @param data - Input parameters including optional mnemonic and PIN
 * @returns Generated key pairs, encrypted mnemonic, and optional PIN hash
 */
export async function generateData(data: GenerationData) {
    let { userID, mnemonic, pin } = data;

    let mnemonicEntropy: string;
    if (mnemonic === null || mnemonic === undefined) {
        // Generate mnemonic
        const generatedMnemonicData = generateMnemonicData(128);
        mnemonic = generatedMnemonicData.mnemonic;
        mnemonicEntropy = generatedMnemonicData.entropy;
    } else {
        mnemonicEntropy = bip39.mnemonicToEntropy(mnemonic);
    }

    // Generate key pairs
    const xKeyPair = generateXKeyPair(mnemonicEntropy, userID);
    const edKeyPair = await generateEdKeyPair(mnemonicEntropy, userID);

    // Encrypts seed phrase (mnemonic phrase)
    const key = generateSharedAesKey(xKeyPair.privateKey, xKeyPair.publicKey, userID);

    const signedMnemonic = signData(mnemonic, edKeyPair.privateKey);
    const encryptedMnemonic = encryptData(signedMnemonic, key);

    let pinHash: { salt: string, hash: string } | undefined;
    if (pin != null || pin != undefined) {
        pinHash = hashPin(pin);
    }

    return {
        status: "success",
        command: "data_generated",
        result: {
            edPrivateKey: edKeyPair.privateKey,
            edPublicKey: edKeyPair.publicKey,
            xPrivateKey: xKeyPair.privateKey,
            xPublicKey: xKeyPair.publicKey,
            encryptedMnemonic: encryptedMnemonic,
            pinHash: pinHash
        }
    }
}

/**
 * Encrypts a message: signs it with Ed25519, then encrypts the signed data with AES-GCM.
 *
 * @param params - Encryption parameters
 * @param params.message - Plaintext message to encrypt
 * @param params.privateKey - Ed25519 private key (hex) used for signing
 * @param params.key - Optional AES key (hex) for encryption. If not provided, a shared key will be derived.
 * @param params.xPrivateKey - X25519 private key (hex), used if shared key must be derived
 * @param params.xPublicKey - X25519 public key (hex), used if shared key must be derived
 * @param params.userID - User identifier (salt context for key derivation)
 * @returns An object containing AES-GCM ciphertext and metadata
 */
export function encrypt(params: EncryptionData) {
    let key = params.key;
    if (params.key === null || params.key === undefined) {
        key = generateSharedAesKey(params.xPrivateKey, params.xPublicKey, params.userID);
    }

    // Signs
    const signedMessage = signData(params.message, params.privateKey);

    // Encrypts
    const encrypted = encryptData(signedMessage, key);

    return {
        status: "success",
        command: "encrypted",
        result: {
            encrypted: encrypted,
        },
    }
}

/**
 * Decrypts AES-GCM encrypted data and verifies its Ed25519 signature.
 *
 * @param params - Decryption parameters
 * @param params.encrypted - AES-GCM encrypted payload (stringified JSON)
 * @param params.key - Optional AES key (hex). If not provided, a shared key will be derived.
 * @param params.xPrivateKey - X25519 private key (hex), used if shared key must be derived
 * @param params.xPublicKey - X25519 public key (hex), used if shared key must be derived
 * @param params.userID - User identifier (salt context for key derivation)
 * @param params.edPublicKey - Ed25519 public key (hex) used to verify the message signature
 * @returns An object containing the decrypted message and signature verification status
 */
export function decrypt(params: DecryptionData) {
    let key = params.key;
    if (params.key === null || params.key === undefined) {
        key = generateSharedAesKey(params.xPrivateKey, params.xPublicKey, params.userID);
    }

    // Decryptes
    const decrypted = decryptData(params.encrypted, key);

    // Verificates
    let isVerified = false;
    if (params.edPublicKey !== null) {
        isVerified = verifyData(decrypted.signature, decrypted.message, params.edPublicKey);
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


/**
 * Generates a shared AES key between two parties using X25519 ECDH.
 *
 * @param data - Shared key generation parameters
 * @param data.userIDs - Context string (used as salt in HKDF)
 * @param data.publicKey - Peer X25519 public key (hex)
 * @param data.privateKey - Own X25519 private key (hex)
 * @returns Shared AES key (hex string)
 */
export function generateSharedKey(data: SharedKeyData) {
    const userIDs: string = data.userIDs;

    const sharedKey = generateSharedAesKey(data.privateKey, data.publicKey, userIDs);

    return {
        status: "success",
        command: "generated_shared_key",
        result: {
            sharedKey: sharedKey,
        },
    }
}

/**
 * Derives a 32-byte salt from a string identifier using SHA-256.
 *
 * @param saltContext - String to derive salt from (e.g., userID)
 * @returns A 32-byte Uint8Array usable as HKDF salt
 */
function deriveSaltFromUserId(saltContext: string): Uint8Array {
    if (typeof saltContext !== "string") {
        throw Error(saltContext + " is not string type");
    }

    const hash = _sha256(saltContext, { asBytes: true }) as number[];
    return new Uint8Array(hash).subarray(0, 32);
}


/**
 * Generates a new mnemonic phrase and its entropy.
 *
 * @param strength - Entropy strength (128, 256 bits, etc.)
 * @returns Object containing the mnemonic phrase and entropy (hex)
 */
function generateMnemonicData(strength: number): { mnemonic: string; entropy: string } {
    const mnemonic = bip39.generateMnemonic(strength);

    const entropyHex = bip39.mnemonicToEntropy(mnemonic);

    return { mnemonic: mnemonic, entropy: entropyHex };
}

/**
 * Deterministically derives a pseudorandom key using HKDF.
 *
 * @param entropy - Seed or shared secret (hex string)
 * @param saltContext - Salt context (e.g., userID)
 * @param context - HKDF "info" parameter, defines key usage (signing, encryption, etc.)
 * @returns Derived key as hex string
 */
function generatePRNG(entropy: string, saltContext: string, context: string): string {
    const salt = deriveSaltFromUserId(saltContext);
    const seedBinary = utils.hexToBytes(entropy);

    const hk1 = hkdf(sha256, seedBinary, salt, context, 32);

    return utils.bytesToHex(hk1);
}

/**
 * Generates an Ed25519 key pair for signing, derived deterministically from entropy and userID.
 *
 * @param entropy - Entropy (hex string)
 * @param userID - User identifier (used as salt)
 * @returns Object containing privateKey and publicKey (hex strings)
 */
async function generateEdKeyPair(entropy: string, userID: string): Promise<{ privateKey: string; publicKey: string }> {
    const privateKey = generatePRNG(entropy, userID, "signing");
    const publicKey = ed25519.getPublicKey(privateKey);

    const data = {
        privateKey: privateKey,
        publicKey: utils.bytesToHex(publicKey),
    }

    return data;
}

/**
 * Generates an X25519 key pair for ECDH, derived deterministically from entropy and userID.
 *
 * @param entropy - Entropy (hex string)
 * @param userID - User identifier (used as salt)
 * @returns Object containing privateKey and publicKey (hex strings)
 */
function generateXKeyPair(entropy: string, userID: string): { privateKey: string; publicKey: string } {
    const privateKey = generatePRNG(entropy, userID, "key exchange");
    const publicKey = x25519.getPublicKey(privateKey);

    const data = {
        privateKey: privateKey,
        publicKey: utils.bytesToHex(publicKey),
    };

    return data;
}

/**
 * Generates a shared AES key using X25519 ECDH and HKDF.
 *
 * @param privateKey - Own X25519 private key (hex)
 * @param publicKey - Peer X25519 public key (hex)
 * @param sharedContext - Context string (e.g., userID or session ID)
 * @returns Derived AES key (hex string)
 */
function generateSharedAesKey(privateKey: string, publicKey: string, sharedContext: string): string {
    const sharedSecret = getSharedSecret(privateKey, publicKey);
    const key = generatePRNG(sharedSecret, sharedContext, "shared encryption");

    return key;
}

/**
 * Performs X25519 ECDH to derive a raw shared secret.
 *
 * @param privateKey - Own private key (hex)
 * @param publicKey - Peer public key (hex)
 * @returns Shared secret (hex string)
 */
function getSharedSecret(privateKey: string, publicKey: string): string {
    const secret = x25519.getSharedSecret(privateKey, publicKey);

    return utils.bytesToHex(secret);
}

/**
 * Signs a message using Ed25519.
 *
 * @param message - Plaintext message
 * @param privateKey - Ed25519 private key (hex)
 * @returns JSON string containing the message and its signature (hex)
 */
function signData(message: string, privateKey: string): string {
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

    const signedData = JSON.stringify({ message, signature: forge.util.bytesToHex(signature) });

    return signedData;
}


/**
 * Verifies a message signature using Ed25519.
 *
 * @param signature - Signature (hex)
 * @param message - Original message
 * @param publicKey - Ed25519 public key (hex)
 * @returns True if the signature is valid, false otherwise
 */
function verifyData(signature: string, message: string, publicKey: string): boolean {
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

/**
 * Encrypts a signed message using AES-GCM.
 *
 * @param signedMessage - JSON string containing message + signature
 * @param key - AES key (hex)
 * @returns Object containing IV, tag, and ciphertext (all hex)
 */
function encryptData(signedMessage: string, key: string): { iv: string, tag: string, encrypted: string } {
    const iv = forge.random.getBytesSync(12);

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

    const data = {
        iv: forge.util.bytesToHex(iv),
        tag: forge.util.bytesToHex(tag),
        encrypted: forge.util.bytesToHex(encrypted)
    };

    return data;
}

/**
 * Decrypts AES-GCM encrypted data and extracts signed message.
 *
 * @param rawData - JSON string containing IV, tag, and ciphertext
 * @param key - AES key (hex)
 * @returns Object containing message and signature (both strings)
 * @throws If authentication fails
 */
function decryptData(rawData: string, key: string): { signature: string; message: string } {
    const data = JSON.parse(rawData) as { iv: string, tag: string, encrypted: string };

    const iv = forge.util.hexToBytes(data.iv);
    const tag = forge.util.hexToBytes(data.tag);
    const encrypted = forge.util.hexToBytes(data.encrypted);

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
        const decryptedUint8 = Uint8Array.from(decryptedBinary as string, ch => ch.charCodeAt(0));
        const decryptedData = new TextDecoder().decode(decryptedUint8); // возвращаем UTF-8 строку

        const decryptedObject = JSON.parse(decryptedData) as { message: string, signature: string };
        const signature = decryptedObject.signature;
        const message = decryptedObject.message;

        const data = {
            signature: signature,
            message: message,
        }

        return data;
    } else {
        throw Error("Decryption is not passed");
    }
}

/**
 * Computes SHA-256 hash of data.
 *
 * @param data - Input string
 * @returns First 32 bytes of SHA-256 as hex string
 */
export function hashData(data: string): string {
    const hashedData = new Uint8Array(_sha256(data, { asBytes: true }) as number[]).subarray(0, 32);

    return utils.bytesToHex(hashedData);
}

/**
 * Hashes a PIN code using PBKDF2 with SHA-256 and random salt.
 *
 * @param pin - PIN code as string
 * @returns Object containing random salt (hex) and derived hash (hex)
 */
export function hashPin(pin: string): { salt: string; hash: string } {
    const saltBytes = forge.random.getBytesSync(16); // 16-byte random salt
    const saltHex = forge.util.bytesToHex(saltBytes);

    const derived = pbkdf2(sha256, utils.utf8ToBytes(pin), saltBytes, {
        c: 100_000, // iterations
        dkLen: 32,  // 256-bit output
    });

    return {
        salt: saltHex,
        hash: utils.bytesToHex(derived),
    };
}

/**
 * Verifies a PIN against stored salt and hash.
 *
 * @param pin - User-provided PIN
 * @param saltHex - Previously stored salt (hex)
 * @param storedHash - Previously stored hash (hex)
 * @returns True if PIN is valid, false otherwise
 */
export function verifyPin(pin: string, saltHex: string, storedHash: string): boolean {
    const derived = pbkdf2(sha256, utils.utf8ToBytes(pin), utils.hexToBytes(saltHex), {
        c: 100_000,
        dkLen: 32,
    });

    return utils.bytesToHex(derived) === storedHash;
}
