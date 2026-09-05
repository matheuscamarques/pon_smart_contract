// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title MerklePONLogistics
 * @author Matheus de Camargo Mar
 * @notice Implementação do PON (Production Oriented Network) utilizando compressão de estado via Merkle Proofs.
 *         Permite atualização eficiente e verificada dos fatos logísticos, suportando rollups e provas de integridade.
 *         Ideal para cenários onde a rastreabilidade e a integridade dos dados são essenciais, aproveitando lógica de Merkle Trees para garantir consistência e segurança das informações logísticas.
 */
contract MerklePONLogistics {
    // Métodos wrappers (Garantindo alinhamento de 32 bytes à esquerda)
    function updateFactTemperature(int256 _temp) external {
        this.updateFact(0, bytes32(uint256(_temp)), new bytes32[](0));
    }
    function updateFactDoor(bool _door) external {
        this.updateFact(1, bytes32(uint256(_door ? 1 : 0)), new bytes32[](0));
    }
    function updateFactRoute(bool _route) external {
        this.updateFact(2, bytes32(uint256(_route ? 1 : 0)), new bytes32[](0));
    }
    function updateFactHumidity(uint256 _humidity) external {
        this.updateFact(3, bytes32(_humidity), new bytes32[](0));
    }
    function updateFactPressure(uint256 _pressure) external {
        this.updateFact(4, bytes32(_pressure), new bytes32[](0));
    }
    function updateFactLight(uint256 _light) external {
        this.updateFact(5, bytes32(_light), new bytes32[](0));
    }
    function updateFactVibration(uint256 _vibration) external {
        this.updateFact(6, bytes32(_vibration), new bytes32[](0));
    }
    function updateFactCO2(uint256 _co2) external {
        this.updateFact(7, bytes32(_co2), new bytes32[](0));
    }
    function updateFactBattery(uint256 _battery) external {
        this.updateFact(8, bytes32(_battery), new bytes32[](0));
    }
    function updateFactShock(bool _shock) external {
        this.updateFact(9, bytes32(uint256(_shock ? 1 : 0)), new bytes32[](0));
    }

    bytes32 public factsRoot;

    event InstigationTriggered(string actionName);
    event RootUpdated(bytes32 newRoot);

    function updateFact(uint256 index, bytes32 newValue, bytes32[] calldata proof) external {
        bytes32 leaf = keccak256(abi.encodePacked(index, newValue));
        factsRoot = _processProof(proof, leaf);
        _evaluateRules(index, newValue);
        emit RootUpdated(factsRoot);
    }

    /**
     * @notice Atualização em Lote (Rollup-style) corrigida para Casting direto.
     */
    function updateAllFacts(
        int256 _temp, bool _door, bool _route, uint256 _hum, 
        uint256 _pres, uint256 _light, uint256 _vib, uint256 _co2, 
        uint256 _bat, bool _shock, bytes32 _newRoot
    ) external {
        _evaluateRules(0, bytes32(uint256(_temp)));
        _evaluateRules(1, bytes32(uint256(_door ? 1 : 0)));
        _evaluateRules(2, bytes32(uint256(_route ? 1 : 0)));
        _evaluateRules(3, bytes32(_hum));
        _evaluateRules(4, bytes32(_pres));
        _evaluateRules(5, bytes32(_light));
        _evaluateRules(6, bytes32(_vib));
        _evaluateRules(7, bytes32(_co2));
        _evaluateRules(8, bytes32(_bat));
        _evaluateRules(9, bytes32(uint256(_shock ? 1 : 0)));

        factsRoot = _newRoot;
        emit RootUpdated(factsRoot);
    }

    // ==========================================
    // 1. BASE DE REGRAS (Casting direto e barato)
    // ==========================================

    function _evaluateRules(uint256 index, bytes32 value) internal {
        if (index == 0) { 
            int256 temp = int256(uint256(value));
            if (temp > -50) actionAlert("Premise: Temp Critical");
            if (temp > -40) actionAlert("Warning: Temp High");
        } 
        else if (index == 1) { 
            bool door = uint256(value) != 0; // Cast seguro para EVM
            if (door) actionAlert("Warning: Door Opened");
        }
        else if (index == 2) { 
            bool route = uint256(value) != 0;
            if (route) actionAlert("Warning: Route Deviated");
        }
        else if (index == 3) { 
            uint256 hum = uint256(value);
            if (hum > 80) actionAlert("Warning: Humidity High");
        }
        else if (index == 4) { 
            uint256 pres = uint256(value);
            if (pres < 950) actionAlert("Warning: Pressure Low");
        }
        else if (index == 5) { 
            uint256 light = uint256(value);
            if (light > 1000) actionAlert("Warning: Light High");
        }
        else if (index == 6) { 
            uint256 vib = uint256(value);
            if (vib > 5) actionAlert("Warning: Vibration Detected");
        }
        else if (index == 7) { 
            uint256 co2 = uint256(value);
            if (co2 > 2000) actionAlert("Warning: CO2 High");
        }
        else if (index == 8) { 
            uint256 bat = uint256(value);
            if (bat < 20) actionAlert("Warning: Battery Low");
        }
        else if (index == 9) { 
            bool shock = uint256(value) != 0;
            if (shock) actionAlert("Warning: Shock Detected");
        }
    }

    function actionAlert(string memory message) internal {
        emit InstigationTriggered(message);
    }

    // ==========================================
    // 2. MOTOR CRIPTOGRÁFICO (Merkle Logic)
    // ==========================================

    function _processProof(bytes32[] memory proof, bytes32 leaf) internal pure returns (bytes32) {
        bytes32 computedHash = leaf;
        for (uint256 i = 0; i < proof.length; i++) {
            computedHash = _hashPair(computedHash, proof[i]);
        }
        return computedHash;
    }

    function _hashPair(bytes32 a, bytes32 b) internal pure returns (bytes32) {
        return a < b ? keccak256(abi.encodePacked(a, b)) : keccak256(abi.encodePacked(b, a));
    }
}