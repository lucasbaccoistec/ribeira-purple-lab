# O cenário: a Ribeira

A **Ribeira Soluções Digitais, Lda.** é uma empresa fictícia do Porto, com cerca de 35 pessoas, que faz software de faturação para pequenos comércios. O nome, as pessoas e os dados são inventados; qualquer semelhança com a realidade é coincidência.

## Como está organizada

| Departamento | Para quê | Grupo no domínio |
| --- | --- | --- |
| Administracao | Direção e secretariado | `GRP-Administracao` |
| Financeiro | Contabilidade e pagamentos | `GRP-Financeiro` |
| RecursosHumanos | Pessoal e recrutamento | `GRP-RecursosHumanos` |
| Comercial | Vendas e apoio a clientes | `GRP-Comercial` |
| TI | Tecnologia da própria empresa | `GRP-TI` |

Tem um único domínio (`ribeira.test`), um controlador de domínio (DC01) e postos de trabalho Windows 11 (no laboratório, o WS01). Cresceu depressa e a tecnologia foi sendo acrescentada sem grande revisão de segurança: é o ponto de partida realista de muitas pequenas empresas.

## O ponto de partida do atacante

O teste é do tipo **assumed breach** (presume-se que já houve uma entrada): um funcionário abriu um anexo falso e o atacante tem a sessão dele no WS01, como **utilizador normal, sem privilégios de administrador**. Como entrou não interessa; interessa o que consegue fazer a partir daí.

## O que o atacante quer

1. Perceber como o domínio está organizado (quem é quem, que máquinas existem).
2. Subir de privilégios até controlar o domínio inteiro.
3. Mostrar o impacto, sem destruir nada.

## Regras do jogo

- **Dentro de âmbito:** apenas as três máquinas do laboratório e a rede `192.168.64.0/24`.
- **Fora de âmbito:** o Mac anfitrião, a rede de casa ou da escola, a internet e qualquer sistema que não seja teu. Em Portugal, aceder a sistemas alheios sem autorização é crime (Lei do Cibercrime, Lei n.º 109/2009, artigo 6.º).
- **Ferramentas:** só programas públicos e conhecidos, sem custo. Nada de malware real nem de código que não percebas.
- **Registo:** cada passo fica documentado em `attack/` (data e hora, o que fizeste, evidência).
- **Antes de cada passo:** cópia limpa das máquinas (ver [`architecture.md`](architecture.md)).

## As quatro fases do projeto

| Fase | Pergunta a que responde | Pasta |
| --- | --- | --- |
| Atacar | O que consegue fazer um atacante que já está dentro? | `attack/` |
| Detetar | Como é que a equipa de defesa se aperceberia? | `detections/` |
| Corrigir | O que muda para o ataque deixar de funcionar? | `hardening/` |
| Provar | O ataque falha mesmo depois da correção? | `hardening/` e `report/` |
