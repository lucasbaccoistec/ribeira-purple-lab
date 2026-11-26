# Registo da semana 0

Preenche este ficheiro à medida que segues o guia da semana 0 (o guia fica fora do Git; este registo é a prova do teste de viabilidade). Os limites são os do portão de decisão.

## Passos

| Passo | Resultado | Notas |
| --- | --- | --- |
| 1. UTM instalado | Passou | Já estava instalado (QEMU 10.0). |
| 2. Windows Server no DC01 | Passou | Server 2022 Standard Evaluation, modo Core. Instalação em 20 min (23:01 a 23:21, 25/11/2026). Nome DC01 e IP fixo 192.168.64.10 feitos no SConfig. |
| 3. Active Directory no DC01 | Passou | Domínio `ribeira.test` criado em 10 min. NTDS, DNS, Netlogon e Kdc a correr, e o AD continuou a responder depois do reinício. DNS do DC em 127.0.0.1, reencaminhador 1.1.1.1. Cópia `DC01-limpo` feita (7,5 GB). |
| 4. Certificados (AD CS), bónus | Passou | Autoridade `Ribeira-CA` (empresa, raiz) em 2 min 17 s: função em 2 min 13 s e configuração em 4 s (26/11/2026). Valores por omissão do Windows (RSA 2048, SHA-256, 5 anos). `CertSvc` a correr e `certutil -ping` respondeu. Licença do DC01: Licensed, 179 dias. |
| 5. WS01 no domínio | Passou com problemas | Windows 11 Pro ARM64, endereço 192.168.64.5 (DHCP), copiar e colar a funcionar depois de reiniciar. Três problemas, todos resolvidos: (1) o DNS por IPv6 do router do Mac tinha prioridade e o domínio não era encontrado; resolvido a desligar o IPv6 na placa do WS01. (2) Entrou no domínio, mas a mudança de nome falhou ("directory service is busy", DC01 lento); resolvido com `Rename-Computer` à segunda. (3) O DC01 estava no fuso do Pacífico e ficou 8 horas adiantado em UTC; posto em `GMT Standard Time` e a sincronizar com `pool.ntp.org`. Entrada como `RIBEIRA\ana.teste` e `nltest` a mostrar o DC01. As cópias `DC01-limpo` e `DC01-com-CA` ficaram desatualizadas (sem o WS01 e com o fuso errado). |
| 6. Kali | Passou | Kali novo (ARM64, 2 GB, 2 CPUs), endereço 192.168.64.7. O pacote `ntpdate` já não existe: instalado `ntpsec-ntpdate`, que traz o mesmo comando. Cópia `KALI-limpo` feita. |
| 7. As três juntas, 30 minutos | Passou | 22:29 a 23:02 (26/11/2026). Do Kali: portas 53, 88, 389 e 445 abertas, `ldapsearch` devolveu `DC=ribeira,DC=test`, `nxc smb` mostrou DC01 e `ribeira.test`, hora igual à do Mac. Nenhuma máquina bloqueou (os ecrãs apagaram-se por inatividade, o que é normal). Cópias `WS01-limpo` e `DC01-com-WS01` feitas antes do teste. |

Resultados possíveis: **Por fazer**, **Passou**, **Passou com problemas**, **Falhou**.

## Medidas

| Medida | Limite | O teu valor |
| --- | --- | --- |
| Instalar o Windows Server, até poderes entrar | até 120 min | 20 min |
| Criar o AD (`Install-ADDSForest`) | até 90 min | 10 min, com o reinício (23:59 a 00:09) |
| Arranque do DC01, até poderes entrar | até 15 min | 1 min 18 s |
| `Get-ADUser -Filter *`, segunda execução | até 30 s | 0,039 s (a primeira foi 5,49 s) |
| Instalar o AD CS (bónus) | até 45 min | 2 min 17 s |
| As três máquinas ligadas | 30 min sem bloquear | 33 min, sem bloqueios |
| Pressão da memória do Mac | não fica vermelha | Verde o tempo todo (13,1 a 13,3 GB usados de 16 GB, 1,8 GB de swap) |
| `Get-ADUser -Filter *` no fim dos 30 minutos | até 30 s | 0,027 s (a primeira foi 3,78 s) |

## Decisão

Primeira pergunta: o laboratório base (DC01, WS01 e Kali) cumpre todos os limites, menos os do AD CS?
Segunda pergunta: o AD CS cumpriu o limite?

| Resultado | Plano |
| --- | --- |
| Sim e sim | **Plano A completo:** o projeto segue como está, com ataques a certificados. |
| Sim e não | **Plano A sem certificados:** o projeto segue; fica de fora o capítulo dos certificados. |
| Não à primeira | **Plano B (Samba AD)** ou **Plano C (outro computador)**: ver [`architecture.md`](architecture.md). |

**Plano escolhido:** Plano A completo. O laboratório base cumpriu todos os limites e o AD CS também (2 min 17 s).

**Data:** 26/11/2026
