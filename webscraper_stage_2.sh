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

#Creates a folder "recept"
mkdir recept

#:slug example: surdegsbrod-med-dinkel
echo "Grep found $(wc -l slugs.tmp) slugs"

#Prints out number of total recipes
TOTAL_RECIPES=$(wc -l slugs.tmp | cut -d" " -f 1)


#Loops through each recipe from $slugs.tmp

for line in $(seq 1 ${TOTAL_RECIPES})
do

	#Sets the title of the recipe as filename
	FILENAME=./recept/$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g)
	TITLE=$(sed "${line}q;d" titles.tmp)
	touch "${FILENAME}"
	echo -e "${TITLE}" | sed s/':title="'// | sed s/'"$'// > "${FILENAME}"
	echo -e "===INGREDIENTS===\n" >> "${FILENAME}"

	slug=$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g )
	echo $slug

	#Curls and greps microdata in Json from the $slug
	jsonData=$(curl -s "https://recept.se/recept/$slug" | grep -o '<script type="application/ld+json">.*</script>' | grep -o '\{.*\}')
	IFS="
"
	#For each line it fetches the ingredients data ,formats it and write it to the file
	for LINE in $(echo "$jsonData" | jq .recipeIngredient | jq .[]); do echo $LINE | sed s/'"'//g >> "${FILENAME}"; done
	
	echo -e "\n===INSTRUCTIONS===\n" >> "${FILENAME}"
	
	#For each line it fetches the instructions data ,formats it and write it to the file
	for LINE in $(echo "$jsonData" | jq .recipeInstructions.itemListElement | jq .[]); do echo $LINE | sed s/'"'//g >> "${FILENAME}"; done

	
done

rm slugs.tmp titles.tmp

