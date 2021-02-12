#! /usr/bin/env bash

#-------------------------HEADER----------------------------------------------------|
# AUTOR             : Marlon Brendo <marlonbrendo2013@gmail.com>
# DATA-DE-CRIAÇÃO   : 2021-1-12
# PROGRAMA          : Dicionário
# LICENÇA           : MIT
# DESCRIÇÃO 	    : Dicionário utilizando tabela Hash em Shell Bash
#
#-----------------------------------------------------------------------------------|

# ===================================================================================
#				Bibliotecas
# ===================================================================================

#Carregando biblioteca essenciais
libraries=(

	'dt_hash.conf'
	'core.sh'
	
)

for libs in "${libraries[@]}"
do
	source "$libs" || { echo "Erro ao carregar as bibliotecas \"$libs\""; exit 1 ;} 
done

# ===================================================================================
#				Variáveis
# ===================================================================================

size=16000;


declare -a menu=(

	" [1]-Pesquisar expressão \n" 
	"[2]-Inserir expressão\n"
	"[3]-Remover expressão\n"
	"[4]-Exibir dicionario\n"
	"[5]-Salvar\n"
	"[6]-Exit\n"

)


#Iniciando variáveis de configuracao em modo default
DICTIONARY_OPEN="${DICTIONARY_OPEN:=0}"
DT_PATH="${DT_PATH:="/home/${USER}/Documentos/dictionary.txt"}"

#Algumas cores
readonly red='\033[31;1m'
readonly green='\033[32;1m'
readonly end='\033[m'

#Declarando atributos e a tabela 
declare -A attributes=( [key]='' [expression]='' [meaning]='' )
declare -A table=()

# ===================================================================================
#				Testes
# ===================================================================================

[[ ! -e "$DT_PATH" ]] && > "$DT_PATH" 

#Inicializando a tabela hash
startTable

#Abrindo o dicionário 
openDictionary
(( "$?" == '0' )) && DICTIONARY_OPEN='1'


# ===================================================================================
#				Main
# ===================================================================================

while 

	echo -e "${menu[@]}"
	read -p "Opção:>" op

	case "$op" in

	 1) 

		(( "$DICTIONARY_OPEN" != 1 )) && { echo -e "${red}[!]${end} Dicionário não está aberto"; exit 1; } 
		read -p "Informe a expressão: " expression

		clear
		search "$expression" 

		(( "$?" != '0' )) && printf "${red} \u274c ${end} Expressão não encontrada\n\n" || echo     ;;
	
	 2) 	
		(( "$DICTIONARY_OPEN" != 1 )) && { echo -e "${red}[!]${end} Dicionário não está aberto"; exit 1; }
		read -p "Informe a expressão: "   expression
		read -p "Informe o significado: " meaning
		
		clear
		insertTable "${expression,,}" "${meaning,,}"
		
		(( "$?"  == '0' )) && printf " ${green}\xE2\x9C\x94${end} Expressão adicionada!\n\n" \
		|| printf "${red} \u274c ${end} Não conseguimos remover!\n\n"	
													     ;;

	 3)	(( "$DICTIONARY_OPEN" != 1 )) && { echo -e "${red}[!]${end} Dicionário não está aberto"; exit 1; }
		read -p "Informe a expressão: "   expression
		
		clear
		removeTable "${expression,,}"

		(( "$?"  == '0' )) && printf " ${green}\xE2\x9C\x94${end} Expressão removida!\n\n" \
		|| printf "${red} \u274c ${end} Não conseguimos remover!\n\n"				     ;;

	 4) 	{ clear; showDictionary; }   			 		            		     ;;

	 5)
		clear 	
		saveDictionary  
	
		(( "$?"  == '0' )) && printf " ${green}\xE2\x9C\x94${end} Dicionário Salvo!\n\n" \
		|| printf "${red} \u274c ${end} Não conseguimos salvar!\n\n"				     ;;
     	
	 6)     { clear; exit 1;} 									     ;;
								             
	 *)     { clear ; printf "${red} [!] ${end}Opção inválida\n\n";} 				     ;;

	esac 

do :; done
