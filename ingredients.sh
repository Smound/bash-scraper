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
done

# TODO : gör samma sak som "ingredients" fast för beskrivingen.

rm slugs.tmp titles.tmp

