##################################
### OLD WRANGLE MIHC DATA INFO ###
##################################

### The initial output of the mIHC pipeline is a table of cell counts. 
### There's one column per cell type
### Each row is a unique sample
### Often there will be multiple ROIs for a given sample

### Samples are generally named in the format: PREFIX_[0-9]+ROI[0-9]+
### Prefix is some string describing the source material
### First [0-9]+ is the patient identifier
### Second [0-9]+ is the ROI number

### In addition to the counts file, we have:

### A metadata file
### Must contain an Area column to use for density calculations
### Must contain same ID column as counts
### Optionally can contain other metadata entries

### Color File (not used here)
### Must have a column whose entries match column names of count data
### Must have column containing hex codes for each population

### Gating/Graphing Config (not used here)
### Must have same populations as count data
### Extra columns each specify a graph to plot, format is plotType_Graph.Name
### examples are: stacked_Global.Composition
###               sunburst_Immune.Proliferation
### Entries for a given column are numbers indicating the plotting order

### For downstream plots, we want to do the following:
### 1. Convert all cell counts to densities (by dividing by area)
### 2. Collapse multiple ROIs from a single patient into a patient average

###
### INSTRUCTIONS
###

### 1. Locate the fxns.R script and make sure the source call below is correct 
### 2. Determine your directory structure and make it fit this script or adjust this script.
### This script is set up for the following structure:
### baseDir_v - main project directory that contains everything else
### dataDir_v - sub-directory of baseDir_v that contains the reference files (e.g. metadata, color codes, etc.)
### funcDir_v - sub-directory of baseDir_v that contains the output of Sam's gating script.

### For the testing project, this would be:
### baseDir_v: Coussens-secure/Multiplex_IHC_studies/SMMART/AMTEC_restains_Jan2021/AMTEC_2023/
### dataDir_v: Coussens-secure/Multiplex_IHC_studies/SMMART/AMTEC_restains_Jan2021/AMTEC_2023/scripts
### funcDir_v: Coussens-secure/Multiplex_IHC_studies/SMMART/AMTEC_restains_Jan2021/AMTEC_2023/AMTEC2023_CSV/FunctionalCounts_CSV

### 3. Change the project name to the apropriate name.

### 4. Run this script, confirm outputs, then run generateReports.R

###
### AMTEC RESTAIN
###

# ### Paths
# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/AMTECrestain/"
# dataDir_v <- file.path(baseDir_v, "data")
# 
# dataFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_studycounts.csv")
# metaFile_v <- file.path(dataDir_v, "AMTEC2023March_metadata.xlsx")
# funcDir_v <- "AMTEC_march2023_CSV/FunctionalCounts_CSV"
# 
# ### Name
# name_v <- "AMTEC2023March_V2"


###
### Cell Death Panel - Zar 2023
###

# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/zar/"
# dataDir_v <- file.path(baseDir_v, "data")
# dataFile_v <- file.path(dataDir_v, "ZarCellDeath2023_V1_studycounts.csv")
# metaFile_v <- file.path(dataDir_v, "ZarCellDeath2023_Metadata.xlsx")
# colorFile_v <- file.path(dataDir_v, "ZarCellDeath2023_colorcodes.xlsx")
# gatingFile_v <- file.path(dataDir_v, "ZarCellDeath2023_gatingConfig.csv")
# funcDir_v <- "CSV/FunctionalCounts_CSV"
# name_v <- "ZarCellDeath2023"

###
### Zuz
###

# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/MdR01/"
# dataDir_v <- file.path(baseDir_v, "data")
# dataFile_v <- file.path(dataDir_v, "MdR01_V1_studycounts.csv")
# metaFile_v <- file.path(dataDir_v, "MdR01_Metadata.xlsx")
# colorFile_v <- file.path(dataDir_v, "MdR01_colorcodes.xlsx")
# gatingFile_v <- file.path(dataDir_v, "MdR01_gatingConfig.csv")
# funcDir_v <- "CSVs/FunctionalCounts_CSV"
# name_v <- "MdR01"


#################################
### OLD GENERATE REPORTS INFO ###
#################################

### For each patient, we need to make a report containing all of the important graphs.
### This script reads in the list of patients to make reports for, and then calls
### the RMarkdown reporting script, providing it with the patient ID to use.

###
### Instructions
###

### 1. Make sure wrangleCounts.R has been successfully run
### 2. Update the Dir_v variables to match project.
### baseDir_v should be same as wrangleCounts
### inDir_v should be same as dataDir_v of wrangleCounts
### outDir_v is the directory that you want the reports to be written to.

### 3. Double check the file names as well as the contents of metadata, colorcodes, etc.
### Each file should start with name_v
### It's important that there is a color entry for each population
### If the results are weird, colors missing, etc. Also double check the spelling and capitalization of the populations in each file

### 4. Make sure sample assignment is correct column as this will change between projects.

### 5. Make sure the location of mIHC_Report.Rmd is correct

### 6. Run.


###
### New Test Stuff ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

###
### Generate Reports
###

### Testing
# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/"
# inDir_v <- file.path(baseDir_v, "data")
# outDir_v <- mkdir(baseDir_v, "reports")
# name_v <- "MdR01"
# cohort_v <- F
# uniqCol_v <- "Tumor_ID"
# origMetaCols_v <- 'Tumor_ID'
# idCol_v <- "origTumorID"
# markdown_v <- "~/my_tool_repos/mIHC/scripts/mIHC_Report.Rmd" 

###
### mIHC_Report.Rmd
###

### New Test
# pt_v <- 137
# prj_v <- "AMTEC2023March_V2"
# cell_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC//data/AMTEC2023March_V2_slideAvg_cellDensity.csv")
# func_lsdt <- readAllExcel("/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC//data/AMTEC2023March_V2_slideAvg_funcDensity.xlsx")
# meta_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC//data/AMTEC2023March_V2_metadata.xlsx")
# color_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC//data/AMTEC2023March_V2_colorcodes.xlsx")
# config_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC//data/AMTEC2023March_V2_gatingConfig.csv")
# idCol_v <- "AMTEC ID"
# uniqCol_v <- "Slide"
# metaCols_v <- strsplit('Slide,AMTEC ID,timepoint', split = ",")[[1]]

### New Zar Test
# pt_v <- NULL
# prj_v <- "ZarCellDeath2023"
# cell_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_slideAvg_cellDensity.csv")
# func_lsdt <- readAllExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_slideAvg_funcDensity.xlsx")
# meta_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_metadata.xlsx")
# color_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_colorcodes.xlsx")
# config_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_gatingConfig.csv")
# idCol_v <- "Tumor"
# uniqCol_v <- "Tumor"
# metaCols_v <- strsplit('Tumor', split = ",")[[1]]

### New MdR01 Test
# pt_v <- "L12"
# prj_v <- "MdR01"
# cell_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/data/MdR01_slideAvg_cellDensity.csv")
# func_lsdt <- readAllExcel("/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/data/MdR01_slideAvg_funcDensity.xlsx")
# meta_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/data/MdR01_metadata.xlsx")
# color_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/data/MdR01_colorcodes.xlsx")
# config_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/data/MdR01_gatingConfig.csv")
# idCol_v <- "origTumorID"
# uniqCol_v <- "Tumor_ID"
# metaCols_v <- strsplit('Tumor_ID', split = ",")[[1]]

###
### Wrangle Counts
###

### Testing
# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/"
# dataDir_v <- file.path(baseDir_v, "data")
# dataFile_v <- file.path(dataDir_v, "MdR01_studycounts.csv")
# metaFile_v <- file.path(dataDir_v, "MdR01_metadata.xlsx")
# colorFile_v <- file.path(dataDir_v, "MdR01_colorcodes.xlsx")
# gatingFile_v <- file.path(dataDir_v, "MdR01_gatingConfig.csv")
# funcDir_v <- file.path(baseDir_v, "CSV/FunctionalCounts_CSV")
# name_v <- "MdR01"
# uniqCol_v <- "Sample_ID"
# sampleCol_v <- "Sample_ID"
# splitCol_v <- "ROI"
# splitLabs_v <- c("Tumor_ID", "ROI")
# by_v <- "Sample_ID"
# getCols_v <- c("Sample_ID", "Tumor_ID")
# mergeCol_v <- "Sample_ID"
# excludeCols_v <- NULL
# subByMeta_v <- F


### Amtec Test
# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC/"
# dataDir_v <- file.path(baseDir_v, "data")
# dataFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_studycounts.csv")
# metaFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_metadata.xlsx")
# colorFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_colorcodes.xlsx")
# gatingFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_gatingConfig.csv")
# funcDir_v <- "CSV/FunctionalCounts_CSV"
# name_v <- "AMTEC2023March_V2"
# uniqCol_v <- "Slide"
# sampleCol_v <- "Sample_ID"
# splitCol_v <- "ROI"
# splitLabs_v <- c("Slide", "ROI")
# # by_v <- "Sample_ID"
# by_v <- "Slide"
# # getCols_v <- c("Sample_ID", "Tumor_ID")
# getCols_v <- c("Sample_ID", "Slide")
# excludeCols_v <- NULL
# mergeCol_v <- "Sample_ID"




### New new Wrangle test

# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC/"
# name_v <- "AMTEC2023March_V2"

# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/newTests/zar/"
# name_v <- "ZarCellDeath2023"

# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/newTests/MdR01/"
# name_v <- "MdR01"
# 
# dataDir_v <- file.path(baseDir_v, "data")
# funcDir_v <- file.path(baseDir_v, "CSV/FunctionalCounts_CSV")
# dataFile_v <- file.path(dataDir_v, paste0(name_v, "_studycounts.csv"))
# metaFile_v <- file.path(dataDir_v, paste0(name_v, "_metadata.xlsx"))
# colorFile_v <- file.path(dataDir_v, paste0(name_v, "_colorcodes.xlsx"))
# gatingFile_v <- file.path(dataDir_v, paste0(name_v, "_gatingConfig.csv"))
# idCol_v <- "Sample_ID"
# sampleCol_v <- "sampleName"
# excludeCols_v <- NULL
# metaCol_v <- "sampleName"
# subByMeta_v <- T



### New New report test

### New Zar Test
reportID_v <- "cohort"
prj_v <- "ZarCellDeath2023"
cell_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_slideAvg_cellDensity.csv")
func_lsdt <- readAllExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_slideAvg_funcDensity.xlsx")
meta_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_metadata.xlsx")
color_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_colorcodes.xlsx")
config_dt <- readCSVOrExcel("/Volumes/wrh_padlock3/projects/SS/newTests/zar/data/ZarCellDeath2023_gatingConfig.csv")


### New stuff
idCol_v <- "Sample_ID"
sampleCol_v <- "sampleName"
reportCol_v <- "reportID"