# Relatório de nível cliente

O relatório é o que um recrutador (ou um cliente) lê primeiro. Escreve-se em Markdown e converte-se em PDF.

## Como gerar o PDF

```bash
brew install pandoc typst                  # uma vez
cp report/template.md report/relatorio.md  # uma vez; edita o relatorio.md
make report                                # gera report/build/relatorio.pdf
```

O ficheiro `report/relatorio.md` entra no Git; a pasta `report/build/` não.

## O que faz um bom relatório

- **Resumo executivo numa página**, sem jargão: o que foi testado, o pior que se encontrou, o risco para o negócio e as três ações mais importantes.
- **Achados por ordem de gravidade**, cada um com descrição, impacto, passos para reproduzir, evidência, recomendação e re-teste.
- **Gravidade com CVSS**: indica sempre a versão e o vetor, para outra pessoa poder confirmar a conta (calculadora oficial em https://www.first.org/cvss/).
- **Reprodutível**: quem lê consegue repetir cada passo.
- **Sem segredos**: nada de palavras-passe ou chaves reais nas capturas.
- **Honesto**: diz o que ficou por testar e o que não ficou provado.

Todos os achados vêm do que está em [`../attack/`](../attack/README.md), [`../detections/`](../detections/README.md) e [`../hardening/`](../hardening/README.md).
