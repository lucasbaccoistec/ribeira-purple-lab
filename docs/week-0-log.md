# Registo da semana 0

Preenche este ficheiro à medida que segues o guia da semana 0 (o guia fica fora do Git; este registo é a prova do teste de viabilidade). Os limites são os do portão de decisão.

## Passos

| Passo | Resultado | Notas |
| --- | --- | --- |
| 1. UTM instalado | Passou | Já estava instalado (QEMU 10.0). |
| 2. Windows Server no DC01 | Passou | Server 2022 Standard Evaluation, modo Core. Instalação em 20 min (23:01 a 23:21, 25/11/2026). Nome DC01 e IP fixo 192.168.64.10 feitos no SConfig. |
| 3. Active Directory no DC01 | Passou | Domínio `ribeira.test` criado em 10 min. NTDS, DNS, Netlogon e Kdc a correr, e o AD continuou a responder depois do reinício. DNS do DC em 127.0.0.1, reencaminhador 1.1.1.1. Cópia `DC01-limpo` feita (7,5 GB). |
| 4. Certificados (AD CS), bónus | Por fazer | |
| 5. WS01 no domínio | Por fazer | |
| 6. Kali | Por fazer | |
| 7. As três juntas, 30 minutos | Por fazer | |

Resultados possíveis: **Por fazer**, **Passou**, **Passou com problemas**, **Falhou**.

## Medidas

| Medida | Limite | O teu valor |
| --- | --- | --- |
| Instalar o Windows Server, até poderes entrar | até 120 min | 20 min |
| Criar o AD (`Install-ADDSForest`) | até 90 min | 10 min, com o reinício (23:59 a 00:09) |
| Arranque do DC01, até poderes entrar | até 15 min | 1 min 18 s |
| `Get-ADUser -Filter *`, segunda execução | até 30 s | 0,039 s (a primeira foi 5,49 s) |
| Instalar o AD CS (bónus) | até 45 min | |
| As três máquinas ligadas | 30 min sem bloquear | |
| Pressão da memória do Mac | não fica vermelha | |
| `Get-ADUser -Filter *` no fim dos 30 minutos | até 30 s | |

## Decisão

Primeira pergunta: o laboratório base (DC01, WS01 e Kali) cumpre todos os limites, menos os do AD CS?
Segunda pergunta: o AD CS cumpriu o limite?

| Resultado | Plano |
| --- | --- |
| Sim e sim | **Plano A completo:** o projeto segue como está, com ataques a certificados. |
| Sim e não | **Plano A sem certificados:** o projeto segue; fica de fora o capítulo dos certificados. |
| Não à primeira | **Plano B (Samba AD)** ou **Plano C (outro computador)**: ver [`architecture.md`](architecture.md). |

**Plano escolhido:** _por decidir_

**Data:** _por preencher_
