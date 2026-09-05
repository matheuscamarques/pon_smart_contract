# 5. Resultados e Discussões

## Tabela 1 - Avaliação de Eficiência de Rede em Cenário Atômico

| Modelo           | 10 Atômicos | HyperFused 1 Lote | Economia de Rede (%) |
|------------------|-------------|-------------------|----------------------|
| Tradicional      | 701231      | 63624             | 90,93                |
| PON Otimizado    | 445723      | 63624             | 85,73                |
| Paradigmático    | 444610      | 63624             | 85,69                |
| BitPacked        | 303487      | 63624             | 79,04                |
| ShortCircuit     | 443531      | 63624             | 85,66                |
| Transient        | 442271      | 63624             | 85,61                |
| YulPON           | 455041      | 63624             | 86,02                |
| Merkle           | 329868      | 63624             | 80,71                |

**Observação:** O resultado de 90,93% indica que o envio de dados atômicos compromete a viabilidade do IoT na blockchain. O modelo HyperFused reduz substancialmente o custo de rede.

---

## Tabela 2 - Avaliação de Eficiência Arquitetural em Batching

| Modelo           | 1 Lote      | HyperFused 1 Lote | Economia Arquitetural (%) |
|------------------|-------------|-------------------|--------------------------|
| Tradicional      | 239879      | 63624             | 73,48                    |
| PON Otimizado    | 244042      | 63624             | 73,93                    |
| Paradigmático    | 244265      | 63624             | 73,95                    |
| BitPacked        | 68680       | 63624             | 7,36                     |
| ShortCircuit     | 242685      | 63624             | 73,78                    |
| Transient        | 241551      | 63624             | 73,66                    |
| YulPON           | 259457      | 63624             | 75,48                    |
| Merkle           | 68202       | 63624             | 6,71                     |

**Observação:** Mesmo com batching, o modelo Tradicional apresenta severa degradação de desempenho devido à ineficiência na alocação de slots. A otimização alcançada é de 73,48%.

---

## Tabela 3 - Análise de Trade-offs: BitPacked vs. PHF

**Discussão:**
No cenário de pior caso e lote purista, o BitPacked (Solidity puro) apresentou desempenho superior ao PHF (HyperFused). Isso ocorre devido a dois fatores:

- **Warm Storage:** Quando o slot de storage já está “quente” (acessado na mesma transação), o custo de leitura e escrita é reduzido, favorecendo o BitPacked em operações repetidas.
- **Peso Computacional da Memória Transiente:** Inicializar e limpar a memória transiente (EIP-1153) em transações hiper-isoladas adiciona overhead, tornando o PHF menos eficiente no pior caso.

**Transparência:**
O modelo HyperFused apresenta desempenho superior em cenários reais de batching e uso intensivo, mas o BitPacked pode ser mais eficiente em execuções minimalistas e isoladas, devido ao comportamento do storage “quente” e à ausência de overhead de inicialização transiente.
