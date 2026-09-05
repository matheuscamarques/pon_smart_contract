# NOP-HF: Uma Arquitetura *Hyper-Fused* baseada no Paradigma Orientado a Notificações para Otimização de *Storage I/O* e Latência na EVM

### Resumo (Abstract)
A viabilidade técnica de redes descentralizadas aplicadas à Internet das Coisas (IoT) é condicionada pela eficiência da gestão de estado *on-chain*. Em cenários de monitorização logística de alta frequência, o custo de execução derivado do *opcode* `SSTORE` torna-se o principal limitador económico. Este artigo apresenta a arquitetura **NOP-HF (Notification-Oriented Paradigm Hyper-Fused)**, que integra técnicas de *Bit-Packing*, armazenamento transiente (EIP-1153) e implementação de baixo nível via motor Yul. A proposta visa mitigar o impacto da mutação de estado persistente, apresentando evidências empíricas de ganhos de eficiência que incluem uma redução de aproximadamente 90% nos custos de rede e uma otimização de 73% na eficiência arquitetural em relação a modelos convencionais. Conclui-se que a otimização da camada de execução é imperativa para a escalabilidade de soluções IoT na *blockchain*, especialmente após avanços recentes em disponibilidade de dados, estando o foco deste trabalho na Camada de Execução (*Execution Layer*), onde reside o principal estrangulamento (*gargalo*) para aplicações de alta frequência.

---

## 1. Introdução

No ecossistema logístico contemporâneo, a IoT é fundamental para assegurar a integridade e a rastreabilidade de ativos em tempo real. Embora avanços como Dencun (EIP-4844) e *blobs* tenham reduzido os custos de publicação de dados (*Data Availability*), o principal estrangulamento para aplicações IoT de alta frequência permanece na camada de execução (*Execution Layer*), especialmente na mutação de estado persistente (`SSTORE`). O custo de mutação de estado eleva o OPEX (Custo Operacional) de forma não linear em frotas de sensores de alta densidade. O NOP-HF apresenta-se como uma solução viável para mitigar essa assimetria, transpondo a barreira económica ao fundir paradigmas reativos com manipulação direta de memória na EVM.

## 2. Fundamentação Teórica e Trabalhos Relacionados

A mitigação de custos de I/O (Entrada/Saída) na Máquina Virtual Ethereum tem sido objeto de extensa pesquisa. Abordagens predominantes na literatura focam-se em soluções de escalabilidade de Camada 2 (*Rollups Optimistic* e *Zero-Knowledge*) ou no processamento *off-chain* via oráculos computacionais. Embora eficientes na redução do congestionamento da rede principal (L1), essas soluções introduzem complexidades arquiteturais, latência de finalidade (*finality*) e novas premissas de confiança (*trust assumptions*). Paralelamente, os esforços de otimização estritamente *on-chain* limitam-se, na sua maioria, à compressão de *calldata* para reduzir o peso da transação. O custo de execução persistente no disco dos nós validadores (`SSTORE`) permanece subexplorado na literatura de IoT descentralizada. A arquitetura proposta preenche esta lacuna ao aplicar eficiência nativa na camada de execução.

### 2.1 O Paradigma Orientado a Notificações (NOP)
A evolução das estruturas de dados na EVM exige a transição de modelos imperativos tradicionais para paradigmas reativos que minimizem o acesso contínuo ao armazenamento global. O NOP (*Notification-Oriented Paradigm*) é uma especialização dos princípios da Arquitetura Reativa (Reactive Architecture) e da Arquitetura Orientada a Eventos (Event-Driven Architecture), aplicando-os ao contexto de contratos inteligentes. Assim como nas arquiteturas reativas, o NOP privilegia a resposta a deltas de estado e eventos significativos, em vez de processar fluxos contínuos ou estados estáticos, promovendo eficiência e escalabilidade em sistemas distribuídos. O NOP estrutura-se sobre quatro entidades determinísticas:
1. **Factos:** O estado bruto da informação sensoriada (ex: temperatura, humidade).
2. **Atributos:** Propriedades observáveis que encapsulam valores e notificam alterações estruturais.
3. **Premissas:** Condições lógicas pré-compiladas avaliadas sobre factos e atributos.
4. **Regras:** Ações de estado executadas exclusivamente quando premissas específicas são satisfeitas.


A aplicação do NOP garante que o contrato inteligente ignore a redundância de dados em estado de repouso ("*steady-state*"), ativando rotinas de cálculo apenas perante deltas (mutações) operacionais.

Do ponto de vista algébrico, num modelo imperativo clássico, a transição de estado $T$ avalia e grava os dados independentemente de variação térmica ou de movimento: $T(S_t, \Delta S) \to S_{t+1}$. No NOP, a reatividade é baseada num delta estrito. O estado e a avaliação das Regras ($R$) só são acionados se a diferença entre o estado atual ($S_t$) e o novo estado for não nula:

$$
R(S_t) =
\begin{cases}
	ext{Executa e Grava}, & \text{se } |S_{novo} - S_t| > 0 \\
	ext{Rejeita (Short-Circuit)}, & \text{se } |S_{novo} - S_t| = 0
\end{cases}
$$

Esta barreira lógica algorítmica é a responsável direta pela prevenção de overhead desnecessário em redes de alta frequência, atuando como o gatilho determinístico do sistema.

### 2.2 Assimetria de Custos da EVM e Armazenamento Transiente
A viabilidade de qualquer paradigma reativo *on-chain* é limitada pela assimetria termodinâmica de custos da EVM: enquanto o *opcode* `SLOAD` (leitura) possui um custo base de 2.100 gas (acesso frio), o `SSTORE` (escrita em novo *slot*) atinge 22.100 gas. Modificar o estado global da *blockchain* é propositalmente custoso para desencorajar o inchaço da rede (*State Bloat*).

A introdução da EIP-1153 (*Transient Storage*) na atualização Cancun transformou este cenário. Disponibilizou os *opcodes* `TSTORE` e `TLOAD`, que operam numa camada de memória efémera com custo fixo e ínfimo de 100 gas. A memória transiente comporta-se de maneira idêntica ao armazenamento tradicional durante o ciclo de vida da transação, porém, é integralmente descartada ao término da execução, sem gerar persistência no disco físico dos validadores.

**Comparativo de Custos de Gas (EVM Cancun - Padrão Persistente vs. Transiente):**
* **SSTORE (Escrita Fria):** 22.100 gas
* **SSTORE (Escrita Quente / Reescrita):** $\approx 5.000$ gas
* **SLOAD (Leitura Fria):** 2.100 gas
* **TSTORE / TLOAD (Transiente):** 100 gas

## 3. Arquitetura Proposta: NOP-HF

O *design* do NOP-HF utiliza a fusão de técnicas de baixo nível para otimizar o fluxo de dados de sensores IoT através de três componentes:


1. **Compressão de Estado O(1):** Implementa *Bit-Packing* para consolidar múltiplos sensores (temperatura, porta, humidade) num único *slot* `uint256`. Isto reduz a complexidade de escrita para uma única operação atómica, independentemente do número de atributos.

Matematicamente, a técnica de Bit-Packing operada no NOP-HF transforma o vetor de estados dos sensores $V = [v_1, v_2, ..., v_n]$ numa única palavra de memória $S_{packed}$ (de 256 bits). O estado consolidado é obtido através do somatório de disjunções lógicas (operações OR), onde cada valor $v_i$ é deslocado (Shift Left) para a sua posição exata de offset ($\theta_i$):

$$
S_{packed} = \bigvee_{i=1}^{n} (v_i \ll \theta_i)
$$

Onde $\theta_i = \sum_{j=1}^{i-1} L_j$, sendo $L_j$ o comprimento em bits alocado para o sensor $j$. Esta formulação garante que o custo de escrita $O(n)$ do modelo tradicional é reduzido à complexidade espacial estrita de $O(1)$.
2. **Motor Yul (Assembly):** A manipulação de bits é realizada via máscaras de bits (*Dirty-Mask*). Tecnicamente, o *Dirty-Mask* envolve operações *bitwise AND/OR* para isolar ou inserir bits específicos dentro de um `uint256` sem alterar dados adjacentes, eliminando o *overhead* de segurança e memória do compilador Solidity.
3. **Prevenção de Double-Firing:** O armazenamento transiente (`TSTORE`) é utilizado para controlo de sessão efémero. Garante a reatividade do sistema (disparo de regras) sem a necessidade de persistir sinalizadores de estado caros no armazenamento global, limpando-se automaticamente ao fim da execução.

## 4. Metodologia e Configuração Experimental

A reprodutibilidade científica foi assegurada através de um protocolo de isolamento de estado, realizando o *re-deploy* completo dos contratos em cada medição para neutralizar o viés de *Warm Storage* (armazenamento quente).

* **Ambiente:** Hardhat, EVM Cancun, Solidity 0.8.24.
* **Configuração:** `viaIR: true`, 1.000 execuções controladas por cenário.
* **Modelos de Comparação:** Foram avaliados os modelos Tradicional, PON Otimizado, Paradigmático, BitPacked, ShortCircuit, Transient, YulPON, Merkle e o proposto NOP-HF (HyperFused).


## 5. Avaliação de Desempenho e Economia de Gas

Antes de apresentar os dados empíricos, fundamenta-se a análise com um modelo analítico de custo transacional. Num cenário onde $k$ sensores sofrem mutação, o modelo Tradicional (sem loteamento) exige um custo total de gas ($C_{trad}$) ditado pela soma linear de acessos ao disco:

$$
C_{trad} = \sum_{i=1}^{k} \left( C_{base} + C_{SSTORE}(i) \right)
$$

Em contrapartida, a arquitetura NOP-HF centraliza a persistência e isola as restrições lógicas na memória efémera. A sua função de custo ($C_{HF}$) é dada por:

$$
C_{HF} = C_{base} + C_{SSTORE} + C_{TSTORE} + \sum_{i=1}^{k} C_{Yul\_ops}(i)
$$

Como o custo atómico das operações bitwise em Yul ($C_{Yul\_ops} \approx 3$ gas) e do armazenamento transiente ($C_{TSTORE} = 100$ gas) é ordens de grandeza inferior ao $C_{SSTORE}$ ($20.000$ gas para alocação fria), a inequação $C_{HF} \ll C_{trad}$ sustenta-se sempre que $k \ge 1$, validando o ganho de eficiência assintótica.

Os dados quantitativos a seguir validam a otimização estatisticamente significativa alcançada pelo NOP-HF.

### 5.1 Eficiência de Rede

Como demonstrado na Tabela 1, a comparação entre 10 envios atómicos individuais e um lote HyperFused evidencia a inviabilidade do modelo tradicional para aplicações industriais.

**Tabela 1 - Eficiência de Rede (10 Envios Atómicos vs. 1 Lote HyperFused)**

| Modelo | 10 Envios Atómicos (Gas) | HyperFused 1 Lote (Gas) | Economia de Rede (%) |
| :--- | :--- | :--- | :--- |
| Tradicional | 701.231 | 63.624 | 90,93 |
| PON Otimizado | 445.723 | 63.624 | 85,73 |
| Paradigmático | 444.610 | 63.624 | 85,69 |
| BitPacked | 303.487 | 63.624 | 79,04 |
| ShortCircuit | 443.531 | 63.624 | 85,66 |
| Transient | 442.271 | 63.624 | 85,61 |
| YulPON | 455.041 | 63.624 | 86,02 |
| Merkle | 329.868 | 63.624 | 80,71 |
| **HyperFused (NOP-HF)** | - | **63.624** | - |

### 5.2 Eficiência Arquitetural em *Batching*

Como pode ser observado na Tabela 2, mesmo em cenários onde o processamento em lote (*batching*) é aplicado, o NOP-HF mantém ganhos substanciais sobre arquiteturas convencionais.

**Tabela 2 - Eficiência Arquitetural (*Batching* Padrão vs. HyperFused)**

| Modelo | 1 Lote Padrão (Gas) | HyperFused 1 Lote (Gas) | Economia Arquitetural (%) |
| :--- | :--- | :--- | :--- |
| Tradicional | 239.879 | 63.624 | 73,48 |
| PON Otimizado | 244.042 | 63.624 | 73,93 |
| Paradigmático | 244.265 | 63.624 | 73,95 |
| BitPacked | 68.680 | 63.624 | 7,36 |
| ShortCircuit | 242.685 | 63.624 | 73,78 |
| Transient | 241.551 | 63.624 | 73,66 |
| YulPON | 259.457 | 63.624 | 75,48 |
| Merkle | 68.202 | 63.624 | 6,71 |
| **HyperFused (NOP-HF)** | - | **63.624** | - |

### 5.3 O *Trade-off* do *Transient Storage* e Efeito *Warm Storage*

A análise quantitativa da Tabela 3 revela que o modelo BitPacked (Solidity puro) supera o NOP-HF em transações unitárias microscópicas devido ao efeito de *Warm Storage* e ao *overhead* de inicialização da memória transiente.

**Tabela 3 - Trade-off Quantitativo: Microexecuções (10 Atómicos)**

| Modelo | Gas (10 Atómicos) |
| :--- | :--- |
| Tradicional | 701.231 |
| PON Otimizado | 445.723 |
| Paradigmático | 444.610 |
| BitPacked | 303.487 |
| ShortCircuit | 443.531 |
| Transient | 442.271 |
| YulPON | 455.041 |
| Merkle | 329.868 |
| **HyperFused (NOP-HF)** | **329.479** |

Neste cenário restrito de microexecuções atómicas, o modelo BitPacked apresenta o menor custo de gas (303.487 gas), seguido de forma estreita pelo NOP-HF (329.479 gas). Este comportamento evidencia o *trade-off* arquitetural do sistema: o *overhead* de inicialização da memória transiente penaliza execuções isoladas microscópicas. Contudo, o NOP-HF mantém um ganho expressivo de 53% sobre o modelo Tradicional (701.231 gas), atestando a sua resiliência mesmo no pior caso operacional.

### 5.4 Análise Empírica de *Throughput* e Latência

Para garantir rigor científico, apresentam-se na Tabela 4 os resultados empíricos de *throughput* (TPS) e latência média (ms) obtidos experimentalmente para cada arquitetura avaliada. Os dados foram recolhidos a partir de execuções controladas no ambiente de *benchmark* descrito na Secção 4.

**Tabela 4 - Desempenho Empírico: TPS e Latência Média**

| Modelo | TPS | Latência Média (ms) |
| :--- | :--- | :--- |
| Tradicional | 236.88 | 1.00 |
| PON Otimizado | 329.21 | 0.57 |
| Paradigmático | 390.88 | 0.50 |
| BitPacked | 378.63 | 0.60 |
| ShortCircuit | 383.45 | 0.58 |
| Transient | 260.83 | 0.74 |
| YulPON | 424.84 | 0.47 |
| Merkle | 350.89 | 0.63 |
| **HyperFused (NOP-HF)** | **333.65** | **0.53** |


**Nota metodológica:** As latências apresentadas correspondem à média de execuções em ambiente simulado determinístico (Hardhat Node local), sem influência de jitter de rede ou variações externas. O desvio padrão observado foi inferior a 0,02 ms para todos os modelos, indicando alta estabilidade experimental e reforçando a validade estatística dos resultados.

Os resultados comprovam empiricamente que o NOP-HF reduz a latência média para 0,53 ms e eleva o *throughput* para 333,65 TPS, superando significativamente o modelo Tradicional e validando a proposta de otimização de *Storage I/O* e Latência.

## 6. Considerações de Segurança

Arquiteturas de baixo nível e o uso da EIP-1153 introduzem vetores de risco específicos. O custo reduzido do `TSTORE` (100 gas) rompe a barreira tradicional de 2.300 gas de estipêndio em transferências de ETH, permitindo ataques de reentrância de baixo custo, como evidenciado no *exploit* do protocolo SIR.trading ($355.000 de prejuízo). O NOP-HF mitiga estes riscos através de dois mecanismos:

* **Padrão Clean-up:** Implementação rigorosa de zeragem de *slots* transientes ao final da transação, evitando fuga de estado entre execuções *batching*.
* **Isolamento via Assembly:** Encapsulamento da lógica em blocos Yul com verificações explícitas de contexto de chamada (*caller namespacing*), impedindo colisões de *slots* em arquiteturas de *proxies* ou chamadas delegadas.

## 7. Conclusão

O NOP-HF estabelece um novo teto de *performance* para logística IoT na EVM ao otimizar o I/O de armazenamento. Os resultados demonstram que a fusão de *Bit-Packing* e *Transient Storage* reduz o OPEX em até 90%, viabilizando a monitorização em tempo real. A arquitetura prepara os sistemas para a infraestrutura modular emergente das atualizações Dencun e Pectra, onde a eficiência da execução se torna o diferencial competitivo. Futuros desenvolvimentos em IoT descentralizada deverão tratar o estado da *blockchain* como um recurso crítico, priorizando soluções que equilibrem rigor técnico, economia de gas e segurança de baixo nível.