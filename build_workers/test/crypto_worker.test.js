import { generateData, encrypt, decrypt, hashData, generateSharedKey } from "../src/handlers/crypto_logic";
import { describe, expect, it } from 'vitest'

//* Data for testing
// {
//     edPrivateKey: '175d49db38c81a4c06582807eac98b8727153230cdf6dcb3cbb8fba949bd132e',
//     edPublicKey: '0400361da0fa5b50dcb6da4d5374dcdd587967800964551bd558aa3508701d6c',
//     xPrivateKey: 'ad30c1e6f6c885b5167b3182a454c7d0bab0fad9ec6016672da5fc1dfec2613b',
//     xPublicKey: '7d4f9e2b8f2df0d60fe05ec8ffb1352c9344b18dac98209017e7b2dd5e459568',
//     encryptedMnemonic: '98e90de74a6b5ff3e759870560d551fa:ac9ce47d6b44f345e5cc754a6354f8d8:fefe31dd83572a81451abbe1f0b50c1b91d6dce5f68da080884301457b9bcf9870b2b720d1edbc640b94364ee70376d329b8ebd6001f9058d1f502fd68a99cb206bbad7f342d01435eeaba8d089fb44cafed1588881a77dc561e945fdef97aa57237d4b791aec94a74bc828ea245c6947bf22ec4e1ce962f62cdd8d603042874faad4ad4d67e1544a4c1ba2bb6b84932b8be6100eaedbddf51037da61f2f895798dab2889ba024e778830b33912e8bb019abed4570b8d90c3c71a66dab04149afb481dd16a72b78b6551630a9286e2e9',
//     pinHash: '03ac674216f3e15c761ee1a5e255f067953623c8b388b4459e13f978d7c846f4'
//   }

describe("#hashData", () => {
    it("returns hashed data", () => {
        var hashedData = [hashData("Hello World!"), hashData("Hello World!")];
        const areEqual = hashedData[0] === hashedData[1];

        expect(areEqual).toBe(true);
    });
});

describe("#generateData", () => {
    it("returns generated crypto data", async () => {
        var result = await generateData({ userID: "some-id", pin: "1234" });

        expect(result).toHaveProperty("status", "success");
        expect(result).toHaveProperty("command", "data_generated");
        expect(result).toHaveProperty("result");

        const data = result.result;

        // Checking if all keys are present
        expect(data).toHaveProperty("edPrivateKey");
        expect(data).toHaveProperty("edPublicKey");
        expect(data).toHaveProperty("xPrivateKey");
        expect(data).toHaveProperty("xPublicKey");
        expect(data).toHaveProperty("encryptedMnemonic");
        expect(data).toHaveProperty("pinHash");

        // Type checking
        expect(typeof data.edPrivateKey).toBe("string");
        expect(typeof data.edPublicKey).toBe("string");
        expect(typeof data.xPrivateKey).toBe("string");
        expect(typeof data.xPublicKey).toBe("string");
        expect(typeof data.encryptedMnemonic).toBe("string");
        expect(typeof data.pinHash).toBe("string");

        // Checking that lines are not empty
        Object.values(data).forEach((value) => {
            if (typeof value === "string") {
                expect(value.length).toBeGreaterThan(0);
            }
        });
    });
});

describe("#E2E encryption", () => {
    it("encrypts and decrypts text message", async () => {
        const dataToEncrypt = { userID: "some-id", xPrivateKey: "ad30c1e6f6c885b5167b3182a454c7d0bab0fad9ec6016672da5fc1dfec2613b", xPublicKey: "7d4f9e2b8f2df0d60fe05ec8ffb1352c9344b18dac98209017e7b2dd5e459568", message: "Hello!", privateKey: "175d49db38c81a4c06582807eac98b8727153230cdf6dcb3cbb8fba949bd132e" };
        var encryptionResult = encrypt(dataToEncrypt);

        expect(encryptionResult).toHaveProperty("status", "success");
        expect(encryptionResult).toHaveProperty("command", "encrypted");
        expect(encryptionResult).toHaveProperty("result");

        const encryptedData = encryptionResult.result;

        // Checking if all keys are present
        expect(encryptedData).toHaveProperty("encrypted");

        // Type checking
        expect(typeof encryptedData.encrypted).toBe("string");

        // Checking that lines are not empty
        Object.values(encryptedData).forEach((value) => {
            if (typeof value === "string") {
                expect(value.length).toBeGreaterThan(0);
            }
        });

        const dataToDecrypt = { userID: "some-id", xPrivateKey: "ad30c1e6f6c885b5167b3182a454c7d0bab0fad9ec6016672da5fc1dfec2613b", xPublicKey: "7d4f9e2b8f2df0d60fe05ec8ffb1352c9344b18dac98209017e7b2dd5e459568", encrypted: encryptedData.encrypted, edPublicKey: "0400361da0fa5b50dcb6da4d5374dcdd587967800964551bd558aa3508701d6c" };
        var decryptionResult = decrypt(dataToDecrypt);

        expect(decryptionResult).toHaveProperty("status", "success");
        expect(decryptionResult).toHaveProperty("command", "decrypted");
        expect(decryptionResult).toHaveProperty("result");

        const decryptedData = decryptionResult.result;

        // Checking if all keys are present
        expect(decryptedData).toHaveProperty("decrypted");
        expect(decryptedData).toHaveProperty("isVerified");

        // Type checking
        expect(typeof decryptedData.decrypted).toBe("string");
        expect(typeof decryptedData.isVerified).toBe("boolean");

        // Checking that lines are not empty
        Object.values(decryptedData).forEach((value) => {
            if (typeof value === "string") {
                expect(value.length).toBeGreaterThan(0);
            }
        });

        expect(decryptedData.isVerified).toBe(true);
        expect(decryptedData.decrypted).toBe(dataToEncrypt.message);
    });
});

describe("#generateSharedKey", () => {
    it("returns shared AES key based on Diffie-Hellman key pair", async () => {
        const rawData = { userIDs: ["some-id", "some-id_2"].sort().join("_"), privateKey: "ad30c1e6f6c885b5167b3182a454c7d0bab0fad9ec6016672da5fc1dfec2613b", publicKey: "7d4f9e2b8f2df0d60fe05ec8ffb1352c9344b18dac98209017e7b2dd5e459568" };
        var result = generateSharedKey(rawData);

        expect(result).toHaveProperty("status", "success");
        expect(result).toHaveProperty("command", "generated_shared_key");
        expect(result).toHaveProperty("result");

        const returnedData = result.result;

        // Checking if all keys are present
        expect(returnedData).toHaveProperty("sharedKey");

        // Type checking
        expect(typeof returnedData.sharedKey).toBe("string");

        // Checking that lines are not empty
        Object.values(returnedData).forEach((value) => {
            if (typeof value === "string") {
                expect(value.length).toBeGreaterThan(0);
            }
        });
    });
});
