#!/bin/bash

### Set scripts
CODEDIR="~/my_tool_repos/mIHC/scripts"
WRANGLE="$CODEDIR/wrangleCounts.R"

### Set other
DIR="/Volumes/wrh_padlock3/projects/SS/newTests"

### AMTEC
amtec="$WRANGLE \
	--baseDir $DIR/AMTEC \
	--dataDir data \
	--funcDir CSV/FunctionalCounts_CSV \
	--dataFile _studycounts.csv \
	--metaFile _metadata.xlsx \
	--colorFile _colorcodes.xlsx \
	--gatingFile _gatingConfig.csv \
	--name AMTEC2023March_V2 \
	--uniqueCol Slide \
	--sampleCol Sample_ID \
	--splitCol ROI \
	--splitLabs 'Slide,ROI' \
	--by Slide \
	--getCols 'Sample_ID,Slide' \
	--mergeCol Sample_ID"

#echo $amtec
#eval $amtec

### Cell Death
cellDeath="$WRANGLE \
	--baseDir $DIR/zar \
	--dataDir data \
	--funcDir CSV/FunctionalCounts_CSV \
	--dataFile _studycounts.csv \
	--metaFile _metadata.xlsx \
	--colorFile _colorcodes.xlsx \
	--gatingFile _gatingConfig.csv \
	--name ZarCellDeath2023 \
	--uniqueCol Tumor \
	--sampleCol Sample_ID \
	--splitCol ROI \
	--splitLabs 'Slide,Sample' \
	--by Tumor \
	--getCols 'Sample_ID,Tumor' \
	--mergeCol Sample_ID \
	--metaCol Tumor \
	--subByMeta T"

#echo $cellDeath
#eval $cellDeath

### MdR01 - orig version
mdr01="$WRANGLE \
	--baseDir $DIR/MdR01 \
	--dataDir data \
	--funcDir CSV/FunctionalCounts_CSV \
	--dataFile _studycounts.csv \
	--metaFile _metadata.xlsx \
	--colorFile _colorcodes.xlsx \
	--gatingFile _gatingConfig.csv \
	--name MdR01 \
	--uniqueCol Sample_ID \
	--sampleCol Sample_ID \
	--splitCol ROI \
	--splitLabs 'Tumor_ID,ROI' \
	--by Sample_ID \
	--getCols 'Sample_ID,Tumor_ID' \
	--mergeCol Sample_ID"

echo $mdr01
eval $mdr01
