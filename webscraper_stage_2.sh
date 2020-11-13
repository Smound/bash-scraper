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
	echo -e "${TITLE}\n\n" | sed s/':title="'// | sed s/'"$'// > "${FILENAME}"

	slug=$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g )
	echo $slug
	curl -s "https://recept.se/recept/$slug" | grep ',"recipeIngredient":\[' | sed  -r 's/.*,"recipeIngredient":\[([^]]*)\].*/\1/' | awk  'BEGIN{ FS = "\",\"" } { for (i=1;i<=NF;i++) { print $i }}' | sed 's/"//' | sed s/'\\u00e5'/"å"/g | sed s/'\\u00f6'/"ö"/g | sed s/'\\u00e4'/"ä"/g | sed s/'\u00e9'/"é"/g | sed s/'\u2019'/"'"/g  | sed s/'\\u00e2'/'á'/g | sed s/'\\u00bd'/'1\/2'/g >> "${FILENAME}"
	echo -e "\nINSTRUCTIONS\n" >> "${FILENAME}"
	INSTRUCTIONS_JSON=$(curl "https://recept.se/recept/$slug" 2> /dev/null | grep -o "^.*instructions=.*$" | sed s/':instructions='// | sed s/'&quot;'/'"'/g | sed s/'^"'/""/ | sed s/'"$'/""/ )
	echo "$INSTRUCTIONS_JSON" | jq .[].instructions | jq .[].instruction > tmp.tmp
	while read line
	do
	    echo -e "$line\n\n" | sed s/'^"'// | sed s/'"$'// >> "${FILENAME}"
	done < tmp.tmp
done

rm slugs.tmp titles.tmp tmp.tmp

