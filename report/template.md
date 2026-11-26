---
title: "Relatório de teste de intrusão: Ribeira Soluções Digitais, Lda."
subtitle: "Teste interno ao Active Directory (assumed breach)"
author: "O Teu Nome"
date: "Dezembro de 2026"
lang: pt-PT
---

# Resumo executivo

*Uma página, para quem decide e não é técnico. Responde a quatro perguntas: o que foi testado, o que se encontrou de mais grave, qual é o risco para o negócio e o que fazer primeiro.*

**Âmbito:** teste interno do domínio `ribeira.test` (três máquinas de laboratório), a partir de um utilizador sem privilégios.

**Conclusão:** *(uma frase, por exemplo: "Um atacante com a conta de um funcionário consegue controlar o domínio inteiro em X passos.")*

| Gravidade | Achados |
| --- | --- |
| Crítica | 0 |
| Alta | 0 |
| Média | 0 |
| Baixa | 0 |
| Informativa | 0 |

**As três ações mais importantes:**

1. *(a correção que mais reduz o risco)*
2. *(...)*
3. *(...)*

# Âmbito e metodologia

| | |
| --- | --- |
| Cliente | Ribeira Soluções Digitais, Lda. (fictícia) |
| Tipo de teste | Interno, *assumed breach*, caixa cinzenta |
| Sistemas em âmbito | DC01, WS01 e a rede 192.168.64.0/24 |
| Fora de âmbito | O computador anfitrião, redes externas e a internet |
| Período | *(datas)* |
| Testador | *(nome)* |

A metodologia segue as fases do MITRE ATT&CK (referências nos achados). As ferramentas usadas estão no apêndice A.

## Classificação de gravidade

A gravidade usa o CVSS (indica sempre a versão e o vetor em cada achado). As faixas são as do padrão:

| Gravidade | Pontuação CVSS |
| --- | --- |
| Crítica | 9.0 a 10.0 |
| Alta | 7.0 a 8.9 |
| Média | 4.0 a 6.9 |
| Baixa | 0.1 a 3.9 |
| Informativa | 0.0 |

# Resumo dos achados

| ID | Achado | Gravidade | CVSS | Estado |
| --- | --- | --- | --- | --- |
| F-01 | *(título curto)* | *(Alta)* | *(8.1)* | *(Corrigido e provado)* |

# Cadeia de ataque

*Narrativa curta, do ponto de partida ao controlo do domínio, com um diagrama se ajudar. Cada passo remete para o achado respetivo.*

# Achados detalhados

## F-01 · Título do achado

| | |
| --- | --- |
| **Gravidade** | *(Alta)* |
| **CVSS** | *(versão, vetor e pontuação)* |
| **Técnica ATT&CK** | *(T0000, nome)* |
| **Sistemas afetados** | *(DC01)* |

**Descrição.** *O que está mal, em linguagem clara.*

**Impacto.** *O que um atacante consegue por causa disto, em termos de negócio.*

**Como reproduzir.** *Passos numerados, com os comandos e a saída relevante, para que outra pessoa os repita.*

**Evidência.** *Capturas ou excertos de saída (sem palavras-passe reais).*

**Como se deteta.** *Eventos que o defensor vê e regra Sigma correspondente.*

**Recomendação.** *A correção concreta, por ordem de prioridade.*

**Re-teste.** *Resultado do mesmo passo depois da correção.*

**Referências.** *Ligações para a técnica ATT&CK e para a documentação do fabricante.*

# Conclusão e próximos passos

*O que fica resolvido, o que fica por resolver e o que se recomenda a seguir.*

# Apêndice A: ferramentas

| Ferramenta | Versão | Para quê |
| --- | --- | --- |
| *(nome)* | *(versão)* | *(uso)* |

# Apêndice B: cronologia

| Data e hora (UTC) | Evento |
| --- | --- |
| *(…)* | *(…)* |
