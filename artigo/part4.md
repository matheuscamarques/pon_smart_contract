# 4. Metodologia Experimental (O seu Setup de Testes)

## Ambiente
- **Framework:** Hardhat
- **EVM via IR:** Ativado (`viaIR: true`)
- **Solidity:** 0.8.24
- **EVM Version:** Cancun (suporte ao EIP-1153)
- **Otimizador:** Ativado (1000 runs)
- **Gas Reporter:** Ativado (CSV)
- **Rede de Teste:** Hardhat, hardfork Cancun

## O Arsenal de Contratos
Foram desenvolvidos 9 modelos para representar a evolução arquitetural dos contratos logísticos:

1. **TraditionalLogistics** — Monolítico tradicional, referência didática.
2. **PONLogistics** — Paradigma PON reativo, fatos individuais.
3. **ParadigmaticPONLogistics** — PON com motor sequencial e atributos individuais.
4. **PONBitPackedLogistics** — Estado global bit-packed em um único slot.
5. **ShortCircuitPONLogistics** — Avaliação preguiçosa e short-circuit.
6. **TransientPONLogistics** — Armazenamento transiente (EIP-1153).
7. **MerklePONLogistics** — Compressão via Merkle Proofs.
8. **PONHyperFusedLogistics** — Bit-packing, Yul e EIP-1153 integrados.
9. **YulPONLogistics** — Assembly puro (Yul), limite teórico de otimização.

## Os Cenários
- **Eficiência de Rede (Atômico):** Mede o custo de gas para operações unitárias (uma atualização por transação).
- **Eficiência Arquitetural (Batching):** Mede o custo de gas para operações em lote (várias atualizações em uma única transação).
- **Consistência:** Testes garantem que todas as regras e notificações funcionam corretamente em todos os modelos.
