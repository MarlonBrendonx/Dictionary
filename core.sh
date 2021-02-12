

openDictionary(){

	while read line
	do
		 
		local expression=$( echo "$line" | cut -d ':' -f 1 )
		local meaning=$( echo "$line" | cut -d ':' -f 2 )

	
		insertTable "$expression" "$meaning" 

	done < "$DT_PATH"

	return 0

}

startTable(){

	attributes[key]='-1'
	attributes[expression]=""
	attributes[meaning]=""	

	for(( i=0; i<"$size" ; i++ ))
	do
		table["$i"]="${attributes[@]}" 		
	done

}

#Sondagem para  verificar se a posição na tabela esta sendo usada,caso esteja, utiliza-se um contator "tentativas" para incrementar para a próxima posição
poll(){

	position=$(( ("$key" % "$size") + "$1" ))
	
}

#funcao hashing que calcula a chave
createKey(){
		
	local ascii_a=$( printf %d \'"a" )
	char_to_ascii=()
	i=0
		
	for pos in 0 1 2
	do		
		char_to_ascii[$pos]=$( printf %d \'"${1:$pos:1}" )

	done
			
	key=$(( ("${char_to_ascii[0]}" - "$ascii_a") *26 *26 )) 
	key=$(( "$key" + (("${char_to_ascii[1]}" - "$ascii_a") *26) ))
	key=$(( "$key" + (("${char_to_ascii[2]}" - "$ascii_a")+1) )) 

}


insertTable(){

	# $1 = expression
	# $2 = $meaning	

		

	position='-1'
	key='-1'
	local attempts='0'
	local flag='1'
	
	createKey "$1"
	
	while [[ "$flag" -ne '0'  ]]
	do
		poll "$attempts"
		

		if (( "${table[$position]%%:*}" != '-1'  ))
		then
			
			
			pos_table=$( echo ${table[$position]%%:*} )
		
			if (( "${pos_table:=-1}" == "$position"  ))
			then
				let attempts++
			fi

		else
			
			attributes[key]="$position:"
			attributes[expression]="$1"
			attributes[meaning]=":$2"
			
			table["$position"]="${attributes[@]}" 

			flag='0'
		fi		
	done

	return 0
}

removeTable(){

		
	for(( i=0; i<"$size" ; i++ ))
	do
		if (( "${table[$i]%%:*}" != '-1' ))
		then

			if [[ $( echo "${table[$i]// /}" | cut -d ':' -f 2 ) == "${1// /}" ]]
			then
				attributes[key]='-1'
				attributes[expression]=""
				attributes[meaning]=""

				table[$i]="${attributes[@]}"
				
				return 0

			fi
		fi
			
	done

	return 1

}

showDictionary(){
	
	echo -e "==============Dictionary=============\n"

	for(( i=0; i<"$size" ; i++ ))
	do
		if (( "${table[$i]%%:*}" != '-1' ))
		then
			echo -e "${green}|${end} ${table[$i]#* }"
			
		fi
			
	done
	echo -e "\n\n"

}

search(){

	for(( i=0; i<"$size" ; i++ ))
	do
		if (( "${table[$i]%%:*}" != '-1' ))
		then

			if [[ $( echo "${table[$i]// /}" | cut -d ':' -f 2 ) == "${1// /}" ]]
			then
				
				printf " ${green}\xE2\x9C\x94${end} Expressão encontrada!\n\n"
				echo -e " ${table[$i]#* }\n"
				return 0

			fi
		fi
			
	done

	return 1
	
}

saveDictionary(){

	
	[[ $( > "$DT_PATH" ) != '0' ]] || { echo -e "Erro ao salvar o dicionário!\n"; exit 1;} 

	for(( i=0; i<"$size" ; i++ ))
	do
		if (( "${table[$i]%%:*}" != '-1' ))
		then
			
			echo -e "${table[$i]#* }" >> "$DT_PATH"
			
		fi
			
	done

	sort "$DT_PATH" -o "$DT_PATH" 

	(( "$?" != 0 )) && { echo "Erro ao ordenar o dicionário" ; exit 1 ;}

	return 0
}

