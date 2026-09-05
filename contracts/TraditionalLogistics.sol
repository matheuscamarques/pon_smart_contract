// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title TraditionalLogistics
 * @author Matheus de Camargo Mar
 * @notice Implementação tradicional do PON (Production Oriented Network) com lógica monolítica.
 *         Cada atualização de fato força a revalidação completa de todas as regras, priorizando simplicidade e clareza.
 *         Útil para comparação de desempenho, referência didática e cenários onde a transparência da lógica é mais importante que a eficiência de gas.
 */
contract TraditionalLogistics {
    // --- ESTADO (Variables) ---
    int256 public temperature;
    bool public isDoorOpen;
    bool public isRouteDeviated;
    int256 public humidity;
    int256 public pressure;
    int256 public light;
    int256 public vibration;
    int256 public co2;
    int256 public battery;
    bool public shockDetected;

    event AlertTriggered(string reason);

    function updateAll(
        int256 _temp, bool _door, bool _route, int256 _humidity, 
        int256 _pressure, int256 _light, int256 _vibration, 
        int256 _co2, int256 _battery, bool _shock
    ) external {
        temperature = _temp;
        isDoorOpen = _door;
        isRouteDeviated = _route;
        humidity = _humidity;
        pressure = _pressure;
        light = _light;
        vibration = _vibration;
        co2 = _co2;
        battery = _battery;
        shockDetected = _shock;
        
        evaluateAllRules();
    }
    
    // --- ATUALIZAÇÃO (Cada atualização força a validação completa) ---
    function updateTemperature(int256 _temp) external {
        temperature = _temp;
        evaluateAllRules();
    }

    function updateDoor(bool _door) external {
        isDoorOpen = _door;
        evaluateAllRules();
    }

    function updateRoute(bool _route) external {
        isRouteDeviated = _route;
        evaluateAllRules();
    }

    function updateHumidity(int256 _humidity) external {
        humidity = _humidity;
        evaluateAllRules();
    }

    function updatePressure(int256 _pressure) external {
        pressure = _pressure;
        evaluateAllRules();
    }

    function updateLight(int256 _light) external {
        light = _light;
        evaluateAllRules();
    }

    function updateVibration(int256 _vibration) external {
        vibration = _vibration;
        evaluateAllRules();
    }

    function updateCO2(int256 _co2) external {
        co2 = _co2;
        evaluateAllRules();
    }

    function updateBattery(int256 _battery) external {
        battery = _battery;
        evaluateAllRules();
    }

    function updateShock(bool _shock) external {
        shockDetected = _shock;
        evaluateAllRules();
    }

    // --- LÓGICA MONOLÍTICA (O ralo de Gas) ---
    function evaluateAllRules() internal {
        // Regra 1
        if (temperature > -50 && isDoorOpen) {
            emit AlertTriggered("Critical: Temp high and door open");
        }
        // Regra 2
        if (temperature > -40) {
            emit AlertTriggered("Warning: Temp too high");
        }
        // Regra 3
        if (isRouteDeviated) {
            emit AlertTriggered("Warning: Route deviated");
        }
        // Regra 4
        if (humidity > 80) {
            emit AlertTriggered("Warning: Humidity too high");
        }
        // Regra 5
        if (pressure < 950) {
            emit AlertTriggered("Warning: Pressure too low");
        }
        // Regra 6
        if (light > 1000) {
            emit AlertTriggered("Warning: Light too high");
        }
        // Regra 7
        if (vibration > 5) {
            emit AlertTriggered("Warning: Vibration detected");
        }
        // Regra 8
        if (co2 > 2000) {
            emit AlertTriggered("Warning: CO2 too high");
        }
        // Regra 9
        if (battery < 20) {
            emit AlertTriggered("Warning: Battery low");
        }
        // Regra 10
        if (shockDetected) {
            emit AlertTriggered("Warning: Shock detected");
        }
    }
}