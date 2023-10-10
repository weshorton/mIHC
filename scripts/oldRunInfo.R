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