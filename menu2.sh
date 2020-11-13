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
else
  echo "Skriv in en Ingrediens!"
  read varstarters
  echo "Söker efter $varstarters"
fi
  break;
done
