## Consolidação de Uma Base de dados específica 

## Esse código faz parte de um trabalho em desenvolvimento junto ao Núcleo de Estudos em Economia Agrícola do IPEA/MAPA. Busquei utilizar bastante funções para evitar repetições de códigos, além de tentar fazer o código fácilmente adaptavél para vários tipos de dados, já que trabalhei com `.txt` e `.csv`. Vale salientar que essa não foi a minha primeira experiência numa montagem extensa de banco de dados, então, minha primeira tentativa, por achar mais fácil a visualização, eu usei o espaço do `Global Environment` para colocar todos os data.frames que chamei. Posteriormente comecei a utilizar `lists`. Nesse ponto Listas deixam mais *Clean* o nosso espaço de trabalho, acabei preferindo e será tema desse post. Não me adentrarei em detalhes sobre listas nesse post.

## Sem mais balela, mas do que se trata os dados? Bem, meu objetivo era puxar do Tribunal Superior Eleitoral (tse) dados sobre eleções municipais desde 2000 até 2016, que contessem a escolaridade dos prefeitos eleitos, partido, etc, além de colocar todos eses dados num data frame. Para a manipulação dos dados desenvolvi várias funções e elas demandam alguma explicação. No site do tse todos os anos estão zipados, depois de extraído as pastas fiquei com cinco pastas, onde se continham todas as informações que me interessavam. Dessa feita, bolei uma forma de pegar todos esses dados usando a própria acomodação dos dados nas pastas.

## A primeira função: Criar uma lista com todas as bases de cada ano, geral o bastante que eu possa usar-lá para todos os tipos de dados que encontrei nas pastas. A primeira função ficou da seguinte forma:

read_list <- function(list_of_datasets, read_func, header){ #list_of_datasets é um vetor com todos os nomes dos arquivos, read_func é para indicarmos  qual a função que utilizaremos para importar os dados, header é para indicar se há ou não cabeçalho.Lembre, uma função deve ser o mais geral possível!
  
  require(haven) # fiz isso para caso eu precisasse usar uma função semelhante com dados importados do stata.
  
  read_and_assign <- function(dataset, read_func){ # uma função dentro de uma função
    dataset_name <- as.name(dataset) #para fazer referência à um objeto (dataset) por um nome. 
    dataset_name <- read_func(dataset,header=header, sep=";") #Onde ocorre a leitura dos dados
  }
  
  # a função invisible é usada para suprimir saídas desnecessárias
  
  output <- invisible(
    sapply(list_of_datasets,
           read_and_assign, read_func = read_func, simplify = FALSE, USE.NAMES = TRUE))
  
  # Esse trecho de código é para nos livrar da extensão q era necessária para a leitura dos dados.
  names_of_datasets <- c(unlist(strsplit(list_of_datasets, "[.]"))[c(T, F)])
  names(output) <- names_of_datasets
  return(output)
  
}

## Feita a função que vai ler os dados e transformá-las em uma única lista por ano, agora precisamos indicar a pasta e o a extensão que cada base de dados está. Essa segunda função veio pelo necessidade de repetir diversas vezes um código e como um dos arquivos tinha uma anormalia, um dataset com todos os dados já arrumdinhos com todos os municípios brasileiros fiz a seguinte função, sempre pensando na generalizadade da função. 

list_for_year <-function(path, pattern, header, problematic_fact) {
  #path caminho para a pasta com os arquivos
  #pattern o padrão da extensão
  #header se tem cabeçário ou não
  #problematic_fact se tem um arquivo a mais
  
  setwd(path)
  
  data_files <- list.files( pattern = pattern)
  
  if (problematic_fact == T) {
    
    data_files <- data_files[-6]#retirar o brasil da jogada
    
  }else{
    
    data_files <- data_files
    
  }
  
  print(data_files)
  
  output<-read_list(data_files, read.csv, header = header)
  
  return(output)
}


Montada as duas funções, podemos rodar todos os anos e extrair todos os dados em listas separadas por ano.

#2000

list_2000 = list_for_year("D:/Trabalho/R Stuff/Consolidação de Dados/consulta_cand_2000", ".txt", header = F, problematic_fact = F)

#2004

list_2004<-list_for_year("D:/Trabalho/R Stuff/Consolidação de Dados/consulta_cand_2004", ".txt", header = F, problematic_fact = F)

#2008

list_2008<-list_for_year("D:/Trabalho/R Stuff/Consolidação de Dados/consulta_cand_2008", ".txt", header = F, problematic_fact = F)

#2012

list_2012<-list_for_year("D:/Trabalho/R Stuff/Consolidação de Dados/consulta_cand_2012", ".txt", header = F, problematic_fact = F)

#2016

list_2016<-list_for_year("D:/Trabalho/R Stuff/Consolidação de Dados/consulta_cand_2016", ".csv", header = T, problematic_fact = T)


setwd("D:/Trabalho/R Stuff/Consolidação de Dados")

# O caminho que defini para o próximo passo foi empilhar por estado por ano e filtrar as variáveis de interesse e apenas prefeitos eleitos. Criei uma função para unir os dados por Estados.

union_data <- function(a,b,c,d,e) {
  require(dplyr)
  names <- c("state", "year", "city", "mayor", "name", "party", "gender", "education", "situation", "cond" )
  
  x1 <-a %>%
    filter(V10 == "PREFEITO" &  (V43== "ELEITO" | V43== "ELEITO POR QUOCIENTE PARTIDÁRIO")) %>%
    select(V6, V3, V8, V10, V11, V19, V31, V33, V17, V43)
  colnames(x1) <- names
  
  
  colnames(x1) <- names
  
  x2 <-b %>%
    filter(V10 == "PREFEITO" &  (V43== "ELEITO" | V43== "ELEITO POR QUOCIENTE PARTIDÁRIO")) %>%
    select(V6, V3, V8, V10, V11, V19, V31, V33, V17, V43)
  
  colnames(x2) <- names
  
  
  x3 <-c %>%
    filter(V10 == "PREFEITO" &  (V43== "ELEITO" | V43== "ELEITO POR QUOCIENTE PARTIDÁRIO")) %>%
    select(V6, V3, V8, V10, V11, V19, V31, V33, V17, V43)
  colnames(x3) <- names
  
  
  x4 <-d %>%
    filter(V10 == "PREFEITO" &  (V43== "ELEITO" | V43== "ELEITO POR QUOCIENTE PARTIDÁRIO")) %>%
    select(V6, V3, V8, V10, V11, V19, V31, V33, V17, V43)
  colnames(x4) <- names
  
  
  x5 <-e %>%
    filter(DS_CARGO == "PREFEITO" &  (DS_SIT_TOT_TURNO== "ELEITO" | DS_SIT_TOT_TURNO== "ELEITO POR QUOCIENTE PARTIDÁRIO")) %>%
    select(SG_UF, ANO_ELEICAO, NM_UE, DS_CARGO, NM_CANDIDATO, SG_PARTIDO, DS_GENERO, DS_GRAU_INSTRUCAO, DS_DETALHE_SITUACAO_CAND, DS_SIT_TOT_TURNO)
  
  colnames(x5) <- names
  rbind(x1,x2,x3,x4,x5)
  
  x5$state <- as.factor(x5$state)
  x5$city <- as.factor(x5$city)
  x5$mayor <- as.factor(x5$mayor)
  x5$party <- as.factor(x5$party)
  x5$gender <- as.factor(x5$gender)
  x5$education <- as.factor(x5$education)
  x5$situation <- as.factor(x5$situation)
  x5$name <- as.factor(x5$name)
  
  
  final<- rbind(x1,x2)
  final<- rbind(final,x3)
  final<- rbind(final,x4)
  final <-rbind(final,x5)
  
  return(final)
}

#Para automatizar 

list_estados<-list()

for (i in 1:26) {
  
  list_estados[[i]] = union_data(list_2000[[i]], list_2004[[i]], list_2008[[i]], list_2012[[i]], list_2016[[i]])
  
}


zinal <- list_estados[[1]]

for (i in 2:26) {
  
  zinal <- rbind(zinal, list_estados[[i]])
  
}


write.table(zinal, "eleicoes_mun.txt", sep="\t", row.names = F)

zinal %>%
  filter(city == "ARACOIABA")


