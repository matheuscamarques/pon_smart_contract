// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ParadigmaticPONLogistics
 * @author Matheus de Camargo Mar
 * @notice Implementação do PON (Production Oriented Network) baseada em paradigma de regras explícitas.
 *         Cada fato logístico é armazenado como atributo individual e processado por um motor de inferência sequencial.
 *         Ideal para cenários didáticos, validação de lógica e rastreabilidade total das premissas e condições.
 */
contract ParadigmaticPONLogistics {

    // ==========================================
    // 1. BASE DE FATOS (Fact Base - FB)
    // ==========================================
    
    // --- FBEs: Atributos (Attributes) ---
    int256 private attributeTemperature;
    bool private attributeDoorOpen;
    bool private attributeRouteDeviated;
    int256 private attributeHumidity;
    int256 private attributePressure;
    int256 private attributeLight;
    int256 private attributeVibration;
    int256 private attributeCO2;
    int256 private attributeBattery;
    bool private attributeShockDetected;

    event InstigationTriggered(string actionName);

    /**
     * @notice Recebe múltiplos fatos em uma única transação, mas mantém
     * o roteamento estrito do PON (Atributo -> Premissa).
     */
    function methodUpdateAll(
        int256 _temp, bool _door, bool _route, int256 _humidity, 
        int256 _pressure, int256 _light, int256 _vibration, 
        int256 _co2, int256 _battery, bool _shock
    ) external {
        
        if (attributeTemperature != _temp) {
            attributeTemperature = _temp;
            premiseTempCritical();
            premiseTempHigh();
        }

        if (attributeDoorOpen != _door) {
            attributeDoorOpen = _door;
            premiseDoorOpen();
        }

        if (attributeRouteDeviated != _route) {
            attributeRouteDeviated = _route;
            premiseRouteDeviated();
        }

        if (attributeHumidity != _humidity) {
            attributeHumidity = _humidity;
            premiseHumidityHigh();
        }

        if (attributePressure != _pressure) {
            attributePressure = _pressure;
            premisePressureLow();
        }

        if (attributeLight != _light) {
            attributeLight = _light;
            premiseLightHigh();
        }

        if (attributeVibration != _vibration) {
            attributeVibration = _vibration;
            premiseVibrationDetected();
        }

        if (attributeCO2 != _co2) {
            attributeCO2 = _co2;
            premiseCO2High();
        }

        if (attributeBattery != _battery) {
            attributeBattery = _battery;
            premiseBatteryLow();
        }

        if (attributeShockDetected != _shock) {
            attributeShockDetected = _shock;
            premiseShockDetected();
        }
    }
    
    // --- FBEs: Métodos (Methods) ---
    function methodUpdateTemperature(int256 _temp) external {
        if (attributeTemperature != _temp) {
            attributeTemperature = _temp;
            premiseTempCritical();
            premiseTempHigh();
        }
    }

    function methodUpdateDoor(bool _door) external {
        if (attributeDoorOpen != _door) {
            attributeDoorOpen = _door;
            premiseDoorOpen();
        }
    }

    function methodUpdateRoute(bool _route) external {
        if (attributeRouteDeviated != _route) {
            attributeRouteDeviated = _route;
            premiseRouteDeviated();
        }
    }

    function methodUpdateHumidity(int256 _humidity) external {
        if (attributeHumidity != _humidity) {
            attributeHumidity = _humidity;
            premiseHumidityHigh();
        }
    }

    function methodUpdatePressure(int256 _pressure) external {
        if (attributePressure != _pressure) {
            attributePressure = _pressure;
            premisePressureLow();
        }
    }

    function methodUpdateLight(int256 _light) external {
        if (attributeLight != _light) {
            attributeLight = _light;
            premiseLightHigh();
        }
    }

    function methodUpdateVibration(int256 _vibration) external {
        if (attributeVibration != _vibration) {
            attributeVibration = _vibration;
            premiseVibrationDetected();
        }
    }

    function methodUpdateCO2(int256 _co2) external {
        if (attributeCO2 != _co2) {
            attributeCO2 = _co2;
            premiseCO2High();
        }
    }

    function methodUpdateBattery(int256 _battery) external {
        if (attributeBattery != _battery) {
            attributeBattery = _battery;
            premiseBatteryLow();
        }
    }

    function methodUpdateShock(bool _shock) external {
        if (attributeShockDetected != _shock) {
            attributeShockDetected = _shock;
            premiseShockDetected();
        }
    }


    // ==========================================
    // 2. BASE DE REGRAS (Rule Base - RB)
    // ==========================================

    // --- Premissas (Premises) ---
    function premiseTempCritical() internal {
        if (attributeTemperature > -50) {
            conditionTempAndDoor();
        }
    }

    function premiseTempHigh() internal {
        if (attributeTemperature > -40) {
            conditionTempHigh();
        }
    }

    function premiseDoorOpen() internal {
        if (attributeDoorOpen == true) {
            conditionTempAndDoor();
        }
    }

    function premiseRouteDeviated() internal {
        if (attributeRouteDeviated == true) {
            conditionRouteDeviated();
        }
    }

    function premiseHumidityHigh() internal {
        if (attributeHumidity > 80) {
            conditionHumidityHigh();
        }
    }

    function premisePressureLow() internal {
        if (attributePressure < 950) {
            conditionPressureLow();
        }
    }

    function premiseLightHigh() internal {
        if (attributeLight > 1000) {
            conditionLightHigh();
        }
    }

    function premiseVibrationDetected() internal {
        if (attributeVibration > 5) {
            conditionVibrationDetected();
        }
    }

    function premiseCO2High() internal {
        if (attributeCO2 > 2000) {
            conditionCO2High();
        }
    }

    function premiseBatteryLow() internal {
        if (attributeBattery < 20) {
            conditionBatteryLow();
        }
    }

    function premiseShockDetected() internal  {
        if (attributeShockDetected == true) {
            conditionShockDetected();
        }
    }

    // --- Condições (Conditions) ---
    function conditionTempAndDoor() internal  {
        if (attributeTemperature > -50 && attributeDoorOpen) {
            ruleCriticalViolation();
        }
    }

    function conditionTempHigh() internal  {
        ruleWarningTemp();
    }

    function conditionRouteDeviated() internal {
        ruleWarningRoute();
    }

    function conditionHumidityHigh() internal  {
        ruleWarningHumidity();
    }

    function conditionPressureLow() internal {
        ruleWarningPressure();
    }

    function conditionLightHigh() internal  {
        ruleWarningLight();
    }

    function conditionVibrationDetected() internal  {
        ruleWarningVibration();
    }

    function conditionCO2High() internal  {
        ruleWarningCO2();
    }

    function conditionBatteryLow() internal  {
        ruleWarningBattery();
    }

    function conditionShockDetected() internal {
        ruleWarningShock();
    }

    // --- Regras (Rules) ---
    function ruleCriticalViolation() internal {
        actionAlertCritical();
    }

    function ruleWarningTemp() internal {
        actionAlertTemp();
    }

    function ruleWarningRoute() internal {
        actionAlertRoute();
    }

    function ruleWarningHumidity() internal {
        actionAlertHumidity();
    }

    function ruleWarningPressure() internal {
        actionAlertPressure();
    }

    function ruleWarningLight() internal {
        actionAlertLight();
    }

    function ruleWarningVibration() internal {
        actionAlertVibration();
    }

    function ruleWarningCO2() internal {
        actionAlertCO2();
    }

    function ruleWarningBattery() internal {
        actionAlertBattery();
    }

    function ruleWarningShock() internal {
        actionAlertShock();
    }

    // --- Ações (Actions) e Instigações (Instigations) ---
    function actionAlertCritical() internal {
        instigationEmitEvent("Critical: Temp high and door open");
    }

    function actionAlertTemp() internal {
        instigationEmitEvent("Warning: Temp too high");
    }

    function actionAlertRoute() internal {
        instigationEmitEvent("Warning: Route deviated");
    }

    function actionAlertHumidity() internal {
        instigationEmitEvent("Warning: Humidity too high");
    }

    function actionAlertPressure() internal {
        instigationEmitEvent("Warning: Pressure too low");
    }

    function actionAlertLight() internal {
        instigationEmitEvent("Warning: Light too high");
    }

    function actionAlertVibration() internal {
        instigationEmitEvent("Warning: Vibration detected");
    }

    function actionAlertCO2() internal {
        instigationEmitEvent("Warning: CO2 too high");
    }

    function actionAlertBattery() internal {
        instigationEmitEvent("Warning: Battery low");
    }

    function actionAlertShock() internal {
        instigationEmitEvent("Warning: Shock detected");
    }

    function instigationEmitEvent(string memory message) internal {
        emit InstigationTriggered(message);
    }
}