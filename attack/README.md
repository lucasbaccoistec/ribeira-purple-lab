# Cadeia de ataque

Aqui documentas, passo a passo, o caminho do atacante: do utilizador normal no WS01 até ao controlo do domínio. Cada passo é **um ficheiro** feito a partir de [`_template.md`](_template.md), com a técnica MITRE ATT&CK, o que fizeste, a evidência e o que o defensor vê.

> **Só no laboratório.** Em Portugal, aceder a sistemas informáticos sem autorização é crime (Lei do Cibercrime, Lei n.º 109/2009, artigo 6.º). Mantém-te dentro do âmbito definido em [`../docs/scenario.md`](../docs/scenario.md).

## Como trabalhar cada passo

1. Escolhe uma fraqueza do [registo](../docs/vulnerability-register.md) e faz uma cópia limpa das máquinas.
2. Faz o passo e escreve o ficheiro `AT-NN-nome.md` **enquanto o fazes**: o que tentaste, o que falhou, o que funcionou.
3. Guarda a evidência em `attack/evidence/AT-NN/` (o Git ignora as pastas vazias; põe lá pelo menos um `.gitkeep` se ficar vazia).
4. Anota o que o defensor viu (eventos) e passa para a deteção em [`../detections/`](../detections/README.md).

## A cadeia

| Passo | Técnica ATT&CK | Origem → destino | Deteção | Correção | Estado |
| --- | --- | --- | --- | --- | --- |
| *(por preencher)* | | | | | |

Estados: **Por fazer**, **Feito**, **Detetado**, **Corrigido**, **Provado**.

## Dicas

- O valor do projeto está nas **tuas explicações**: porque funciona, o que o defensor vê e como se corrige. Um comando sem explicação não diz nada a quem lê.
- Uma tentativa que falhou, bem explicada, vale tanto como uma que funcionou.
- Nunca ponhas palavras-passe, chaves ou ficheiros de terceiros no repositório.
