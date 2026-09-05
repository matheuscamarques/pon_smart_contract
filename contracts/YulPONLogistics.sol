// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title YulPONLogistics
 * @author Matheus de Camargo Marques
 * @notice O Limite Teórico: Implementação em Assembly Puro (Yul)
 */
contract YulPONLogistics {

    // Assinatura do evento para o opcode log1: keccak256("InstigationTriggered(string)")
    bytes32 private constant EVENT_SIG = 0x8b8e0d165681992036c05d5d8d4c2d3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b;

    // --- MAPA DE STORAGE (0-9) ---
    // 0:Temp, 1:Door, 2:Route, 3:Hum, 4:Pres, 5:Light, 6:Vib, 7:CO2, 8:Bat, 9:Shock

    function updateAllYul(
        int256 _temp, bool _door, bool _route, uint256 _hum, 
        uint256 _pres, uint256 _light, uint256 _vib, uint256 _co2, 
        uint256 _bat, bool _shock
    ) external {
        assembly {
            // Flags de controle em memória (stack) para evitar "Double Firing"
            let tempChanged := 0
            let doorChanged := 0

            // [SLOT 0: TEMP]
            if iszero(eq(sload(0), _temp)) {
                sstore(0, _temp)
                tempChanged := 1
            }

            // [SLOT 1: DOOR]
            if iszero(eq(sload(1), _door)) {
                sstore(1, _door)
                doorChanged := 1
            }

            // [REGRA COMPOSTA: TEMP & DOOR]
            // Só avalia se algum dos dois mudou na transação atual
            if or(tempChanged, doorChanged) {
                if sgt(_temp, sub(0, 50)) {
                    if eq(_door, 1) {
                        mstore(0, 0x20)
                        mstore(0x20, 19) // Tamanho da string
                        mstore(0x40, "Critical: Temp/Door") 
                        log1(0, 0x60, EVENT_SIG)
                    }
                }
            }

            // [SLOT 2: ROUTE]
            if iszero(eq(sload(2), _route)) {
                sstore(2, _route)
                if _route {
                    mstore(0, 0x20)
                    mstore(0x20, 15)
                    mstore(0x40, "Route Activated")
                    log1(0, 0x60, EVENT_SIG)
                }
            }

            // [SLOT 3: HUMIDITY]
            if iszero(eq(sload(3), _hum)) {
                sstore(3, _hum)
                if gt(_hum, 80) {
                    mstore(0, 0x20)
                    mstore(0x20, 19)
                    mstore(0x40, "Warning: High Humid")
                    log1(0, 0x60, EVENT_SIG)
                }
            }

            // [SLOT 4: PRESSURE]
            if iszero(eq(sload(4), _pres)) {
                sstore(4, _pres)
                if lt(_pres, 950) {
                    mstore(0, 0x20)
                    mstore(0x20, 21)
                    mstore(0x40, "Warning: Low Pressure")
                    log1(0, 0x60, EVENT_SIG)
                }
            }

            // [SLOT 5: LIGHT]
            if iszero(eq(sload(5), _light)) {
                sstore(5, _light)
                if gt(_light, 1000) {
                    mstore(0, 0x20)
                    mstore(0x20, 19)
                    mstore(0x40, "Warning: High Light")
                    log1(0, 0x60, EVENT_SIG)
                }
            }

            // [SLOT 6: VIBRATION]
            if iszero(eq(sload(6), _vib)) {
                sstore(6, _vib)
                if gt(_vib, 5) {
                    mstore(0, 0x20)
                    mstore(0x20, 23)
                    mstore(0x40, "Warning: High Vibration")
                    log1(0, 0x60, EVENT_SIG)
                }
            }

            // [SLOT 7: CO2]
            if iszero(eq(sload(7), _co2)) {
                sstore(7, _co2)
                if gt(_co2, 2000) {
                    mstore(0, 0x20)
                    mstore(0x20, 17)
                    mstore(0x40, "Warning: High CO2")
                    log1(0, 0x60, EVENT_SIG)
                }
            }

            // [SLOT 8: BATTERY]
            if iszero(eq(sload(8), _bat)) {
                sstore(8, _bat)
                if lt(_bat, 20) {
                    mstore(0, 0x20)
                    mstore(0x20, 20)
                    mstore(0x40, "Warning: Low Battery")
                    log1(0, 0x60, EVENT_SIG)
                }
            }

            // [SLOT 9: SHOCK]
            if iszero(eq(sload(9), _shock)) {
                sstore(9, _shock)
                if _shock {
                    mstore(0, 0x20)
                    mstore(0x20, 14)
                    mstore(0x40, "Shock Detected")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }
    
    function methodUpdateTemperature(int256 _temp) external {
        assembly {
            let current := sload(0)
            if iszero(eq(current, _temp)) {
                sstore(0, _temp)
                
                // Premissa: Temp > -50 (sgt = Signed Greater Than)
                if sgt(_temp, sub(0, 50)) {
                    // Condição: Temp > -50 && DoorOpen (Slot 1)
                    if eq(sload(1), 1) {
                        mstore(0, 0x20) // Offset da string
                        mstore(0x20, 19) // Tamanho da string
                        mstore(0x40, "Critical: Temp/Door") 
                        log1(0, 0x60, EVENT_SIG)
                    }
                }
            }
        }
    }

    function methodUpdateDoor(bool _door) external {
        assembly {
            if iszero(eq(sload(1), _door)) {
                sstore(1, _door)
                if _door {
                    // Reavalia regra de temperatura se porta abrir
                    if sgt(sload(0), sub(0, 50)) {
                        mstore(0, 0x20) // Offset da string
                        mstore(0x20, 19) // Tamanho da string
                        mstore(0x40, "Critical: Temp/Door")
                        log1(0, 0x60, EVENT_SIG)
                    }
                }
            }
        }
    }

    function methodUpdateRoute(bool _route) external {
        assembly {
            if iszero(eq(sload(2), _route)) {
                sstore(2, _route)
                if _route {
                    mstore(0, 0x20)
                    mstore(0x20, 15)
                    mstore(0x40, "Route Activated")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }

    function methodUpdateHumidity(uint256 _hum) external {
        assembly {
            if iszero(eq(sload(3), _hum)) {
                sstore(3, _hum)
                if gt(_hum, 80) {
                    mstore(0, 0x20)
                    mstore(0x20, 18)
                    mstore(0x40, "Warning: High Humid")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }

    function methodUpdatePressure(uint256 _pres) external {
        assembly {
            if iszero(eq(sload(4), _pres)) {
                sstore(4, _pres)
                if lt(_pres, 950) {
                    mstore(0, 0x20)
                    mstore(0x20, 19)
                    mstore(0x40, "Warning: Low Pressure")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }

    function methodUpdateLight(uint256 _light) external {
        assembly {
            if iszero(eq(sload(5), _light)) {
                sstore(5, _light)
                if gt(_light, 1000) {
                    mstore(0, 0x20)
                    mstore(0x20, 18)
                    mstore(0x40, "Warning: High Light")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }

    function methodUpdateVibration(uint256 _vib) external {
        assembly {
            if iszero(eq(sload(6), _vib)) {
                sstore(6, _vib)
                if gt(_vib, 5) {
                    mstore(0, 0x20)
                    mstore(0x20, 22)
                    mstore(0x40, "Warning: High Vibration")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }

    function methodUpdateCO2(uint256 _co2) external {
        assembly {
            if iszero(eq(sload(7), _co2)) {
                sstore(7, _co2)
                if gt(_co2, 2000) {
                    mstore(0, 0x20)
                    mstore(0x20, 17)
                    mstore(0x40, "Warning: High CO2")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }

    function methodUpdateBattery(uint256 _bat) external {
        assembly {
            if iszero(eq(sload(8), _bat)) {
                sstore(8, _bat)
                if lt(_bat, 20) {
                    mstore(0, 0x20)
                    mstore(0x20, 19)
                    mstore(0x40, "Warning: Low Battery")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }

    function methodUpdateShock(bool _shock) external {
        assembly {
            if iszero(eq(sload(9), _shock)) {
                sstore(9, _shock)
                if _shock {
                    mstore(0, 0x20)
                    mstore(0x20, 13)
                    mstore(0x40, "Shock Detected")
                    log1(0, 0x60, EVENT_SIG)
                }
            }
        }
    }
}