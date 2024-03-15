#!/bin/bash

# Adapted from: https://tex.stackexchange.com/questions/427622/importing-diagram-from-draw-io-into-latex

echo ------------------------- Converting drawio to PDF ------------------------------

COUNTERC=0
COUNTERU=0
COUNTERtot=0

for filename in ./*.drawio; do
  if [ -n "$(git status ${filename} --porcelain)" ]; then
    echo " 🔁 ${filename} changed, converting..."
    DUMMY=$(rm "${filename%.*}.pdf" 2>&1)
    DUMMY=$(/Applications/draw.io.app/Contents/MacOS/draw.io ${filename} --crop -x -o ${filename%.*}.pdf 2>&1)
    COUNTERC=$((COUNTERC+1))
  else
    echo " ⤵️  ${filename} hasnt changed, skipping..."
    COUNTERU=$((COUNTERU+1))
  fi
done

printf "\n✔ DONE converting"
COUNTERtot=$((COUNTERC+COUNTERU))
echo -e "\n$COUNTERtot total \t $COUNTERC changed \t $COUNTERU skipped"
