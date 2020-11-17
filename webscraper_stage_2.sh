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

grep "^:slug" result.txt | sort | uniq  > slugs.tmp # Isolate all slugs to a separate file
grep "^:title" result.txt | sort | uniq > titles.tmp # Isolate all titles to a separate file

# recept will contain all the recipes, each in a textfile
mkdir recept

# :slug example: surdegsbrod-med-dinkel
echo "Grep found $(wc -l slugs.tmp) slugs"

# Saves number of total recipes to a variable. By design, `wc -l titles.tmp` will return the same
# number.
TOTAL_RECIPES=$(wc -l slugs.tmp | cut -d" " -f 1)


# Loops through each recipe from $slugs.tmp and titles.tmp
#
# This works because titles.tmp and slugs.tmp have the same order (see comments on webscraper stage
# 1 for more info).
#
# the $line loop-variable is the line number to fetch from each tmp file.
#
# Note: `sed "$Nq;d" $FILE` returns only line nr. $N from $FILE. So we use it inside the next for
#       loop to get line nr. $line on each iteration from both slugs.tmp and titles.tmp.
for line in $(seq 1 ${TOTAL_RECIPES})
do

	# Sets the slug of the recipe as filename
	FILENAME=./recept/$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g)
	TITLE=$(sed "${line}q;d" titles.tmp)
	touch "${FILENAME}"
	# Write the title to $FILENAME, and a separator for the ingredients' list
	echo -e "${TITLE}" | sed s/':title="'// | sed s/'"$'// > "${FILENAME}"
	echo -e "===INGREDIENTS===\n" >> "${FILENAME}"
	# Remove quotation marks (both " and ') from our slug, as well as the prefix ':slug='
	slug=$(sed "${line}q;d" slugs.tmp | sed s/"'"//g | sed s/'"'//g | sed s/":slug="//g )
	# Printing the slug we're processing for debugging
	echo $slug

	# Curls microdata in Json from the $slug, and greps it to remove unneeded tags
	jsonData=$(curl -s "https://recept.se/recept/$slug" | grep -o '<script type="application/ld+json">.*</script>' | grep -o '\{.*\}')
	# Changing IFS to easily parse by line instead of by word
	IFS="
"
	# For each line it fetches the ingredients data ,formats it with the help of `jq` and write it to $FILENAME
	for LINE in $(echo "$jsonData" | jq .recipeIngredient | jq .[]); do echo $LINE | sed s/'"'//g >> "${FILENAME}"; done
	
	echo -e "\n===INSTRUCTIONS===\n" >> "${FILENAME}"
	
	# For each line it fetches the instructions data ,formats it with the help of `jq` and write it to $FILENAME
	for LINE in $(echo "$jsonData" | jq .recipeInstructions.itemListElement | jq .[]); do echo $LINE | sed s/'"'//g >> "${FILENAME}"; done

done

# Cleanup temporary files
rm slugs.tmp titles.tmp

