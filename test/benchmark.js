const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

function hexZeroPad(hex, length) {
    hex = hex.replace(/^0x/, '');
    while (hex.length < length * 2) hex = '0' + hex;
    return '0x' + hex;
}

describe("Mestre de Benchmark Final: PON IoT Logistics", function () {
    let contracts = {};
    const metrics = {
        traditional: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        pon: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        paradigmatic: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        bitpacked: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        shortcircuit: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        transient: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        merkle: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        yulpon: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] },
        hyperfused: { deploy: 0, batchGas: 0, atomicGas: 0, tps: 0, latency: [] }
    };

    // Helpers para rastrear Gas
    async function trackBatch(txPromise, modelKey) {
        const tx = await txPromise;
        const receipt = await tx.wait();
        metrics[modelKey].batchGas = Number(receipt.gasUsed);
    }

    async function trackAtomic(txPromise, modelKey) {
        const start = process.hrtime.bigint();
        const tx = await txPromise;
        const sent = process.hrtime.bigint();
        const receipt = await tx.wait();
        const confirmed = process.hrtime.bigint();
        metrics[modelKey].atomicGas += Number(receipt.gasUsed);
        // Latência: tempo entre envio e confirmação (em ms)
        const latencyMs = Number(confirmed - sent) / 1e6;
        metrics[modelKey].latency.push(latencyMs);
    }

    // Função para Deploy Limpo
    async function deployAllContracts() {
        console.log("   🔄 Realizando Deploys Limpos...");
        const names = [
            "TraditionalLogistics", "PONLogistics", "ParadigmaticPONLogistics",
            "PONBitPackedLogistics", "ShortCircuitPONLogistics", "TransientPONLogistics",
            "MerklePONLogistics", "YulPONLogistics", "PONHyperFusedLogistics"
        ];
        const keys = [
            "traditional", "pon", "paradigmatic", "bitpacked", "shortcircuit", 
            "transient", "merkle", "yulpon", "hyperfused"
        ];
        
        for (let i = 0; i < names.length; i++) {
            const Factory = await ethers.getContractFactory(names[i]);
            const instance = await Factory.deploy();
            const receipt = await instance.deploymentTransaction().wait();
            contracts[keys[i]] = instance;
            if (metrics[keys[i]].deploy === 0) {
                metrics[keys[i]].deploy = Number(receipt.gasUsed);
            }
        }
    }

    const v = { temp: -30, door: true, route: true, hum: 90, pres: 900, light: 1500, vib: 10, co2: 2500, bat: 10, shock: true };

    // =====================================================================
    // CENÁRIO 1: EFICIÊNCIA DE REDE (10 TXs Atômicas)
    // =====================================================================
    describe("Cenário 1: Degradação de Transporte (10 TXs Atômicas Individuais)", function () {
        before(async function () {
            await deployAllContracts(); // Contratos Virgens
        });

        it("Atualizando fatos 1 a 1 em TODOS os modelos (Incluindo PHF)", async function () {
            const tpsStart = {};
            const tpsEnd = {};
            const txCount = {};

            // 1. Modelos Clássicos
            const trad = contracts.traditional;
            const tradTxs = [
                () => trad.updateTemperature(v.temp),
                () => trad.updateDoor(v.door),
                () => trad.updateRoute(v.route),
                () => trad.updateHumidity(v.hum),
                () => trad.updatePressure(v.pres),
                () => trad.updateLight(v.light),
                () => trad.updateVibration(v.vib),
                () => trad.updateCO2(v.co2),
                () => trad.updateBattery(v.bat),
                () => trad.updateShock(v.shock)
            ];
            tpsStart.traditional = process.hrtime.bigint();
            for (const fn of tradTxs) await trackAtomic(fn(), 'traditional');
            tpsEnd.traditional = process.hrtime.bigint();
            txCount.traditional = tradTxs.length;


            const pon = contracts.pon;
            const ponTxs = [
                () => pon.updateFactTemperature(v.temp),
                () => pon.updateFactDoor(v.door),
                () => pon.updateFactRoute(v.route),
                () => pon.updateFactHumidity(v.hum),
                () => pon.updateFactPressure(v.pres),
                () => pon.updateFactLight(v.light),
                () => pon.updateFactVibration(v.vib),
                () => pon.updateFactCO2(v.co2),
                () => pon.updateFactBattery(v.bat),
                () => pon.updateFactShock(v.shock)
            ];
            tpsStart.pon = process.hrtime.bigint();
            for (const fn of ponTxs) await trackAtomic(fn(), 'pon');
            tpsEnd.pon = process.hrtime.bigint();
            txCount.pon = ponTxs.length;


            const merkle = contracts.merkle;
            const merkleTxs = [
                () => merkle.updateFactTemperature(v.temp),
                () => merkle.updateFactDoor(v.door),
                () => merkle.updateFactRoute(v.route),
                () => merkle.updateFactHumidity(v.hum),
                () => merkle.updateFactPressure(v.pres),
                () => merkle.updateFactLight(v.light),
                () => merkle.updateFactVibration(v.vib),
                () => merkle.updateFactCO2(v.co2),
                () => merkle.updateFactBattery(v.bat),
                () => merkle.updateFactShock(v.shock)
            ];
            tpsStart.merkle = process.hrtime.bigint();
            for (const fn of merkleTxs) await trackAtomic(fn(), 'merkle');
            tpsEnd.merkle = process.hrtime.bigint();
            txCount.merkle = merkleTxs.length;


            const standardModels = ['paradigmatic', 'bitpacked', 'shortcircuit', 'transient', 'yulpon'];
            for (const key of standardModels) {
                const c = contracts[key];
                const txs = [
                    () => c.methodUpdateTemperature(v.temp),
                    () => c.methodUpdateDoor(v.door),
                    () => c.methodUpdateRoute(v.route),
                    () => c.methodUpdateHumidity(v.hum),
                    () => c.methodUpdatePressure(v.pres),
                    () => c.methodUpdateLight(v.light),
                    () => c.methodUpdateVibration(v.vib),
                    () => c.methodUpdateCO2(v.co2),
                    () => c.methodUpdateBattery(v.bat),
                    () => c.methodUpdateShock(v.shock)
                ];
                tpsStart[key] = process.hrtime.bigint();
                for (const fn of txs) await trackAtomic(fn(), key);
                tpsEnd[key] = process.hrtime.bigint();
                txCount[key] = txs.length;
            }

            // 2. PHF: O PIOR CASO
            // Simulando um Oráculo que manda 10 atualizações separadas, construindo o estado aos poucos.
            tpsStart.hyperfused = process.hrtime.bigint();
            for (let i = 0; i < 10; i++) {
                let args = [v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock];
                for (let j = i + 1; j < args.length; j++) args[j] = (typeof args[j] === 'boolean') ? false : 0;
                await trackAtomic(contracts.hyperfused.updateLogistics(...args), 'hyperfused');
            }
            tpsEnd.hyperfused = process.hrtime.bigint();
            txCount.hyperfused = 10;

            // Calcular TPS para todos os modelos
            for (const key of Object.keys(tpsStart)) {
                const elapsedSec = Number(tpsEnd[key] - tpsStart[key]) / 1e9;
                metrics[key].tps = txCount[key] / elapsedSec;
            }
        });
    });

    // =====================================================================
    // CENÁRIO 2: EFICIÊNCIA ARQUITETURAL (Batch)
    // =====================================================================
    describe("Cenário 2: Eficiência Arquitetural (1 TX Lote vs 1 TX PHF)", function () {
        before(async function () {
            await deployAllContracts(); 
        });

        it("Atualização simultânea em lote (Batching)", async function () {
            await trackBatch(contracts.traditional.updateAll(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'traditional');

            await trackBatch(contracts.pon.updateAll(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'pon');

            await trackBatch(contracts.paradigmatic.methodUpdateAll(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'paradigmatic');

            await trackBatch(contracts.bitpacked.updateAllBitPacked(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'bitpacked');

            await trackBatch(contracts.shortcircuit.updateAllShortCircuit(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'shortcircuit');

            await trackBatch(contracts.transient.updateAllTransient(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'transient');

            const mockRoot = "0x" + "1".repeat(64);
            await trackBatch(contracts.merkle.updateAllFacts(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock, mockRoot
            ), 'merkle');

            await trackBatch(contracts.yulpon.updateAllYul(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'yulpon');

            await trackBatch(contracts.hyperfused.updateLogistics(
                v.temp, v.door, v.route, v.hum, v.pres, v.light, v.vib, v.co2, v.bat, v.shock
            ), 'hyperfused');
        });
    });

    after(async function () {
        const resultsDir = path.join(__dirname, "../results");
        if (!fs.existsSync(resultsDir)) fs.mkdirSync(resultsDir, { recursive: true });

        const hBatchGas = metrics.hyperfused.batchGas; 
        const hAtomicGas = metrics.hyperfused.atomicGas; 

        const models = [
            { key: 'traditional', label: 'Tradicional' },
            { key: 'pon', label: 'PON Otimizado' },
            { key: 'paradigmatic', label: 'Paradigmático' },
            { key: 'bitpacked', label: 'BitPacked' },
            { key: 'shortcircuit', label: 'ShortCircuit' },
            { key: 'transient', label: 'Transient' },
            { key: 'yulpon', label: 'YulPON' },
            { key: 'merkle', label: 'Merkle' }
        ];

        // ==========================================
        // TABELA 1
        // ==========================================
        console.log("\n" + "=".repeat(75));
        console.log("🌐 TABELA 1: O MUNDO IDEAL (10 TXs vs 1 TX PHF em Lote)");
        console.log("=".repeat(75));
        let csvIdeal = 'Modelo,Custo_10_Atômicos,HyperFused_1_Lote,Economia_%\n';
        for (const m of models) {
            const atomic = metrics[m.key].atomicGas;
            let econ = atomic > 0 ? (((atomic - hBatchGas) / atomic) * 100).toFixed(2) : 'N/A';
            console.log(`${m.label.padEnd(16)} | 10 TXs: ${atomic.toLocaleString().padStart(8)} | PHF(Lote): ${hBatchGas.toLocaleString().padStart(6)} | Otimização: ${econ}%`);
            csvIdeal += `${m.label},${atomic},${hBatchGas},${econ}\n`;
        }

        // ==========================================
        // TABELA 2
        // ==========================================
        console.log("\n" + "=".repeat(75));
        console.log("💎 TABELA 2: A EVM NUA E CRUA (1 Lote Clássico vs 1 Lote PHF)");
        console.log("=".repeat(75));
        let csvArq = 'Modelo,Custo_1_Lote,HyperFused_1_Lote,Economia_Arquitetural_%\n';
        for (const m of models) {
            const batch = metrics[m.key].batchGas;
            let econ = batch > 0 ? (((batch - hBatchGas) / batch) * 100).toFixed(2) : 'N/A';
            console.log(`${m.label.padEnd(16)} | 1 Lote: ${batch.toLocaleString().padStart(8)} | PHF(Lote): ${hBatchGas.toLocaleString().padStart(6)} | Otimização: ${econ}%`);
            csvArq += `${m.label},${batch},${hBatchGas},${econ}\n`;
        }

        // ==========================================
        // TABELA 3 (Nova)
        // ==========================================
        console.log("\n" + "=".repeat(75));
        console.log("🔥 TABELA 3: O PIOR CASO (10 Atômicos Clássicos vs 10 Atômicos PHF)");
        console.log("=".repeat(75));
        let csvPiorCaso = 'Modelo,Custo_10_Atômicos_Classic,Custo_10_Atômicos_PHF,Economia_Pior_Caso_%\n';
        for (const m of models) {
            const atomic = metrics[m.key].atomicGas;
            let econ = atomic > 0 ? (((atomic - hAtomicGas) / atomic) * 100).toFixed(2) : 'N/A';
            console.log(`${m.label.padEnd(16)} | 10 TXs Class: ${atomic.toLocaleString().padStart(7)} | 10 TXs PHF: ${hAtomicGas.toLocaleString().padStart(7)} | Otimização: ${econ}%`);
            csvPiorCaso += `${m.label},${atomic},${hAtomicGas},${econ}\n`;
        }
        console.log("=".repeat(75));

        // ==========================================
        // TABELA 4: TPS e Latência (Comparativo)
        // ==========================================
        console.log("\n" + "=".repeat(75));
        console.log("🚀 TABELA 4: TPS e Latência (Comparativo)");
        console.log("=".repeat(75));
        let csvTps = 'Modelo,TPS,LatenciaMediaMs\n';
        const allModels = [
            { key: 'traditional', label: 'Tradicional' },
            { key: 'pon', label: 'PON Otimizado' },
            { key: 'paradigmatic', label: 'Paradigmático' },
            { key: 'bitpacked', label: 'BitPacked' },
            { key: 'shortcircuit', label: 'ShortCircuit' },
            { key: 'transient', label: 'Transient' },
            { key: 'yulpon', label: 'YulPON' },
            { key: 'merkle', label: 'Merkle' },
            { key: 'hyperfused', label: 'HyperFused' }
        ];
        for (const m of allModels) {
            const tps = metrics[m.key].tps;
            const latencies = metrics[m.key].latency;
            const avgLatency = latencies.length > 0 ? (latencies.reduce((a, b) => a + b, 0) / latencies.length).toFixed(2) : 'N/A';
            console.log(`${m.label.padEnd(16)} | TPS: ${tps.toFixed(2).padStart(8)} | Latência Média: ${avgLatency} ms`);
            csvTps += `${m.label},${tps.toFixed(2)},${avgLatency}\n`;
        }
        fs.writeFileSync(path.join(resultsDir, 'tps_latency.csv'), csvTps);
    });
});