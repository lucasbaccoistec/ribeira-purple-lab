# Correção e prova

Fechar o ciclo: para cada vulnerabilidade que atacaste e detetaste, corriges e **provas** que a correção funciona, repetindo o mesmo ataque. Uma correção sem re-teste é só uma opinião.

## Uma ficha por correção

Cria um ficheiro `H-NN-nome.md` por correção, a partir deste modelo:

```markdown
# H-01 · Título curto

| | |
| --- | --- |
| **Vulnerabilidade** | VULN-000 |
| **Passo de ataque** | attack/AT-01-nome.md |
| **Gravidade antes** | CVSS (versão e vetor) = 0.0 |
| **Gravidade depois** | CVSS (versão e vetor) = 0.0 |

## O que mudou
Descrição da correção e onde está no código (ficheiro do Ansible e variável, por exemplo
`ribeira_weak_vuln_000: false`).

## Re-teste
Repete o passo do ataque nas mesmas condições (cópia limpa, mesmo ponto de partida).
Antes: o que aconteceu. Depois: o que aconteceu. Evidência em `hardening/evidence/H-01/`.

## Deteção
A regra Sigma continua a disparar na tentativa que a correção bloqueou? (Convém que sim.)

## Risco que fica
O que a correção não resolve e o que se recomenda a seguir.
```

## Como se faz o "antes e depois"

1. Com a vulnerabilidade ativa (`ribeira_weak_<id>: true`), faz o ataque e guarda a evidência.
2. Muda a variável para `false` e corre `ansible-playbook site.yml --tags misconfigurations`.
3. Repete o ataque exatamente da mesma forma e guarda a evidência.
4. Compara. Se o ataque ainda funciona, a correção não chegou: volta ao passo 2.

## Tabela de correções

| Ficha | Vulnerabilidade | Gravidade antes → depois | Re-teste | Estado |
| --- | --- | --- | --- | --- |
| *(por preencher)* | | | | |
