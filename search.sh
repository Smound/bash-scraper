#!/bin/bash

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

rm search.tmp
