# 1. Introdução

A ascensão da Internet das Coisas (IoT) na logística tem promovido avanços no monitoramento de ativos críticos, como contêineres e cadeias de frio, exigindo níveis elevados de confiabilidade, rastreabilidade e imutabilidade dos dados. Nesse contexto, a tecnologia Blockchain apresenta-se como uma solução para garantir a integridade e a auditabilidade das informações, atributos essenciais para operações logísticas modernas e reguladas.

Apesar desse potencial, existe um desafio central: a infraestrutura da Máquina Virtual Ethereum (EVM) impõe custos elevados para operações de escrita persistente ($SSTORE$), enquanto a rede blockchain adiciona um pedágio intrínseco a cada transação. Soluções atuais enfrentam um dilema: ou consomem recursos excessivos da rede para garantir integridade, ou sobrecarregam o processamento interno para reduzir custos, comprometendo escalabilidade e eficiência.

Este trabalho parte da hipótese de que é possível superar esse impasse por meio de uma arquitetura que combine: (i) compressão de estado $O(1)$ via Bit-Packing, (ii) reatividade baseada em delta com o Paradigma Orientado a Notificações (PON), e (iii) prevenção de dupla execução utilizando armazenamento transiente (EIP-1153).

As principais contribuições deste trabalho são:

- Proposição do framework Paradigmático Híbrido Fusão (PHF) para contratos inteligentes logísticos.
- Desenvolvimento e análise de uma taxonomia com nove modelos arquiteturais para logística IoT na EVM, cobrindo do tradicional ao limite teórico.
- Avaliação experimental comparativa dos modelos, destacando ganhos de eficiência e trade-offs arquiteturais.

