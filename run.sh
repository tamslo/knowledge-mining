#!/bin/bash

color01="\033[0;36m"
color02="\033[1;36m"
noColor="\033[0m"

echo -e "$color01 \nProcessing dumps ... $noColor"
python scripts/processDumps.py
echo 'Done.'

echo -e "$color02 \nNow use the phpmyadmin import function with the all_tables.sql file."
echo -e "Press any key when it's done ...\n $noColor"
read -n 1 -s

echo -e "$color01 \nEvaluating dumps ...$noColor"
php scripts/evaluate.php
echo -e "\nDone."