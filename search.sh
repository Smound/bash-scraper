#!/bin/bash
#
# A web scraper written in bash.
#
# This is a utility script to easily search through the scraped
# recipes.
#
# It allows 2 different "modes" of searching: Recept and Ingrediens.
#
# RECEPT MODE: will search only in recipes' titles.
#
# INGREDIENS MODE: will search among all the recipe's text, including
#                  ingredients' list and instructions. Useful for
#                  getting a broader result list (test searching in
#                  this mode for "ägg", "mjölk", "socker" or any other
#                  very common ingredient).
#
# This script accepts regexps as query strings. One example of why
# regexps are needed, is the following: if you search for "ägg",
# you'll get also recipes that do not contain "äggs", but that contain
# the word "lägg". If you search for "\\Wägg\\W" you get only results
# containing the word "ägg".
#

PS3="Välj vad du vill söka efter:"
options=(Recept Ingrediens)

#Titel
echo "-----------------------------"
echo "Välkommen till Receptscrapern!"
echo "-----------------------------"


#Menyn
select menu in "${options[@]}";
do
  echo -e "\nDu valde $menu ($REPLY)"
  echo -e "\n-------------------"

  if [ $menu == Recept ]; then
      #statements
      echo "Skriv in ett recept!"
      read varstarters
      echo "Söker efter $varstarters"
      # find  -iname "$varstarters*"
      for FILE in $(ls recept)
      do
	  echo "$FILE":"$(head -1 recept/$FILE)"
      done | grep -iE "$varstarters" > search.tmp
      
      IFS="
"
      PS3="Vilken recept vill du se? "
      select RECEPT in $(for line in "$(cat search.tmp)"
			 do
			     echo "$line" | cut -d":" -f2
			 done)
      do
	  FILENAME=$(cat search.tmp | grep "$RECEPT" | cut -d":" -f1)
	  echo -e "\n\n==========\n"
	  cat recept/$FILENAME
	  echo -e "\n\n"
	  break
      done
      
  else
      echo "Skriv in en Ingrediens!"
      read varstarters
      
      echo "Söker efter $varstarters"
      for FILE in $(ls recept)
      do
	  LINES_NR=$(wc -l "recept/$FILE")
	  INSTRUCTION_LINE=$(grep -nE "^INSTRUCTIONS" "recept/$FILE" | cut -d ":" -f 1)
	  let "INSTRUCTION_LINE -= 1"
	  cat recept/"$FILE" | head -n ${INSTRUCTION_LINE} | grep -iE "$varstarters" 2>&1 > /dev/null
	  if [ $? -eq 0 ]
	  then
	      echo -n "$FILE:" >> search.tmp
	      echo "$(head -1 recept/$FILE)" >> search.tmp
	  fi
      done
      
      IFS="
"     
      PS3="Vilken recept vill du se? "
      select RECEPT in $(for line in "$(cat search.tmp)"
			 do
			     echo "$line" | cut -d":" -f2
			 done)
      do
	  FILENAME=$(cat search.tmp | grep "$RECEPT" | cut -d":" -f1)
	  echo -e "\n\n==========\n"
	  cat recept/$FILENAME
	  echo -e "\n\n"
	  break
      done
      
  fi
  break;
done

# Cleanup temporary file
rm search.tmp
