#!/bin/bash
#
# A web scraper written in bash.
#
# This is stage 2, it will read names and URLs from the file
# result.txt (from stage 1), and actually scrape down the ingredients
# list and instructions for the recipe.
#
# Recipes will end up in textfiles under the directory ./recept/
#

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
	echo -e "${TITLE}" | sed s/':title="'// | sed s/'"$'// > "${FILENAME}"
	echo -e "===INGREDIENTS===\n" >> "${FILENAME}"

	slug=$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g )
	echo $slug
	jsonData=$(curl -s "https://recept.se/recept/$slug" | grep -o '<script type="application/ld+json">.*</script>' | grep -o '\{.*\}')
	IFS="
"
	for LINE in $(echo "$jsonData" | jq .recipeIngredient | jq .[]); do echo $LINE | sed s/'"'//g >> "${FILENAME}"; done
	echo -e "\n===INSTRUCTIONS===\n" >> "${FILENAME}"
	for LINE in $(echo "$jsonData" | jq .recipeInstructions.itemListElement | jq .[]); do echo $LINE | sed s/'"'//g >> "${FILENAME}"; done

	# TODO: format ingredients and instructions, and write to $FILENAME
done

rm slugs.tmp titles.tmp

