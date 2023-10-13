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
	--dataDir data \
	--outDir reports \
	--name AMTEC2023March_V2 \
	--cohort F \
	--idCol 'AMTEC ID' \
	--uniqCol 'Slide' \
	--metaCols 'Slide,AMTEC ID,timepoint' \
	--markdown $MARKDOWN"

#echo $amtec
eval $amtec

### Cell Death
cellDeath="$REPORT \
	--baseDir $DIR/zar \
	--dataDir data \
	--outDir reports \
	--name ZarCellDeath2023 \
	--cohort T \
	--idCol 'Tumor' \
	--uniqCol 'Tumor' \
	--metaCols 'Tumor' \
	--markdown $MARKDOWN"

#echo $cellDeath
#eval $cellDeath

## MdR01
mdr01="$REPORT \
	--baseDir $DIR/MdR01 \
	--dataDir data \
	--outDir reports \
	--name MdR01 \
	--cohort F \
	--idCol 'origTumorID' \
	--uniqCol 'Tumor_ID' \
	--metaCols 'Tumor_ID' \
	--markdown $MARKDOWN"

#echo $mdr01
#eval $mdr01
