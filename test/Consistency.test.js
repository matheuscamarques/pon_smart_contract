
const { expect } = require("chai");
const { ethers } = require("hardhat");
const { AbiCoder } = require("ethers");
const abiCoder = new AbiCoder();
const { MerkleTree } = require("merkletreejs");
const keccak256 = require("keccak256");

describe("Consistency Logic Test - PON Logistics Contracts", function () {
  let contracts = {};
  let deployer;

  before(async () => {
    [deployer] = await ethers.getSigners();
    // Deploy all contracts
    const contractNames = [
      "PONLogistics",
      "MerklePONLogistics",
      "YulPONLogistics",
      "TransientPONLogistics",
      "PONBitPackedLogistics",
      "TraditionalLogistics",
      "ParadigmaticPONLogistics",
      "ShortCircuitPONLogistics",
      "PONHyperFusedLogistics"
    ];

  const sensores = [
    {
      nome: "Porta",
      valor: true,
      index: 1,
      metodos: {
        PONLogistics: c => c.updateFactDoor(true),
        TraditionalLogistics: c => c.updateDoor(true),
        MerklePONLogistics: c => c.updateFact(1, ethers.toBeHex(1, 32), []),
        YulPONLogistics: c => c.methodUpdateDoor(true),
        TransientPONLogistics: c => c.methodUpdateDoor(true),
        PONBitPackedLogistics: c => c.methodUpdateDoor(true),
        ParadigmaticPONLogistics: c => c.methodUpdateDoor(true),
        ShortCircuitPONLogistics: c => c.methodUpdateDoor(true),
        PONHyperFusedLogistics: c => c.updateLogistics(0, true, false, 0, 0, 0, 0, 0, 0, false)
      }
    },
    {
      nome: "Rota",
      valor: true,
      index: 2,
      metodos: {
        PONLogistics: c => c.updateFactRoute(true),
        TraditionalLogistics: c => c.updateRoute(true),
        MerklePONLogistics: c => c.updateFact(2, ethers.toBeHex(1, 32), []),
        YulPONLogistics: c => c.methodUpdateRoute(true),
        TransientPONLogistics: c => c.methodUpdateRoute(true),
        PONBitPackedLogistics: c => c.methodUpdateRoute(true),
        ParadigmaticPONLogistics: c => c.methodUpdateRoute(true),
        ShortCircuitPONLogistics: c => c.methodUpdateRoute(true),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, true, 0, 0, 0, 0, 0, 0, false)
      }
    },
    {
      nome: "Umidade",
      valor: 99,
      index: 3,
      metodos: {
        PONLogistics: c => c.updateFactHumidity(99),
        TraditionalLogistics: c => c.updateHumidity(99),
        MerklePONLogistics: c => c.updateFact(3, ethers.toBeHex(99, 32), []),
        YulPONLogistics: c => c.methodUpdateHumidity(99),
        TransientPONLogistics: c => c.methodUpdateHumidity(99),
        PONBitPackedLogistics: c => c.methodUpdateHumidity(99),
        ParadigmaticPONLogistics: c => c.methodUpdateHumidity(99),
        ShortCircuitPONLogistics: c => c.methodUpdateHumidity(99),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, false, 99, 0, 0, 0, 0, 0, false)
      }
    },
    {
      nome: "Pressão",
      valor: 2000,
      index: 4,
      metodos: {
        PONLogistics: c => c.updateFactPressure(2000),
        TraditionalLogistics: c => c.updatePressure(2000),
        MerklePONLogistics: c => c.updateFact(4, ethers.toBeHex(2000, 32), []),
        YulPONLogistics: c => c.methodUpdatePressure(2000),
        TransientPONLogistics: c => c.methodUpdatePressure(2000),
        PONBitPackedLogistics: c => c.methodUpdatePressure(2000),
        ParadigmaticPONLogistics: c => c.methodUpdatePressure(2000),
        ShortCircuitPONLogistics: c => c.methodUpdatePressure(2000),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, false, 0, 2000, 0, 0, 0, 0, false)
      }
    },
    {
      nome: "Luz",
      valor: 10000,
      index: 5,
      metodos: {
        PONLogistics: c => c.updateFactLight(10000),
        TraditionalLogistics: c => c.updateLight(10000),
        MerklePONLogistics: c => c.updateFact(5, ethers.toBeHex(10000, 32), []),
        YulPONLogistics: c => c.methodUpdateLight(10000),
        TransientPONLogistics: c => c.methodUpdateLight(10000),
        PONBitPackedLogistics: c => c.methodUpdateLight(10000),
        ParadigmaticPONLogistics: c => c.methodUpdateLight(10000),
        ShortCircuitPONLogistics: c => c.methodUpdateLight(10000),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, false, 0, 0, 10000, 0, 0, 0, false)
      }
    },
    {
      nome: "Vibração",
      valor: 100,
      index: 6,
      metodos: {
        PONLogistics: c => c.updateFactVibration(100),
        TraditionalLogistics: c => c.updateVibration(100),
        MerklePONLogistics: c => c.updateFact(6, ethers.toBeHex(100, 32), []),
        YulPONLogistics: c => c.methodUpdateVibration(100),
        TransientPONLogistics: c => c.methodUpdateVibration(100),
        PONBitPackedLogistics: c => c.updateFactVibration(100),
        ParadigmaticPONLogistics: c => c.methodUpdateVibration(100),
        ShortCircuitPONLogistics: c => c.methodUpdateVibration(100),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, false, 0, 0, 0, 100, 0, 0, false)
      }
    },
    {
      nome: "CO2",
      valor: 10000,
      index: 7,
      metodos: {
        PONLogistics: c => c.updateFactCO2(10000),
        TraditionalLogistics: c => c.updateCO2(10000),
        MerklePONLogistics: c => c.updateFact(7, ethers.toBeHex(10000, 32), []),
        YulPONLogistics: c => c.methodUpdateCO2(10000),
        TransientPONLogistics: c => c.methodUpdateCO2(10000),
        PONBitPackedLogistics: c => c.updateFactCO2(10000),
        ParadigmaticPONLogistics: c => c.methodUpdateCO2(10000),
        ShortCircuitPONLogistics: c => c.methodUpdateCO2(10000),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, false, 0, 0, 0, 0, 10000, 0, false)
      }
    },
    {
      nome: "Bateria",
      valor: 1,
      index: 8,
      metodos: {
        PONLogistics: c => c.updateFactBattery(1),
        TraditionalLogistics: c => c.updateBattery(1),
        MerklePONLogistics: c => c.updateFact(8, ethers.toBeHex(1, 32), []),
        YulPONLogistics: c => c.methodUpdateBattery(1),
        TransientPONLogistics: c => c.methodUpdateBattery(1),
        PONBitPackedLogistics: c => c.updateFactBattery(1),
        ParadigmaticPONLogistics: c => c.methodUpdateBattery(1),
        ShortCircuitPONLogistics: c => c.methodUpdateBattery(1),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, false, 0, 0, 0, 0, 0, 1, false)
      }
    },
    {
      nome: "Choque",
      valor: true,
      index: 9,
      metodos: {
        PONLogistics: c => c.updateFactShock(true),
        TraditionalLogistics: c => c.updateShock(true),
        MerklePONLogistics: c => c.updateFact(9, ethers.toBeHex(1, 32), []),
        YulPONLogistics: c => c.methodUpdateShock(true),
        TransientPONLogistics: c => c.methodUpdateShock(true),
        PONBitPackedLogistics: c => c.updateFactShock(true),
        ParadigmaticPONLogistics: c => c.methodUpdateShock(true),
        ShortCircuitPONLogistics: c => c.methodUpdateShock(true),
        PONHyperFusedLogistics: c => c.updateLogistics(0, false, false, 0, 0, 0, 0, 0, 0, true)
      }
    }
  ];

  // Mapeamento dos getters públicos para cada contrato
  const getters = {
    PONLogistics: {
      Temperatura: c => c.factTemperature?.(),
      Porta: c => c.factDoorOpen?.(),
      Rota: c => c.factRouteDeviated?.(),
      Umidade: c => c.factHumidity?.(),
      Pressão: c => c.factPressure?.(),
      Luz: c => c.factLight?.(),
      Vibração: c => c.factVibration?.(),
      CO2: c => c.factCO2?.(),
      Bateria: c => c.factBattery?.(),
      Choque: c => c.factShockDetected?.()
    },
    TraditionalLogistics: {
      Temperatura: c => c.temperature?.(),
      Porta: c => c.isDoorOpen?.(),
      Rota: c => c.isRouteDeviated?.(),
      Umidade: c => c.humidity?.(),
      Pressão: c => c.pressure?.(),
      Luz: c => c.light?.(),
      Vibração: c => c.vibration?.(),
      CO2: c => c.co2?.(),
      Bateria: c => c.battery?.(),
      Choque: c => c.shockDetected?.()
    }
    // Outros contratos podem ser adicionados se possuírem getters públicos
  };

  sensores.forEach((sensor, idx) => {
    it(`Deve validar reatividade de ${sensor.nome} em todos os modelos`, async function () {
      const contractNames = Object.keys(contracts);

      // --- Merkle Tree Setup (off-chain) ---
      // Para MerklePONLogistics, simulamos uma árvore de 10 fatos (índices 0-9)
      let merkleLeaves = [];
      for (let i = 0; i < 10; i++) {
        let tipo;
        if ([0].includes(i)) tipo = "int256"; // Temperatura
        else if ([1,2,9].includes(i)) tipo = "bool"; // Porta, Rota, Choque
        else tipo = "uint256"; // Demais
        let valor;
        if (i === sensor.index) valor = sensor.valor;
        else if (tipo === "bool") valor = false;
        else valor = 0;
        const encoded = abiCoder.encode(["uint256", tipo], [i, valor]);
        merkleLeaves.push(keccak256(encoded));
      }
      const merkleTree = new MerkleTree(merkleLeaves, keccak256, { sortPairs: true });

      for (const name of contractNames) {
        const c = contracts[name];
        let tx, receipt;
        try {
          if (name === "MerklePONLogistics") {
            const leaf = merkleLeaves[sensor.index];
            const proof = merkleTree.getHexProof(leaf);
            tx = await c.connect(deployer).updateFact(sensor.index, sensor.metodos[name] ? ethers.toBeHex(sensor.valor, 32) : ethers.toBeHex(sensor.valor, 32), proof);
          } else {
            const metodo = sensor.metodos[name];
            if (metodo) {
              tx = await metodo(c.connect ? c.connect(deployer) : c);
            }
          }
          receipt = await tx.wait();
        } catch (e) {
          throw new Error(`Falha ao executar método para ${sensor.nome} em ${name}: ${e.message}`);
        }

        // --- Validação por Evento (para todos os contratos) ---
        const eventName = "InstigationTriggered";
        const hasEvent = receipt.logs.some(log => {
          try {
            const parsed = c.interface.parseLog(log);
            return parsed.name === eventName || parsed.name === "Alert";
          } catch (e) { return false; }
        });
        expect(hasEvent, `Contrato ${name} falhou em disparar notificação para ${sensor.nome}`).to.be.true;
      }
    });
  });
});
});
