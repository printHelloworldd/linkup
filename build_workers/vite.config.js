import { defineConfig } from 'vite';
// import nodePolyfills from 'vite-plugin-node-polyfills';
import { NodeGlobalsPolyfillPlugin } from '@esbuild-plugins/node-globals-polyfill'

export default defineConfig({
    define: {
        global: 'globalThis' // важно для node-forge
    },
    resolve: {
        alias: {
            buffer: 'buffer', // чтобы node-forge мог использовать Buffer
        },
    },
    optimizeDeps: {
        include: ['buffer', 'bip39', 'node-forge', 'sha256', 'hex-encode-decode', '@noble/hashes/utils', '@noble/curves/ed25519', '@noble/hashes/sha2.js', '@noble/hashes/hkdf.js'],
        esbuildOptions: {
            // Node.js global to browser globalThis
            define: {
                global: 'globalThis'
                // global: {},
            },
            // Enable esbuild polyfill plugins
            plugins: [
                NodeGlobalsPolyfillPlugin({
                    buffer: true
                })
            ]
        }
    },
    // plugins: [
    //     nodePolyfills({
    //         protocolImports: true
    //     })
    // ],
    // resolve: {
    //     alias: {
    //         // Полифилы
    //         stream: 'stream-browserify',
    //         buffer: 'buffer',
    //         process: 'process/browser',
    //         crypto: 'crypto-browserify',
    //     }
    // },
    // define: {
    //     global: 'globalThis' // чтобы пакеты не падали от отсутствия global
    // },
    build: {
        outDir: '../web/workers',
        rollupOptions: {
            input: 'src/handlers/cryptography_worker.js', // путь к твоему воркеру
            output: {
                entryFileNames: 'crypto_worker.js', // имя итогового файла
                format: 'es' // важно: чтобы работал `type: 'module'`
            }
        },
        emptyOutDir: true,
        target: 'esnext', // чтобы не было ошибок с modern JS
        minify: false, // отключи на время отладки
        sourcemap: true, // удобно для отладки
    }
});
