# Análise Programa Minha Casa Minha Vida

## Contexto  
O Programa Minha Casa, Minha Vida (MCMV) é uma iniciativa habitacional do governo federal do Brasil, criada pelo presidente Lula em março de 2009. Ele é gerenciado pelo Ministério das Cidades e oferece subsídios e taxas de juros reduzidas para tornar mais acessível a aquisição de moradias populares. Ele abrange diversas faixas de renda e especificações de locais e formas de financiamento.

## Objetivo  
Analisar as informações sobre Minha Casa, Minha Vida - Linha Financiada, que são unidades habitacionais contratadas via financiamento a pessoas físicas, com recursos do Fundo de Garantia do Tempo de Serviço (FGTS), de maneira analítica, ou seja, apresentando os dados sobre os contratos de financiamento do FGTS, nas faixas de renda do MCMV, ao nível de pessoa física.

## Ferramentas Utilizadas  
Utilizei o VS Code e o Notepad++ para o tratamento inicial de caracteres da base. Em seguida, utilizei o SQL Server para a importação da base, o tratamento de dados e para as consultas SQL da análise. Posteriormente, utilizei o Power BI para a visualização gráfica de algumas consultas.

### Dicionário de Dados:
1.	data_referencia: Data de referência dos dados - TEXTO
2.	cod_IBGE: Código IBGE do município - TEXTO
3.	txt_municipio: Nome do Município - TEXTO
4.	mcmv_fgts_txt_uf: UF em que o município se localiza - TEXTO 
5.	txt_regiao: Região em que a UF se localiza. - TEXTO
6.	data_assinatura_financiamento: Data da contratação do financiamento - DATA
7.	qtd_uh_financiadas: Quantidade de unidades habitacionais contratadas no município - NÚMERO
8.	vlr_financiamento: Valor total das operações de crédito realizadas entre o agente financeiro e os mutuários - NÚMERO
9.	vlr_subsidio_desconto_fgts: Valor total do desconto concedido pelo FGTS (Fundo de Garantia do Tempo de Serviço) na operação de crédito para abatimento do valor a ser financiado pelo mutuário - NÚMERO
10.	vlr_subsidio_desconto_ogu: Valor total do desconto concedido pelo OGU (Orçamento Geral da União) na operação de crédito para abatimento do valor a ser financiado pelo mutuário. - NÚMERO
11.	vlr_subsidio_equilíbrio_fgts: Valor total do desconto concedido pelo FGTS(Fundo de Garantia do Tempo de Serviço) na operação de crédito para diminuição da taxa de juros a ser aplicada ao financiamento. - NÚMERO
12.	vlr_subsidio_equilíbrio_ogu: Valor total do desconto concedido pelo OGU (Orçamento Geral da União) na operação de crédito para diminuição da taxa de juros a ser aplicada ao financiamento. - NÚMERO
13.	vlr_compra: Descreve o valor pedido pelo vendedor, normalmente o mesmo que o valor de garantia. - NÚMERO
14.	vlr_renda_familiar: Representa o valor de renda familiar do mutuário/contratante, utilizada para a contratação do financiamento. - NÚMERO
15.	txt_programa_fgts: Descreve o programa vinculado à área responsável pela aplicação dos recursos contratados. - TEXTO
16.	num_taxa_juros: Representa o índice da taxa de juros inicial vinculada ao empréstimo contratado, em forma percentual. - NÚMERO
17.	txt_tipo_imovel: Descreve se o imóvel é Novo ou Usado. - TEXTO
18.	bln_cotista: Descreve se o mutuário/contratante é titular de conta vinculada do FGTS ou não, no formato (S ou N). - TEXTO
19.	txt_sistema_amortizacao: Descreve o sistema de amortização do contrato de financiamento. - TEXTO
20.	dte_nascimento: Data de nascimento do beneficiário. - DATA
21.	txt_compatibilidade_faixa_renda: Descreve a faixa de renda do beneficiário conforme o enquadramento normativo no Programa Minha Casa Minha Vida. - TEXTO
22.	txt_nome_empreendimento: Nome do empreendimento, quando disponível. - TEXTO

### Tratamento de dados:
 Abri o arquivo no Notepad++ e com o “localizar e substituir” inseri os caracteres a seguir, manualmente: 
á|à|â|ã|ä|é|è|ê|ë|í|ì|î|ï|ó|ò|ô|õ|ö|ú|ù|û|ü|ç
a|a|a|a|a|e|e|e|e|i|i|i|i|o|o|o|o|o|u|u|u|u|c

Sei que a ideia é evitar fazer muitos tratamentos manuais, mas a base tinha mais de 6 milhões de linhas e consegui arrumar em menos de 15 minutos, então acredito que tenha sido válido. Já havia tentado selecionar apenas o Encoding correto na importação para o SQLServer, mas mesmo assim ainda não estava funcionando corretamente. Tentei substituir tudo de uma vez no VS Code também, mas pelo tamanho do arquivo começou a dar erro. Por isso preferi seguir do jeito que fiz e remover todos os acentos da base.
Assim que importei a base de dados no SQLServer, iniciei o processo de higienização da tabela fato, que renomeei para t_mcmv com o comando sp_rename.
Em seguida, inspecionei os dados e os tipos de cada coluna com consultas exploratórias, e identifiquei que todas as colunas estavam como VARCHAR, algumas ainda tinham campos em branco e registros com falha de conversão.

• Padronização de valores numéricos: substituí vírgulas por pontos (REPLACE) em todas as colunas com valores financeiros e taxas de juros, para facilitar a conversão posterior para DECIMAL (18,2).

• Diagnóstico com TRY_CONVERT: apliquei testes em todas as colunas que seriam convertidas para tipos numéricos e de data, identificando:

294.766 registros inválidos em num_taxa_juros;  
323 valores não convertíveis em vlr_compra;  
3.142.349 registros nulos em dte_nascimento, que depois da conversão seriam transformados para a “data-zero” do sistema (1900-01-01);  
1.275 registros nulos em “data_assinatura_financiamento”, que depois da conversão seriam mudados para a “data-zero” do sistema (1900-01-01).

Utilizei a função TRY_CONVERT como uma boa prática para garantir qualidade e segurança nas conversões de dados. Essa função permite identificar, de forma não intrusiva, os registros que não estão compatíveis com os tipos desejados (como INT, DECIMAL ou DATE), evitando que erros interrompam o fluxo de processamento.

• Transformação de espaços vazios (' ') para NULL, usando LTRIM(RTRIM(...)) = '', garantindo que esses registros fossem corretamente tratados nas conversões.  
Uma vez que a ideia não era fazer nenhuma análise preditiva, nem imputar os dados para algum modelo de machine learning, e os nulos nesse caso também contam história, resolvi mantê-los.

• Substituição das datas padrão: atualizei todos os valores 1900-01-01 para NULL nas colunas de data - evitando distorções em análises temporais.

• Conversão definitiva de tipos: alterei os tipos de coluna para:  
INT: qtd_uh_financiadas  
DECIMAL (18,2): valores financeiros e taxa de juros  
DATE: datas de nascimento e assinatura

• Verificação de colunas textuais: identifiquei que algumas colunas estavam completamente preenchidas (cod_ibge, txt_municipio, txt_programa_fgts) e outras com grandes volumes ausentes, como:  
txt_nome_empreendimento: 6,9 milhões de registros em branco  
txt_sistema_amortizacao: ~635 mil registros em branco  
bln_cotista: ~295 mil registros em branco

Ao final, deixei a tabela fato t_mcmv com valores convertidos corretamente, registros ausentes devidamente tratados, e preparada para a modelagem dimensional e integração com o Power BI.

## Análises exploratórias via SQL:

• Até 16 de maio de 2025, foram financiadas 6.940.805 unidades em todo o território nacional, desde 2005.  
O programa MCMV foi criado em 2009, pela lógica é estranho ter datas anteriores a 2009. A base apresenta 232 registros entre 2005 e 2008.  
Depois de pesquisar, entendi que existiam outros programas antes do MCMV e que em 1967 começou a prática da utilização do FGTS. Aparentemente a base mantém alguns dados antigos.

• Os estados de SP, MG, PR, RS e GO compõem o TOP 5 em quantidades financiadas.  
Juntos, esses 5 estados somam 62,85% do total de quantidades financiadas.  
Entre eles, SP lidera com 27,08% do total geral.

• O município com maior quantidade de unidades financiadas é São Paulo-SP com 397.047, seguido do Rio de Janeiro-RJ, com 146.554 e João Pessoa-PB com 96.751.  

• A faixa de renda 2 é a faixa da maioria dos beneficiários, com um total de 3.819.591 unidades financiadas nessa linha do MCMV.  
Em seguida vemos a faixa 1, com 1.722.299 unidades financiadas;  
a faixa 3, com 1.185.785 unidades habitacionais e a categoria Fora MCMV/CVA com as 213.130 habitações restantes do total.

• A maior parte dos beneficiários está na faixa de renda 2 em quase todo o território nacional,  
com exceção de AL e PI onde a maioria é da faixa 1,  
e AP que tem a faixa 3 como a mais populosa.

• De maneira geral, a renda familiar média dos beneficiários dessa linha com utilização do FGTS do MCMV, é de 3046,36 reais.  

• Foi possível identificar que 11 estados (AP, DF, AM, AC, SP, RJ, RR, SC, ES, RO e TO) possuem renda familiar média superior em relação à renda familiar média nacional calculada a partir dessa base,  
com valores que vão de 3.072,02 (TO) a 4.762,93 (em AP).  
Os outros 16 têm renda familiar média que vai de 2.135,94 em AL a 2.918,45 em MT.

• O valor médio nacional de financiamentos nessa linha do MCMV é 105.832,44.  
Quando analisamos por unidade federativa, temos SP com o maior valor médio em 123.544,76 e PI com o menor, 76.759,35.

• O maior valor de financiamento foi no DF em 1.324.000, enquanto o menor financiamento foi de 7 reais na BA.

• Quanto ao valor total de financiamentos, o ano de 2024 foi onde se concentrou o maior valor com  
99.213.543.406,54 (noventa e nove bilhões, duzentos e treze milhões, quinhentos e quarenta e três mil, quatrocentos e seis reais e cinquenta e quatro centavos).  
Já o ano com menor valor total foi 2007 com apenas 5.669,73.

• Quando consideramos os registros com ausência de ano de financiamento, temos um valor de financiamento total de  
111.559.637,14 (Cento e onze milhões, quinhentos e cinquenta e nove mil, seiscentos e trinta e sete reais e quatorze centavos) sem essa informação.

• Quando analisamos a idade que o beneficiário tinha quando assinou o contrato, temos uma idade média nacional de 32 anos.  
A maior idade registrada foi de 78 anos e a menor, 16 anos.  
Foi possível identificar 45 registros com idade de 16 anos e 278 com 17 anos.  
Algumas hipóteses que justificariam esses financiamentos com valores menores do que a maioridade nacional,  
são a emancipação desses beneficiários, a imputação de dados de dependentes dos beneficiários originais, por algum motivo,  
ou ainda erro de digitação no dígito da casa da dezena.  

O Sudeste é a região com maior incidência de assinaturas por menores sendo 25 registros de 16 anos e 141 registros de 17 anos.  
Em segundo lugar temos o Sul com 10 registros de 16 anos e 81 de 17 anos;  
o Nordeste com 8 registros de 16 anos e 37 de 17 anos  
e o Centro-Oeste com 2 registros de 16 anos e 18 de 17 anos.  
No Norte do país houve apenas um registro com 17 anos, no estado de Roraima.

• Analisando os valores da coluna “vlr_subsidio_desconto_fgts” é possível observar que o estado de SP foi o que mais recebeu esse tipo de desconto,  
com um montante de 10.305.973.904,46, seguido de MG e GO com 4.802.532.997,82 e 4.520.293.750,12 respectivamente.

Essa categoria de desconto tem como característica principal o vínculo com o trabalhador,  
uma vez que o Fundo de Garantia é alimentado pelas contribuições dos empregadores.  
O governo pode usar parte desses recursos para conceder subsídios que reduzem o valor que o beneficiário precisará financiar —  
é um desconto direto no empréstimo, mas proveniente de recursos vinculados ao próprio mercado de trabalho.

• Analisando os valores da coluna “vlr_subsidio_desconto_ogu” é possível observar que o estado de SP foi o que mais recebeu esse tipo de desconto, com um montante de 1.325.385.618,00, seguido de MG e PR com 703.722.686,48 e 561.913.414,24 respectivamente.  
Diferente do desconto pelo FGTS, o subsídio via OGU vem diretamente do governo federal, por meio de verba pública. Ele é usado para promover acesso à moradia em faixas de renda muito baixas ou regiões estratégicas, funcionando como uma política social explícita.

• A base de dados tem 294.766 registros onde não foram informado a taxa de juros.  
Em um primeiro momento parece bastante estranho, mas pesquisando entendi que existem casos específicos, principalmente para faixas mais baixas de renda, onde os beneficiários podem receber subsídios tão altos que o valor financiado é mínimo, e em alguns casos, sem juros.  
Também, beneficiários do Bolsa Família ou do BPC (Benefício de Prestação Continuada) têm direito a imóvel 100% gratuito, ou seja, sem parcelas e sem juros. 

• Através da consulta é possível observar que a Faixa 1 tem 112.511, menos da metade do total de registros sem taxa.  
A faixa 2 tem 89.074, a faixa 3 tem 87.417 e a faixa fora MCMV/CVA tem 5764.  
Existe uma chance de pelo menos uma parte desses registros sem taxa serem decorrentes de erros ou falta de dados mesmo e não uma taxa 0 real.

• Do total de unidades financiadas, 5.671.321 foram de imóveis novos e 1.269.484 tinham como tipo de imóvel o usado.

• Quanto ao sistema de amortização dos contratos, o mais utilizado é o método tabela PRICE, que compreende 81,90% do total,  
ou 5.684.365 unidades habitacionais, nesse sistema, a prestação é fixa - valor total constante - com amortização crescente e juros decrescentes,  
ou seja, nos primeiros anos você paga mais juros do que amortização, e só depois inverte. No fim, o total pago é maior do que no SAC.  

Do restante, 8,93%, ou 620.096 unidades, foram contratadas pelo sistema SAC  
(onde cada parcela inclui uma amortização fixa, valor que reduz a dívida, mas os juros vão caindo,  
então as parcelas diminuem ao longo do tempo. Isso resulta em menor custo total do financiamento, mas parcelas iniciais são mais altas.).  

Apenas 0,01%, 790 unidades, foram amortizadas pelo sistema SACRE  
(é uma espécie de “SAC ajustado” que incorpora regras de cálculo vinculadas à TR (Taxa Referencial).  
Ele tenta equilibrar os benefícios de ambos: prestações mais leves no início do contrato, mas com amortizações controladas.).  
9,16% dos registros, 635.554 unidades, não possuem essa informação.


## Para o Power BI

Como o ambiente SQL Server estava localizado em uma máquina diferente de onde estava o PBI, optei por realizar todo o tratamento e modelagem diretamente nele e, em seguida, exportar a base final limpa como CSV. Essa abordagem permitiu preservar todas as regras de limpeza e tipagem, mantendo a análise no Power BI fiel à versão original.

---

## Página 1: Visão Geral - Panorama macro sobre volume, tempo e território dos financiamentos

### Quantidade Financiada por UF  
Tipo de gráfico: Gráfico de barras verticais – Mostra a distribuição geográfica dos financiamentos no Brasil.

### Quantidade Financiada por Ano  
Tipo de gráfico: Gráfico de linha - Evolução temporal do volume de financiamentos entre 2005 e 2025.  
Revela picos e quedas ao longo dos anos, como o crescimento entre 2010 e 2015, queda em 2018 e um pico em 2020.  
Pode refletir políticas públicas, crises econômicas ou mudanças nos critérios de financiamento.

### Valor Total de Financiamentos  
Tipo de visual: Card - Mostra o valor total financiado: R$ 734,56 bilhões.  
Revela a magnitude financeira do programa e o impacto econômico geral.

### Total de Unidades Financiadas  
Tipo de visual: Card - Mostra o total de unidades habitacionais financiadas: 6,94 milhões.  
Revela a escala social do programa com quantas famílias foram beneficiadas.

### TOP 10 Municípios em Quantidade de Financiamento  
Tipo de gráfico: Gráfico de barras verticais.  
Lista os 10 municípios com maior volume de contratos.  
Revela a concentração em grandes centros urbanos como São Paulo, Rio de Janeiro e João Pessoa.  
Indica onde há maior pressão habitacional ou maior adesão ao programa.

---

## Página 2: Perfil dos Beneficiários - Quem são, onde moram, qual a idade e a renda

### Distribuição de Idade dos Beneficiários  
Tipo de gráfico: Gráfico de barras verticais.  
Demonstra que a maior parte dos beneficiários está na faixa de 20 a 30 anos.  
Revela que o programa atinge uma boa parcela dos chamados jovens adultos, possivelmente em busca do primeiro imóvel ou do início de uma vida familiar.

### Tipo de visual: Card - Renda Familiar Média Nacional  
A renda familiar média dos beneficiários é de R$ 3.050.  
Isso acaba confirmando o foco social do programa, que é voltado para famílias de baixa a média renda.

### Idade por Região  
Tipo de visual: Tabela com estatísticas (mínima, média e máxima).  
A idade média dos beneficiários é bastante uniforme entre as regiões, em torno de 32 anos.  
É possível observar que o perfil etário do público é consistente nacionalmente, com pequenas variações.  
A menor idade registrada é 16 anos e a maior é 78 anos.

### Quantidade Financiada por Faixa de Renda  
Tipo de gráfico: Gráfico de barras verticais - A Faixa 2 lidera com folga (3,8 milhões de unidades), seguida pela Faixa 1.  
É possível entender que o programa tem maior penetração entre famílias com renda intermediária dentro dos critérios do MCMV.

### Quantidade por Tipo de Imóvel  
Tipo de gráfico: Gráfico de donut - A maioria dos imóveis financiados é novo (81,71%).  
Esse predomínio pode estar relacionado às facilidades oferecidas para aquisição de imóveis na planta, como subsídios mais acessíveis, maior oferta por parte das construtoras e por condições de parcelamento mais flexíveis.

---

## Página 3: Análises Financeiras - Como o dinheiro circula: valores, descontos e sistemas de amortização

### Financiamento Médio por UF  
Tipo de gráfico: Gráfico de barras horizontais – Os estados com maior valor médio de financiamento são SP (R$ 124K), DF (R$ 120K) e AM (R$ 117K).  
Pode indicar maior urbanização ou renda média mais alta.

### Taxa de Juros – Média, Maior e Menor  
Tipo de visual: Cards – A taxa média é 7,14%, com a maior em 9,16% e a menor em 4,24%.  
A variação nas taxas praticadas, em geral, pode estar ligada ao tipo de contrato, faixa de renda ou agente financeiro.

### Sistema de Amortização  
Tipo de gráfico: Gráfico de barras verticais - O sistema PRICE domina com 82%, enquanto SAC e outros têm participação mínima.

### Subsídio FGTS e OGU por UF  
Tipo de gráfico: Gráfico de barras verticais agrupadas - SP lidera com folga (R$ 10,3 bilhões), seguido por MG, GO e PR.  
Revela alta concentração de subsídios em estados populosos e com maior volume de contratos.  
Ainda, o FGTS tem maior participação do que o subsídio OGU.

### Financiamento Médio por Faixa de Renda  
Tipo de visual: Tabela - É possível observar que fora do MCMV/CVA, o valor médio é altíssimo (R$ 11.573,36),  
enquanto Faixa 1 tem o menor (R$ 1.669,27).  
Isso demonstra que quanto maior a renda, em geral, maior é o valor financiado.

### Valor Médio por Faixa de Renda e Região  
Tipo de gráfico: Gráfico de dispersão (scatter plot) - O Sudeste lidera em valor médio de financiamento (até R$ 250K),  
enquanto Norte e Nordeste têm valores mais baixos.

---

## Página 4: Qualidade dos Dados - Campos com valores nulos ou ausentes

### Contratos Sem o Valor de Compra  
Tipo de visual: Card - Apenas 323 contratos (0,00465%) não possuem valor de compra informado.

### Contratos Sem Taxa de Juros  
Tipo de visual: Card - 295 mil contratos (4,25%) estão sem taxa de juros registrada.

### Contratos Sem Data de Assinatura  
Tipo de visual: Card - 1.275 contratos (0,02%) não têm data de assinatura.  
O impacto nas análises é pequeno, dado o tamanho total da base,  
mas pode indicar deficiência no processo de coleta e manutenção dos dados,  
uma vez que todo contrato teve que ser assinado em algum momento.

### Contratos Sem Cotista (Titular da Conta)  
Tipo de visual: Card - 643 mil contratos (9,27%) não têm cotista (se o beneficiário é o titular da conta) identificado.  
A ausência desses dados pode indicar falhas de cadastro ou contratos incompletos.

### Contratos Sem Sistema de Amortização  
Tipo de visual: Card - 636 mil contratos (9,16%) não informam o sistema de amortização.

### Beneficiários Sem Data de Nascimento  
Tipo de visual: Card - 3 milhões de registros (45,27%) estão sem data de nascimento.  
Essas ausências podem indicar deficiência no processo de coleta e manutenção dos dados ou no preenchimento dos contratos.  
Ainda, inviabiliza ou pelo menos dificulta estudos por faixa etária ou geração.

### Beneficiários Sem Data de Nascimento  
Tipo de visual: Card – 3 milhões de registros (45,27%) estão sem data de nascimento.  
Essas ausências podem indicar deficiência no processo de coleta e manutenção dos dados ou no preenchimento dos contratos.  
Ainda, inviabiliza ou pelo menos dificulta estudos por faixa etária ou geração.
