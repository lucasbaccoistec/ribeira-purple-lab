# AT-00 · Título curto do passo

> Modelo: copia este ficheiro para `AT-01-nome-do-passo.md` (um ficheiro por passo, pela ordem da cadeia) e preenche. Só no laboratório.

| | |
| --- | --- |
| **Vulnerabilidade ligada** | VULN-000 (ver `docs/vulnerability-register.md`) |
| **Técnica ATT&CK** | T0000, nome da técnica (https://attack.mitre.org/techniques/T0000/) |
| **Tática** | |
| **Máquina de origem → destino** | KALI → DC01 |
| **Data e hora (UTC)** | |
| **Cópia limpa usada** | `DC01-limpo` |

## Objetivo

O que querias conseguir com este passo, numa frase.

## Ponto de partida

Que acesso tinhas antes do passo (por exemplo, "utilizador normal no WS01") e o que já sabias.

## O que fizeste

Descreve o passo em palavras tuas e o raciocínio: porque escolheste este caminho, o que esperavas, o que aconteceu.

**Comandos usados** (copia o que correste, com a saída relevante):

```text

```

## Resultado

O que ganhaste (um segredo, um acesso, uma informação) e como confirmaste que funcionou.

## Evidência

Capturas de ecrã e saídas guardadas em `attack/evidence/AT-00/` (sem palavras-passe reais).

## O que o defensor vê

| Onde | Evento | O que mostra |
| --- | --- | --- |
| DC01, Security | ID do evento | |

## Deteção e correção

- **Regra Sigma:** `detections/sigma/nome_da_regra.yml` (estado: por fazer)
- **Correção:** `hardening/H-000-nome.md` (estado: por fazer)
- **Re-teste:** resultado do mesmo passo depois da correção
