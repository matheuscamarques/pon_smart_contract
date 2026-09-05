// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title PONLogistics
 * @author Matheus de Camargo Mar
 * @notice Implementação base do PON (Production Oriented Network) com atualização e avaliação reativa de fatos logísticos.
 *         Cada fato é armazenado individualmente e as regras são avaliadas apenas quando há mutação, otimizando notificações e eficiência.
 *         Ideal para cenários de rastreabilidade, monitoramento e automação de alertas logísticos em tempo real.
 */
contract PONLogistics {
    // --- FATOS (Facts) ---
    int256 public factTemperature;
    bool public factDoorOpen;
    bool public factRouteDeviated;
    int256 public factHumidity;
    int256 public factPressure;
    int256 public factLight;
    int256 public factVibration;
    int256 public factCO2;
    int256 public factBattery;
    bool public factShockDetected;

    event ActionExecuted(string actionName);

    /**
     * @notice Atualização consolidada. Mantém a reatividade do PON avaliando 
     * regras apenas para os fatos que sofreram mutação.
     */
    function updateAll(
        int256 _temp, bool _door, bool _route, int256 _humidity, 
        int256 _pressure, int256 _light, int256 _vibration, 
        int256 _co2, int256 _battery, bool _shock
    ) external {
        
        // 1. Controle de Deltas em Memória (Evita duplo disparo)
        bool tempChanged = false;
        if (factTemperature != _temp) {
            factTemperature = _temp;
            tempChanged = true;
        }

        bool doorChanged = false;
        if (factDoorOpen != _door) {
            factDoorOpen = _door;
            doorChanged = true;
        }

        // 2. Avaliação e Notificação Direta (Fatos Simples)
        if (factRouteDeviated != _route) {
            factRouteDeviated = _route;
            notifyRuleRoute();
        }

        if (factHumidity != _humidity) {
            factHumidity = _humidity;
            notifyRuleHumidityHigh();
        }

        if (factPressure != _pressure) {
            factPressure = _pressure;
            notifyRulePressureLow();
        }

        if (factLight != _light) {
            factLight = _light;
            notifyRuleLightHigh();
        }

        if (factVibration != _vibration) {
            factVibration = _vibration;
            notifyRuleVibrationDetected();
        }

        if (factCO2 != _co2) {
            factCO2 = _co2;
            notifyRuleCO2High();
        }

        if (factBattery != _battery) {
            factBattery = _battery;
            notifyRuleBatteryLow();
        }

        if (factShockDetected != _shock) {
            factShockDetected = _shock;
            notifyRuleShockDetected();
        }

        // 3. Resolução de Regras Compostas e Sobrepostas
        // Garante que a regra dependente de 2 fatos seja chamada apenas 1x
        if (tempChanged || doorChanged) {
            notifyRuleTempAndDoor();
        }
        
        if (tempChanged) {
            notifyRuleTempHigh();
        }
    }
    
    // --- ATUALIZAÇÃO DE FATOS E NOTIFICAÇÃO (Edge/Oracles chamam aqui) ---
    function updateFactTemperature(int256 _temp) external {
        if (factTemperature != _temp) {
            factTemperature = _temp;
            // Notifica cirurgicamente apenas as regras dependentes
            notifyRuleTempAndDoor();
            notifyRuleTempHigh();
        }
    }

    function updateFactDoor(bool _door) external {
        if (factDoorOpen != _door) {
            factDoorOpen = _door;
            notifyRuleTempAndDoor();
        }
    }

    function updateFactRoute(bool _route) external {
        if (factRouteDeviated != _route) {
            factRouteDeviated = _route;
            notifyRuleRoute();
        }
    }

    function updateFactHumidity(int256 _humidity) external {
        if (factHumidity != _humidity) {
            factHumidity = _humidity;
            notifyRuleHumidityHigh();
        }
    }

    function updateFactPressure(int256 _pressure) external {
        if (factPressure != _pressure) {
            factPressure = _pressure;
            notifyRulePressureLow();
        }
    }

    function updateFactLight(int256 _light) external {
        if (factLight != _light) {
            factLight = _light;
            notifyRuleLightHigh();
        }
    }

    function updateFactVibration(int256 _vibration) external {
        if (factVibration != _vibration) {
            factVibration = _vibration;
            notifyRuleVibrationDetected();
        }
    }

    function updateFactCO2(int256 _co2) external {
        if (factCO2 != _co2) {
            factCO2 = _co2;
            notifyRuleCO2High();
        }
    }

    function updateFactBattery(int256 _battery) external {
        if (factBattery != _battery) {
            factBattery = _battery;
            notifyRuleBatteryLow();
        }
    }

    function updateFactShock(bool _shock) external {
        if (factShockDetected != _shock) {
            factShockDetected = _shock;
            notifyRuleShockDetected();
        }
    }

    // --- REGRAS (Rules - Avaliação Lógica Isolada) ---
    function notifyRuleTempAndDoor() internal {
        if (factTemperature > -50 && factDoorOpen) {
            actionTriggerAlert("Critical: Temp high and door open");
        }
    }

    function notifyRuleTempHigh() internal {
        if (factTemperature > -40) {
            actionTriggerAlert("Warning: Temp too high");
        }
    }

    function notifyRuleRoute() internal {
        if (factRouteDeviated) {
            actionTriggerAlert("Warning: Route deviated");
        }
    }

    function notifyRuleHumidityHigh() internal {
        if (factHumidity > 80) {
            actionTriggerAlert("Warning: Humidity too high");
        }
    }

    function notifyRulePressureLow() internal {
        if (factPressure < 950) {
            actionTriggerAlert("Warning: Pressure too low");
        }
    }

    function notifyRuleLightHigh() internal {
        if (factLight > 1000) {
            actionTriggerAlert("Warning: Light too high");
        }
    }

    function notifyRuleVibrationDetected() internal {
        if (factVibration > 5) {
            actionTriggerAlert("Warning: Vibration detected");
        }
    }

    function notifyRuleCO2High() internal {
        if (factCO2 > 2000) {
            actionTriggerAlert("Warning: CO2 too high");
        }
    }

    function notifyRuleBatteryLow() internal {
        if (factBattery < 20) {
            actionTriggerAlert("Warning: Battery low");
        }
    }

    function notifyRuleShockDetected() internal {
        if (factShockDetected) {
            actionTriggerAlert("Warning: Shock detected");
        }
    }

    // --- AÇÕES (Actions - Side Effects On-Chain) ---
    function actionTriggerAlert(string memory message) internal {
        emit ActionExecuted(message);
    }
}