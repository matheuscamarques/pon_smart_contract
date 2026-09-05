// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title PONHyperFusedLogistics (PHF)
 * @author Matheus de Camargo Marques
 * @notice Implementação Final para Artigo: PON + Bit-Packing + Yul + EIP-1153.
 */
contract PONHyperFusedLogistics {
    // Slot 0: Estado Persistente (Bit-Packed)
    // Layout: [Reserva: 173][Shock:1][Bat:8][CO2:16][Vib:8][Light:16][Pres:16][Hum:8][Route:1][Door:1][Temp:8]
    uint256 private packedFacts;

    // Slot Transiente (EIP-1153): Dirty-Mask para rastrear deltas por transação
    // Slot literal para EIP-1153 (keccak256("pon.hyperfused.dirty_mask"))
    bytes32 private constant DIRTY_MASK_SLOT = 0xb94d4bb16ee2057a0f1dbc2eb186c5e6831f88891da96b5b733f1c9363346d51;

    event InstigationTriggered(string message);

    /**
     * @notice Atualização em Lote com Inferência por Máscara de Bits
     */
    function updateLogistics(
        int8 _temp, bool _door, bool _route, uint8 _hum, 
        uint16 _pres, uint16 _light, uint8 _vib, uint16 _co2, 
        uint8 _bat, bool _shock
    ) external {
        assembly {
            // 1. CARREGAR ESTADO ATUAL
            let currentPacked := sload(0)
            let newPacked := currentPacked
            let dirtyMask := 0 

            // --- SEÇÃO DE DETECÇÃO DE DELTA (10 SENSORES) ---
            
            // [TEMP: bits 0-7] - Mask Bit 0 (0x01)
            let oldTemp := and(currentPacked, 0xFF)
            if iszero(eq(and(_temp, 0xFF), oldTemp)) {
                newPacked := or(and(newPacked, not(0xFF)), and(_temp, 0xFF))
                dirtyMask := or(dirtyMask, 0x01) 
            }

            // [DOOR: bit 8] - Mask Bit 1 (0x02)
            let newDoor := iszero(iszero(_door))
            if iszero(eq(newDoor, and(shr(8, currentPacked), 0x01))) {
                newPacked := or(and(newPacked, not(shl(8, 0x01))), shl(8, newDoor))
                dirtyMask := or(dirtyMask, 0x02)
            }

            // [ROUTE: bit 9] - Mask Bit 2 (0x04)
            let newRoute := iszero(iszero(_route))
            if iszero(eq(newRoute, and(shr(9, currentPacked), 0x01))) {
                newPacked := or(and(newPacked, not(shl(9, 0x01))), shl(9, newRoute))
                dirtyMask := or(dirtyMask, 0x04)
            }

            // [HUMIDITY: bits 10-17] - Mask Bit 3 (0x08)
            if iszero(eq(and(_hum, 0xFF), and(shr(10, currentPacked), 0xFF))) {
                newPacked := or(and(newPacked, not(shl(10, 0xFF))), shl(10, and(_hum, 0xFF)))
                dirtyMask := or(dirtyMask, 0x08)
            }

            // [PRESSURE: bits 18-33] - Mask Bit 4 (0x10)
            if iszero(eq(and(_pres, 0xFFFF), and(shr(18, currentPacked), 0xFFFF))) {
                newPacked := or(and(newPacked, not(shl(18, 0xFFFF))), shl(18, and(_pres, 0xFFFF)))
                dirtyMask := or(dirtyMask, 0x10)
            }

            // [LIGHT: bits 34-49] - Mask Bit 5 (0x20)
            if iszero(eq(and(_light, 0xFFFF), and(shr(34, currentPacked), 0xFFFF))) {
                newPacked := or(and(newPacked, not(shl(34, 0xFFFF))), shl(34, and(_light, 0xFFFF)))
                dirtyMask := or(dirtyMask, 0x20)
            }

            // [VIBRATION: bits 50-57] - Mask Bit 6 (0x40)
            if iszero(eq(and(_vib, 0xFF), and(shr(50, currentPacked), 0xFF))) {
                newPacked := or(and(newPacked, not(shl(50, 0xFF))), shl(50, and(_vib, 0xFF)))
                dirtyMask := or(dirtyMask, 0x40)
            }

            // [CO2: bits 58-73] - Mask Bit 7 (0x80)
            if iszero(eq(and(_co2, 0xFFFF), and(shr(58, currentPacked), 0xFFFF))) {
                newPacked := or(and(newPacked, not(shl(58, 0xFFFF))), shl(58, and(_co2, 0xFFFF)))
                dirtyMask := or(dirtyMask, 0x80)
            }

            // [BATTERY: bits 74-81] - Mask Bit 8 (0x100)
            if iszero(eq(and(_bat, 0xFF), and(shr(74, currentPacked), 0xFF))) {
                newPacked := or(and(newPacked, not(shl(74, 0xFF))), shl(74, and(_bat, 0xFF)))
                dirtyMask := or(dirtyMask, 0x100)
            }

            // [SHOCK: bit 82] - Mask Bit 9 (0x200)
            let newShock := iszero(iszero(_shock))
            if iszero(eq(newShock, and(shr(82, currentPacked), 0x01))) {
                newPacked := or(and(newPacked, not(shl(82, 0x01))), shl(82, newShock))
                dirtyMask := or(dirtyMask, 0x200)
            }

            // 2. PERSISTÊNCIA E GATING DE REGRAS
            if iszero(eq(dirtyMask, 0)) {
                sstore(0, newPacked)
                // Atribuir a constante a uma variável local Yul para garantir compatibilidade
                let slot := 0xb94d4bb16ee2057a0f1dbc2eb186c5e6831f88891da96b5b733f1c9363346d51
                tstore(slot, dirtyMask)

                // ==========================================
                // 3. MOTOR DE INFERÊNCIA PHF (10 REGRAS)
                // ==========================================
                
                // R1: Temp Critical (> -50) AND Door Open (Gate: bits 0 ou 1)
                if and(dirtyMask, 0x03) {
                    let tempVal := signextend(0, and(newPacked, 0xFF))
                    if and(sgt(tempVal, sub(0, 50)), and(shr(8, newPacked), 0x01)) {
                        _emitEvent("Critical: Temp/Door Violation", 27)
                    }
                }

                // R2: Humidity High (> 80) (Gate: bit 3)
                if and(dirtyMask, 0x08) {
                    if gt(and(shr(10, newPacked), 0xFF), 80) {
                        _emitEvent("Warning: Humidity High", 21)
                    }
                }

                // R3: Pressure Low (< 950) (Gate: bit 4)
                if and(dirtyMask, 0x10) {
                    if lt(and(shr(18, newPacked), 0xFFFF), 950) {
                        _emitEvent("Warning: Pressure Low", 20)
                    }
                }

                // R4: Light High (> 1000) (Gate: bit 5)
                if and(dirtyMask, 0x20) {
                    if gt(and(shr(34, newPacked), 0xFFFF), 1000) {
                        _emitEvent("Warning: Light High", 18)
                    }
                }

                // R5: Vibration Detected (> 5) (Gate: bit 6)
                if and(dirtyMask, 0x40) {
                    if gt(and(shr(50, newPacked), 0xFF), 5) {
                        _emitEvent("Warning: Vibration Detected", 26)
                    }
                }

                // R6: CO2 High (> 2000) (Gate: bit 7)
                if and(dirtyMask, 0x80) {
                    if gt(and(shr(58, newPacked), 0xFFFF), 2000) {
                        _emitEvent("Warning: CO2 High", 16)
                    }
                }

                // R7: Battery Low (< 20) (Gate: bit 8)
                if and(dirtyMask, 0x100) {
                    if lt(and(shr(74, newPacked), 0xFF), 20) {
                        _emitEvent("Warning: Battery Low", 19)
                    }
                }

                // R8: Shock Detected (Gate: bit 9)
                if and(dirtyMask, 0x200) {
                    if and(shr(82, newPacked), 0x01) {
                        _emitEvent("Alert: Shock Detected", 20)
                    }
                }

                // R9: Route Deviated (Gate: bit 2)
                if and(dirtyMask, 0x04) {
                    if and(shr(9, newPacked), 0x01) {
                        _emitEvent("Warning: Route Deviated", 22)
                    }
                }

                // R10: Temp High (> -40) (Gate: bit 0)
                if and(dirtyMask, 0x01) {
                    let tempVal := signextend(0, and(newPacked, 0xFF))
                    if sgt(tempVal, sub(0, 40)) {
                        _emitEvent("Warning: Temp High", 17)
                    }
                }
                // Clear the transient storage slot to avoid composability issues
                tstore(slot, 0)
            }

            function _emitEvent(msgStr, msgLen) {
                let signature := 0x8b8e0d165681992036c05d5d8d4c2d3d4e5f6a7b8c9d0e1f2a3b4c5d6e7f8a9b
                mstore(0x00, 0x20)
                mstore(0x20, msgLen)
                mstore(0x40, msgStr)
                log1(0x00, 0x60, signature)
            }
        }
    }
}