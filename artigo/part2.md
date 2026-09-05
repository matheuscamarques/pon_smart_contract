# 2. Fundamentação Teórica e Trabalhos Correlatos

## O Paradigma PON: Fatos, Atributos, Premissas e Regras
O Paradigma Orientado a Notificações (PON) foi desenvolvido para superar as limitações dos modelos imperativos e declarativos tradicionais, especialmente em sistemas reativos e distribuídos. Sua base teórica, consolidada em ambiente de doutorado, estrutura-se em quatro entidades fundamentais:

- **Fatos**: Representam o estado atual de uma informação relevante do sistema (ex: temperatura, status da porta).
- **Atributos**: São as propriedades observáveis dos fatos, encapsulando valores e notificando mudanças.
- **Premissas**: Avaliam condições lógicas sobre fatos e atributos, funcionando como relés de inferência.
- **Regras**: Definem ações a serem tomadas quando premissas específicas são satisfeitas, promovendo a reatividade do sistema.

No contexto da logística IoT, o PON permite que sensores e atuadores interajam de forma desacoplada e eficiente, eliminando redundâncias e otimizando o processamento de eventos críticos.

## Anatomia do Custo na EVM: Por que $SLOAD$ é barato e $SSTORE$ é caro
A Ethereum Virtual Machine (EVM) diferencia fortemente o custo entre operações de leitura ($SLOAD$) e escrita ($SSTORE$) no armazenamento persistente:

- **$SLOAD$ (Leitura)**: É relativamente barato porque apenas recupera dados já armazenados, sem alterar o estado global. O acesso pode ser ainda mais eficiente se o slot já estiver "quente" (acessado na mesma transação).
- **$SSTORE$ (Escrita)**: É absurdamente caro porque modifica o estado global da blockchain, exigindo que todos os nós validadores atualizem suas cópias do banco de dados (Merkle Patricia Trie). Além disso, gravações permanentes impactam o tamanho do estado da rede, justificando o alto custo para evitar abusos e inchaço do sistema.

Essa assimetria de custos é um dos principais gargalos para aplicações IoT de alta frequência na EVM, pois cada escrita representa um gasto significativo de gas.

## EIP-1153 (Cancun Upgrade): Transient Storage (TSTORE/TLOAD)
A EIP-1153 introduziu os opcodes `TSTORE` e `TLOAD`, criando o conceito de Transient Storage:

- **Transient Storage**: Permite armazenar dados temporários durante a execução de uma transação, com acesso e sintaxe semelhantes ao storage tradicional, mas sem persistência após o término da transação.
- **TSTORE/TLOAD**: São opcodes que escrevem e leem slots de memória transiente. O custo dessas operações é muito menor (100 gas), pois não envolvem gravação em disco nem atualização do estado global.
- **Limpeza automática**: Ao final da transação, toda a memória transiente é automaticamente descartada, garantindo que não haja resíduos ou necessidade de limpeza manual.

Essa inovação é fundamental para contratos inteligentes que precisam compartilhar dados entre chamadas internas ou implementar mecanismos como locks/reentrancy guards, sem incorrer nos custos proibitivos do $SSTORE$.
