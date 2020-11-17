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
	jsonData=$(curl -s "https://recept.se/recept/$slug" | grep -o '<script type="application/ld+json">.*</script>' | grep -o '\{.*\}')
	echo "$jsonData" | jq

	# TODO: format ingredients and instructions, and write to $FILENAME
done

rm slugs.tmp titles.tmp tmp.tmp

