// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title TransientPONLogistics
 * @author Matheus de Camargo Marques
 * @notice Implementação completa do PON utilizando Armazenamento Transiente (EIP-1153)
 * @dev O Transient Storage é limpo automaticamente ao fim de cada transação.
 */
contract TransientPONLogistics {

    // --- 1. BASE DE FATOS PERSISTENTE (Storage - Custo: 20k/2.1k gas) ---
    struct LogisticsState {
        int256 temperature;
        bool   doorOpen;
        bool   routeDeviated;
        uint256 humidity;
        uint256 pressure;
        uint256 light;
        uint256 vibration;
        uint256 co2;
        uint256 battery;
        bool   shockDetected;
    }

    LogisticsState private state;

    // --- 2. SLOTS TRANSIENTES (Hashes para identificação - Custo: 100 gas) ---
    // Usados para evitar disparos duplicados ou rastrear alterações na mesma TX.
    bytes32 private constant SESSION_NOTIFIED_SLOT = keccak256("session.notified");
    bytes32 private constant UPDATE_COUNT_SLOT    = keccak256("session.updatecount");

    event InstigationTriggered(string actionName);

    /**
     * @notice Atualização em lote utilizando EIP-1153 para controle de sessão.
     * @dev Garante que regras compostas não sejam disparadas múltiplas vezes na mesma TX.
     */
    function updateAllTransient(
        int256 _temp, bool _door, bool _route, uint256 _hum, 
        uint256 _pres, uint256 _light, uint256 _vib, uint256 _co2, 
        uint256 _bat, bool _shock
    ) external {
        // 1. Limpeza de Segurança (Garante que a sessão transiente comece limpa)
        _tstore(SESSION_NOTIFIED_SLOT, 0);

        bool tempChanged = false;
        if (state.temperature != _temp) {
            state.temperature = _temp;
            tempChanged = true;
        }

        bool doorChanged = false;
        if (state.doorOpen != _door) {
            state.doorOpen = _door;
            doorChanged = true;
        }

        if (state.routeDeviated != _route) {
            state.routeDeviated = _route;
            if (_route) ruleWarning("Route Deviated");
        }

        if (state.humidity != _hum) {
            state.humidity = _hum;
            if (_hum > 80) ruleWarning("Humidity High");
        }

        if (state.pressure != _pres) {
            state.pressure = _pres;
            if (_pres < 950) ruleWarning("Pressure Low");
        }

        if (state.light != _light) {
            state.light = _light;
            if (_light > 1000) ruleWarning("Light High");
        }

        if (state.vibration != _vib) {
            state.vibration = _vib;
            if (_vib > 5) ruleWarning("Vibration Detected");
        }

        if (state.co2 != _co2) {
            state.co2 = _co2;
            if (_co2 > 2000) ruleWarning("CO2 High");
        }

        if (state.battery != _bat) {
            state.battery = _bat;
            if (_bat < 20) ruleWarning("Battery Low");
        }

        if (state.shockDetected != _shock) {
            state.shockDetected = _shock;
            if (_shock) ruleWarning("Shock Detected");
        }

        // 2. Avaliação de Premissas Dependentes
        // Se ambos mudarem, 'conditionTempAndDoor' será chamada duas vezes.
        // O Transient Storage ('SESSION_NOTIFIED_SLOT') garante que o Alerta só saia UMA vez.
        if (tempChanged) premiseTempCritical(_temp);
        if (doorChanged) premiseDoorOpen(_door);

        // 3. Limpeza Final (Boa prática do EIP-1153 para evitar vazamento de estado em chamadas reentrantes)
        _tstore(SESSION_NOTIFIED_SLOT, 0);
    }

    // ==========================================
    // 3. MÉTODOS DE ATUALIZAÇÃO (FBE)
    // ==========================================

    function methodUpdateTemperature(int256 _temp) external {
        if (state.temperature != _temp) {
            state.temperature = _temp;
            _tstore(keccak256("fact.temp"), uint256(_temp)); // Registo transiente
            premiseTempCritical(_temp);
        }
    }

    function methodUpdateDoor(bool _door) external {
        if (state.doorOpen != _door) {
            state.doorOpen = _door;
            _tstore(keccak256("fact.door"), _door ? 1 : 0);
            premiseDoorOpen(_door);
        }
    }

    function methodUpdateRoute(bool _route) external {
        if (state.routeDeviated != _route) {
            state.routeDeviated = _route;
            if (_route) ruleWarning("Route Deviated");
        }
    }

    function methodUpdateHumidity(uint256 _hum) external {
        if (state.humidity != _hum) {
            state.humidity = _hum;
            if (_hum > 80) ruleWarning("Humidity High");
        }
    }

    function methodUpdatePressure(uint256 _pres) external {
        if (state.pressure != _pres) {
            state.pressure = _pres;
            if (_pres < 950) ruleWarning("Pressure Low");
        }
    }

    function methodUpdateLight(uint256 _light) external {
        if (state.light != _light) {
            state.light = _light;
            if (_light > 1000) ruleWarning("Light High");
        }
    }

    function methodUpdateVibration(uint256 _vib) external {
        if (state.vibration != _vib) {
            state.vibration = _vib;
            if (_vib > 5) ruleWarning("Vibration Detected");
        }
    }

    function methodUpdateCO2(uint256 _co2) external {
        if (state.co2 != _co2) {
            state.co2 = _co2;
            if (_co2 > 2000) ruleWarning("CO2 High");
        }
    }

    function methodUpdateBattery(uint256 _bat) external {
        if (state.battery != _bat) {
            state.battery = _bat;
            if (_bat < 20) ruleWarning("Battery Low");
        }
    }

    function methodUpdateShock(bool _shock) external {
        if (state.shockDetected != _shock) {
            state.shockDetected = _shock;
            if (_shock) ruleWarning("Shock Detected");
        }
    }

    // ==========================================
    // 4. BASE DE REGRAS (Utilizando Transient Storage)
    // ==========================================

    function premiseTempCritical(int256 _temp) internal {
        if (_temp > -50) conditionTempAndDoor();
    }

    function premiseDoorOpen(bool _door) internal {
        if (_door) conditionTempAndDoor();
    }

    /**
     * @dev Condição que utiliza Transient Storage para garantir atomicidade.
     * Útil em batch updates onde múltiplos sensores disparam a mesma regra.
     */
    function conditionTempAndDoor() internal {
        // Verificamos se já notificámos este erro NESTA transação (Session Flag)
        if (_tload(SESSION_NOTIFIED_SLOT) == 0) {
            if (state.temperature > -50 && state.doorOpen) {
                _tstore(SESSION_NOTIFIED_SLOT, 1); // Marca como notificado
                ruleCritical("Critical: Violation in current TX");
            }
        }
    }

    // ==========================================
    // 5. REGRAS E AÇÕES
    // ==========================================

    function ruleCritical(string memory _m) internal {
        emit InstigationTriggered(_m);
    }

    function ruleWarning(string memory _m) internal {
        emit InstigationTriggered(_m);
    }

    // ==========================================
    // 3. HELPERS YUL (EIP-1153 Opcodes)
    // ==========================================

    function _tstore(bytes32 slot, uint256 value) internal {
        assembly {
            tstore(slot, value)
        }
    }

    function _tload(bytes32 slot) internal view returns (uint256 value) {
        assembly {
            value := tload(slot)
        }
    }
}