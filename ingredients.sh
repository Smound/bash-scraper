#!/bin/bash

grep "^:slug" result.txt > slugs.tmp
grep "^:title" result.txt > titles.tmp

mkdir recept

echo "Grep found $(wc -l slugs.tmp) slugs"

TOTAL_RECIPES=$(wc -l slugs.tmp | cut -d" " -f 1)

for line in $(seq 1 ${TOTAL_RECIPES})
do
	FILENAME=./recept/$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g)
	TITLE=$(sed "${line}q;d" titles.tmp)
	touch "${FILENAME}"
	echo -e "${TITLE}\n\n" > "${FILENAME}"

	slug=$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g )
	echo $slug
	curl -s "https://recept.se/recept/$slug" | grep ',"recipeIngredient":\[' | sed  -r 's/.*,"recipeIngredient":\[([^]]*)\].*/\1/' | awk  'BEGIN{ FS = "\",\"" } { for (i=1;i<=NF;i++) { print $i }}' | sed 's/"//' >> "${FILENAME}"
	echo -e "\nINSTRUCTIONS\n" >> "${FILENAME}"
	INSTRUCTIONS_JSON=$(curl "https://recept.se/recept/$slug" 2> /dev/null | grep -o "^.*instructions=.*$" | sed s/':instructions='// | sed s/'&quot;'/'"'/g | sed s/'^"'/""/ | sed s/'"$'/""/ )
  	# echo "$INSTRUCTIONS_JSON" | jq .[0]
	STEPS_NR=$(echo "$INSTRUCTIONS_JSON" | jq .[0] | grep -o "instruction" | wc -l)
	# echo "Found ${STEPS_NR}"
	let "STEPS_NR -= 1"
	for STEP in $(seq 0 $STEPS_NR)
	do
		echo "$INSTRUCTIONS_JSON" | jq .[0].instructions[$STEP] >> "${FILENAME}"
	done
done

rm slugs.tmp titles.tmp

