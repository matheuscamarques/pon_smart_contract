// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title ShortCircuitPONLogistics
 * @author Matheus de Camargo Marques
 * @notice Implementação completa focada em Logic Gating e Short-Circuiting
 */
contract ShortCircuitPONLogistics {
    
    // --- BASE DE FATOS (Estado) ---
    int256 private temp;
    bool    private door;
    bool    private route;
    uint256 private hum;
    uint256 private pres;
    uint256 private light;
    uint256 private vib;
    uint256 private co2;
    uint256 private bat;
    bool    private shock;

    event InstigationTriggered(string actionName);

    /**
     * @notice Atualiza todos os sensores em lote aplicando a filosofia de Short-Circuit.
     * @dev Usa a avaliação preguiçosa (lazy evaluation) do Solidity para abortar 
     * processamentos desnecessários o mais cedo possível.
     */
    function updateAllShortCircuit(
        int256 _temp, bool _door, bool _route, uint256 _hum, 
        uint256 _pres, uint256 _light, uint256 _vib, uint256 _co2, 
        uint256 _bat, bool _shock
    ) external {
        // Variáveis de controle para a regra composta
        bool tempChanged = false;
        bool doorChanged = false;

        // [GATE: TEMP]
        // Se não mudou, pula o SSTORE e pula a avaliação de Temp High
        if (temp != _temp) {
            temp = _temp;
            tempChanged = true;
            if (_temp > -40) ruleWarning("Temp High");
        }

        // [GATE: DOOR]
        if (door != _door) {
            door = _door;
            doorChanged = true;
        }

        // [GATE: REGRA COMPOSTA (Temp + Door)]
        // O Ápice do Short-Circuiting:
        // 1º Gate: Mudou algo? (Se false, a EVM para aqui)
        // 2º Gate: A porta está aberta? (Booleano na memória é ultra barato)
        // 3º Gate: A temperatura passou do limite? (Matemática, fica por último)
        if ((tempChanged || doorChanged) && _door && _temp > -50) {
            ruleCritical("Violation: Door open with high temp");
        }

        // [GATE: ROUTE]
        if (route != _route) {
            route = _route;
            if (_route) ruleWarning("Route Deviated");
        }

        // [GATE: HUMIDITY]
        if (hum != _hum) {
            hum = _hum;
            if (_hum > 80) ruleWarning("Humidity High");
        }

        // [GATE: PRESSURE]
        if (pres != _pres) {
            pres = _pres;
            if (_pres < 950) ruleWarning("Pressure Low");
        }

        // [GATE: LIGHT]
        if (light != _light) {
            light = _light;
            if (_light > 1000) ruleWarning("Light High");
        }

        // [GATE: VIBRATION]
        if (vib != _vib) {
            vib = _vib;
            if (_vib > 5) ruleWarning("Vibration Detected");
        }

        // [GATE: CO2]
        if (co2 != _co2) {
            co2 = _co2;
            if (_co2 > 2000) ruleWarning("CO2 High");
        }

        // [GATE: BATTERY]
        if (bat != _bat) {
            bat = _bat;
            if (_bat < 20) ruleWarning("Battery Low");
        }

        // [GATE: SHOCK]
        if (shock != _shock) {
            shock = _shock;
            if (_shock) ruleWarning("Shock Detected");
        }
    }
    
    // ==========================================
    // 1. MÉTODOS DE ATUALIZAÇÃO (GATEKEEPERS)
    // ==========================================

    // Regra de Ouro 1: Early Return se o valor não mudou (Evita SSTORE)
    // Regra de Ouro 2: Gatilhos condicionais (Evita chamadas de função inúteis)

    function methodUpdateTemperature(int256 _temp) external {
        if (temp == _temp) return; 
        temp = _temp;
        // Portão: Só avalia premissas se o valor entrar na zona de risco
        if (_temp > -50) premiseTempCritical(_temp);
        if (_temp > -40) ruleWarning("Temp High");
    }

    function methodUpdateDoor(bool _door) external {
        if (door == _door) return;
        door = _door;
        // Portão: Se a porta fechou (false), não há risco de violação conjunta
        if (_door) conditionTempAndDoor(temp, _door);
    }

    function methodUpdateRoute(bool _route) external {
        if (route == _route) return;
        route = _route;
        if (_route) ruleWarning("Route Deviated");
    }

    function methodUpdateHumidity(uint256 _hum) external {
        if (hum == _hum) return;
        hum = _hum;
        if (_hum > 80) ruleWarning("Humidity High");
    }

    function methodUpdatePressure(uint256 _pres) external {
        if (pres == _pres) return;
        pres = _pres;
        if (_pres < 950) ruleWarning("Pressure Low");
    }

    function methodUpdateLight(uint256 _light) external {
        if (light == _light) return;
        light = _light;
        if (_light > 1000) ruleWarning("Light High");
    }

    function methodUpdateVibration(uint256 _vib) external {
        if (vib == _vib) return;
        vib = _vib;
        if (_vib > 5) ruleWarning("Vibration Detected");
    }

    function methodUpdateCO2(uint256 _co2) external {
        if (co2 == _co2) return;
        co2 = _co2;
        if (_co2 > 2000) ruleWarning("CO2 High");
    }

    function methodUpdateBattery(uint256 _bat) external {
        if (bat == _bat) return;
        bat = _bat;
        if (_bat < 20) ruleWarning("Battery Low");
    }

    function methodUpdateShock(bool _shock) external {
        if (shock == _shock) return;
        shock = _shock;
        if (_shock) ruleWarning("Shock Detected");
    }

    // ==========================================
    // 2. BASE DE REGRAS (LOGIC GATING)
    // ==========================================

    /**
     * @dev Exemplo mestre de Short-Circuiting.
     * O booleano 'door' é verificado ANTES da comparação numérica 'temp'.
     * Se 'door' for false, a EVM ignora a comparação de temperatura.
     */
    function conditionTempAndDoor(int256 _currentTemp, bool _currentDoor) internal {
        // Portão: [Booleano (Barato)] && [Comparação (Médio)]
        if (_currentDoor && _currentTemp > -50) {
            ruleCritical("Violation: Door open with high temp");
        }
    }

    function premiseTempCritical(int256 _t) internal {
        // Só chama a condição se houver um portão aberto (porta aberta)
        if (door) conditionTempAndDoor(_t, door);
    }

    // ==========================================
    // 3. REGRAS E AÇÕES
    // ==========================================

    function ruleCritical(string memory _m) internal {
        emit InstigationTriggered(_m);
    }

    function ruleWarning(string memory _m) internal {
        emit InstigationTriggered(_m);
    }
}