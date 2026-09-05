// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title PONBitPackedLogistics
 * @author Matheus de Camargo Marques
 * @notice Implementação de Alto Desempenho do PON com Empacotamento de Bits (Bit-Packing)
 */
contract PONBitPackedLogistics {
    // Único slot de 256 bits para o estado global (State Footprint Mínimo)
    uint256 private packedFacts;

    // --- Mapa de Offsets (Posicionamento dos Fatos no Bitfield) ---
    uint256 private constant OFF_TEMP    = 0;   // 8 bits (int8)
    uint256 private constant OFF_DOOR    = 8;   // 1 bit  (bool)
    uint256 private constant OFF_ROUTE   = 9;   // 1 bit  (bool)
    uint256 private constant OFF_HUM     = 10;  // 8 bits (uint8)
    uint256 private constant OFF_PRES    = 18;  // 16 bits (uint16)
    uint256 private constant OFF_LIGHT   = 34;  // 16 bits (uint16)
    uint256 private constant OFF_VIB     = 50;  // 8 bits (uint8)
    uint256 private constant OFF_CO2     = 58;  // 16 bits (uint16)
    uint256 private constant OFF_BAT     = 74;  // 8 bits (uint8)
    uint256 private constant OFF_SHOCK   = 82;  // 1 bit  (bool)

    event InstigationTriggered(string actionName);

    // ==========================================
    // 3. ATUALIZAÇÃO EM LOTE (Batch Update)
    // ==========================================

    /**
     * @notice Atualiza todos os 10 sensores em uma única transação usando Solidity puro.
     * @dev Isola o ganho de eficiência do Storage (1 SSTORE) do ganho de processamento.
     */
    function updateAllBitPacked(
        int8 _temp, bool _door, bool _route, uint8 _hum, 
        uint16 _pres, uint16 _light, uint8 _vib, uint16 _co2, 
        uint8 _bat, bool _shock
    ) external {
        uint256 currentPacked = packedFacts;
        uint256 newPacked = currentPacked;
        bool hasChanges = false;

        // --- 1. DETECÇÃO DE DELTA E EMPACOTAMENTO EM MEMÓRIA ---

        // Temp
        int8 cTemp = int8(uint8((currentPacked >> OFF_TEMP) & 0xFF));
        bool tempChanged = (cTemp != _temp);
        if (tempChanged) {
            newPacked = (newPacked & ~(uint256(0xFF) << OFF_TEMP)) | (uint256(uint8(_temp)) << OFF_TEMP);
            hasChanges = true;
        }

        // Door
        bool cDoor = ((currentPacked >> OFF_DOOR) & 1) == 1;
        bool doorChanged = (cDoor != _door);
        if (doorChanged) {
            if (_door) newPacked |= (1 << OFF_DOOR);
            else newPacked &= ~(1 << OFF_DOOR);
            hasChanges = true;
        }

        // Route
        bool cRoute = ((currentPacked >> OFF_ROUTE) & 1) == 1;
        bool routeChanged = (cRoute != _route);
        if (routeChanged) {
            if (_route) newPacked |= (1 << OFF_ROUTE);
            else newPacked &= ~(1 << OFF_ROUTE);
            hasChanges = true;
        }

        // Humidity
        uint8 cHum = uint8((currentPacked >> OFF_HUM) & 0xFF);
        bool humChanged = (cHum != _hum);
        if (humChanged) {
            newPacked = (newPacked & ~(uint256(0xFF) << OFF_HUM)) | (uint256(_hum) << OFF_HUM);
            hasChanges = true;
        }

        // Pressure
        uint16 cPres = uint16((currentPacked >> OFF_PRES) & 0xFFFF);
        bool presChanged = (cPres != _pres);
        if (presChanged) {
            newPacked = (newPacked & ~(uint256(0xFFFF) << OFF_PRES)) | (uint256(_pres) << OFF_PRES);
            hasChanges = true;
        }

        // Light
        uint16 cLight = uint16((currentPacked >> OFF_LIGHT) & 0xFFFF);
        bool lightChanged = (cLight != _light);
        if (lightChanged) {
            newPacked = (newPacked & ~(uint256(0xFFFF) << OFF_LIGHT)) | (uint256(_light) << OFF_LIGHT);
            hasChanges = true;
        }

        // Vibration
        uint8 cVib = uint8((currentPacked >> OFF_VIB) & 0xFF);
        bool vibChanged = (cVib != _vib);
        if (vibChanged) {
            newPacked = (newPacked & ~(uint256(0xFF) << OFF_VIB)) | (uint256(_vib) << OFF_VIB);
            hasChanges = true;
        }

        // CO2
        uint16 cCO2 = uint16((currentPacked >> OFF_CO2) & 0xFFFF);
        bool co2Changed = (cCO2 != _co2);
        if (co2Changed) {
            newPacked = (newPacked & ~(uint256(0xFFFF) << OFF_CO2)) | (uint256(_co2) << OFF_CO2);
            hasChanges = true;
        }

        // Battery
        uint8 cBat = uint8((currentPacked >> OFF_BAT) & 0xFF);
        bool batChanged = (cBat != _bat);
        if (batChanged) {
            newPacked = (newPacked & ~(uint256(0xFF) << OFF_BAT)) | (uint256(_bat) << OFF_BAT);
            hasChanges = true;
        }

        // Shock
        bool cShock = ((currentPacked >> OFF_SHOCK) & 1) == 1;
        bool shockChanged = (cShock != _shock);
        if (shockChanged) {
            if (_shock) newPacked |= (1 << OFF_SHOCK);
            else newPacked &= ~(1 << OFF_SHOCK);
            hasChanges = true;
        }

        // --- 2. PERSISTÊNCIA ATÔMICA ---
        // Apenas 1 SSTORE se houver qualquer mutação
        if (hasChanges) {
            packedFacts = newPacked;
        }

        // --- 3. MOTOR DE INFERÊNCIA REATIVO (Roteamento PON) ---
        // Disparamos as regras EXCLUSIVAMENTE baseadas nos deltas

        if (tempChanged) {
            premiseTempCritical(_temp);
            premiseTempHigh(_temp);
        }
        if (doorChanged) {
            premiseDoorOpen(_door);
        }
        if (routeChanged) {
            conditionRouteDeviated(_route);
        }
        if (humChanged) {
            conditionHumidityHigh(_hum);
        }
        if (presChanged) {
            conditionPressureLow(_pres);
        }
        if (lightChanged) {
            conditionLightHigh(_light);
        }
        if (vibChanged) {
            conditionVibrationDetected(_vib);
        }
        if (co2Changed) {
            conditionCO2High(_co2);
        }
        if (batChanged) {
            conditionBatteryLow(_bat);
        }
        if (shockChanged) {
            conditionShockDetected(_shock);
        }
    }
    // ==========================================
    // 1. BASE DE FATOS (FBE - Fact Base Elements)
    // ==========================================

    function methodUpdateTemperature(int8 _temp) external {
        int8 current = int8(uint8((packedFacts >> OFF_TEMP) & 0xFF));
        if (current != _temp) {
            packedFacts = (packedFacts & ~(uint256(0xFF) << OFF_TEMP)) | (uint256(uint8(_temp)) << OFF_TEMP);
            premiseTempCritical(_temp);
            premiseTempHigh(_temp);
        }
    }

    function methodUpdateDoor(bool _door) external {
        bool current = ((packedFacts >> OFF_DOOR) & 1) == 1;
        if (current != _door) {
            if (_door) packedFacts |= (1 << OFF_DOOR);
            else packedFacts &= ~(1 << OFF_DOOR);
            premiseDoorOpen(_door);
        }
    }

    function methodUpdateRoute(bool _route) external {
        bool current = ((packedFacts >> OFF_ROUTE) & 1) == 1;
        if (current != _route) {
            if (_route) packedFacts |= (1 << OFF_ROUTE);
            else packedFacts &= ~(1 << OFF_ROUTE);
            conditionRouteDeviated(_route);
        }
    }

    function methodUpdateHumidity(uint8 _hum) external {
        uint8 current = uint8((packedFacts >> OFF_HUM) & 0xFF);
        if (current != _hum) {
            packedFacts = (packedFacts & ~(uint256(0xFF) << OFF_HUM)) | (uint256(_hum) << OFF_HUM);
            conditionHumidityHigh(_hum);
        }
    }

    function methodUpdatePressure(uint16 _pres) external {
        uint16 current = uint16((packedFacts >> OFF_PRES) & 0xFFFF);
        if (current != _pres) {
            packedFacts = (packedFacts & ~(uint256(0xFFFF) << OFF_PRES)) | (uint256(_pres) << OFF_PRES);
            conditionPressureLow(_pres);
        }
    }

    function methodUpdateLight(uint16 _light) external {
        uint16 current = uint16((packedFacts >> OFF_LIGHT) & 0xFFFF);
        if (current != _light) {
            packedFacts = (packedFacts & ~(uint256(0xFFFF) << OFF_LIGHT)) | (uint256(_light) << OFF_LIGHT);
            conditionLightHigh(_light);
        }
    }

    function methodUpdateVibration(uint8 _vib) external {
        uint8 current = uint8((packedFacts >> OFF_VIB) & 0xFF);
        if (current != _vib) {
            packedFacts = (packedFacts & ~(uint256(0xFF) << OFF_VIB)) | (uint256(_vib) << OFF_VIB);
            conditionVibrationDetected(_vib);
        }
    }

    function methodUpdateCO2(uint16 _co2) external {
        uint16 current = uint16((packedFacts >> OFF_CO2) & 0xFFFF);
        if (current != _co2) {
            packedFacts = (packedFacts & ~(uint256(0xFFFF) << OFF_CO2)) | (uint256(_co2) << OFF_CO2);
            conditionCO2High(_co2);
        }
    }

    function methodUpdateBattery(uint8 _bat) external {
        uint8 current = uint8((packedFacts >> OFF_BAT) & 0xFF);
        if (current != _bat) {
            packedFacts = (packedFacts & ~(uint256(0xFF) << OFF_BAT)) | (uint256(_bat) << OFF_BAT);
            conditionBatteryLow(_bat);
        }
    }

    function methodUpdateShock(bool _shock) external {
        bool current = ((packedFacts >> OFF_SHOCK) & 1) == 1;
        if (current != _shock) {
            if (_shock) packedFacts |= (1 << OFF_SHOCK);
            else packedFacts &= ~(1 << OFF_SHOCK);
            conditionShockDetected(_shock);
        }
    }

    // ==========================================
    // 2. BASE DE REGRAS (Rule Base - RB)
    // ==========================================

    // --- Getters Internos (Evitam SLOAD redundante) ---
    function isDoorOpen() internal view returns (bool) { return ((packedFacts >> OFF_DOOR) & 1) == 1; }
    function getTemp() internal view returns (int8) { return int8(uint8((packedFacts >> OFF_TEMP) & 0xFF)); }

    // --- Premissas e Condições ---
    function premiseTempCritical(int8 _temp) internal {
        if (_temp > -50) conditionTempAndDoor(_temp, isDoorOpen());
    }

    function premiseTempHigh(int8 _temp) internal {
        if (_temp > -40) ruleWarning("Temp high");
    }

    function premiseDoorOpen(bool _door) internal {
        if (_door) conditionTempAndDoor(getTemp(), _door);
    }

    function conditionTempAndDoor(int8 _temp, bool _door) internal {
        if (_temp > -50 && _door) ruleCritical("Temp crit & Door open");
    }

    function conditionRouteDeviated(bool _route) internal { if (_route) ruleWarning("Route deviated"); }
    function conditionHumidityHigh(uint8 _hum) internal { if (_hum > 80) ruleWarning("Humidity high"); }
    function conditionPressureLow(uint16 _pres) internal { if (_pres < 950) ruleWarning("Pressure low"); }
    function conditionLightHigh(uint16 _light) internal { if (_light > 1000) ruleWarning("Light high"); }
    function conditionVibrationDetected(uint8 _vib) internal { if (_vib > 5) ruleWarning("Vibration"); }
    function conditionCO2High(uint16 _co2) internal { if (_co2 > 2000) ruleWarning("CO2 high"); }
    function conditionBatteryLow(uint8 _bat) internal { if (_bat < 20) ruleWarning("Battery low"); }
    function conditionShockDetected(bool _shock) internal { if (_shock) ruleWarning("Shock detected"); }

    // --- Regras e Ações ---
    function ruleCritical(string memory _msg) internal { emit InstigationTriggered(_msg); }
    function ruleWarning(string memory _msg) internal { emit InstigationTriggered(_msg); }
}