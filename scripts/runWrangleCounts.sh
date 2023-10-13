#!/bin/bash

### Set scripts
CODEDIR="~/my_tool_repos/mIHC/scripts"
WRANGLE="$CODEDIR/wrangleCounts.R"

### Set other
DIR="/Volumes/wrh_padlock3/projects/SS/newTests"

### AMTEC
amtec="$WRANGLE \
	--baseDir $DIR/AMTEC \
	--name AMTEC2023March_V2"

#echo $amtec
#eval $amtec

### Cell Death
cellDeath="$WRANGLE \
	--baseDir $DIR/zar \
	--name ZarCellDeath2023 \
	--metaCol Tumor \
	--subByMeta T"

#echo $cellDeath
#eval $cellDeath

### MdR01 - orig version
mdr01="$WRANGLE \
	--baseDir $DIR/MdR01 \
	--name MdR01 \
	--metaCol sampleName
	--subByMeta T"

echo $mdr01
eval $mdr01
