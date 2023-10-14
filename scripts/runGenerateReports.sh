#!/bin/bash

### Set scripts
CODEDIR="~/my_tool_repos/mIHC/scripts"
REPORT="$CODEDIR/generateReports.R"
MARKDOWN="$CODEDIR/mIHC_Report.Rmd"

### Set other
DIR="/Volumes/wrh_padlock3/projects/SS/newTests"

### AMTEC
amtec="$REPORT \
	--baseDir $DIR/AMTEC \
	--name AMTEC2023March_V2 \
	--markdown $MARKDOWN"

#echo $amtec
eval $amtec

### Cell Death
cellDeath="$REPORT \
	--baseDir $DIR/zar \
	--name ZarCellDeath2023 \
	--markdown $MARKDOWN"

#echo $cellDeath
#eval $cellDeath

## MdR01
mdr01="$REPORT \
	--baseDir $DIR/MdR01 \
	--name MdR01 \
	--markdown $MARKDOWN"

#echo $mdr01
#eval $mdr01
