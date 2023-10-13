#!/usr/local/bin/Rscript

########################
### GENERATE REPORTS ###
########################

### For each patient, we need to make a report containing all of the important graphs.
### This script reads in the list of patients to make reports for, and then calls
### the RMarkdown reporting script, providing it with the patient ID to use.

### You can view the github page for more information.

###
### Dependencies ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Libraries
suppressMessages(library(wrh.rUtils))
libs_v <- c("readxl", "data.table", "ggplot2", "ggpubr", "tools", "openxlsx", "mIHC", "optparse")
loadLib(libs_v)

###
### Command Line ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Make option list
optlist <- list(
  make_option(
    c("-b", "--baseDir"),
    type = "character",
    help = "Full bath to base project directory"
  ),
  make_option(
    c("-d", "--dataDir"),
    type = "character",
    default = "data",
    help = "Relative path to data location within baseDir"
  ),
  make_option(
    c("-o", "--outDir"),
    type = "character",
    default = "reports",
    help = "Relative path to the directory where reports will be output"
  ),
  make_option(
    c("-i", "--idCol"),
    type = "character",
    help = "Column name from metadata file that separates samples. AMTEC - Slide"
  ),
  make_option(
    c("-n", "--name"),
    type = "character",
    help = "Project name. Used to load meta file, data files, gating file, etc. 
    The suffixes of these names are hardcoded within the script, but should be standardized after wrangleCounts run"
  ),
  make_option(
    c("-c", "--cohort"),
    type = "logical",
    default = F,
    help = "logical indicating if all samples should be run together or not."
  ),
  make_option(
    c("-u", "--uniqCol"),
    type = "character",
    help = "Column name that specifies unique samples. Used for subsetting"
  ),
  make_option(
    c("-M", "--metaCols"),
    type = "character",
    help = "Comma-sep no spaces list of columns from meta data that should be included in analysis."
  ),
  make_option(
    c("-m", "--markdown"),
    type = "character",
    default = "~/my_tool_repos/mIHC/scripts/mIHC_Report.Rmd",
    help = "Path to report markdown script. Will be wherever you downloaded the github repository."
  )
)

### Parse command line
p <- OptionParser(usage = "%proj -b baseDir -d dataDir -o outDir -i idCol -n name -c cohort -u uniqCol -M metaCols -m markdown",
                  option_list = optlist)
args <- parse_args(p)
opt <- args$options

### Assign to variables
baseDir_v <- args$baseDir
inDir_v <- file.path(baseDir_v, args$dataDir)
outDir_v <- mkdir(baseDir_v, args$outDir)
idCol_v <- args$idCol
name_v <- args$name
cohort_v <- args$cohort
uniqCol_v <- args$uniqCol
origMetaCols_v <- args$metaCols
markdown_v <- args$markdown

### Expand file paths
cellDensityFile_v <- file.path(inDir_v, paste0(name_v, "_slideAvg_cellDensity.csv"))
funcDensityFile_v <- file.path(inDir_v, paste0(name_v, "_slideAvg_funcDensity.xlsx"))
metaFile_v <- file.path(inDir_v, paste0(name_v, "_metadata.xlsx"))
colorFile_v <- file.path(inDir_v, paste0(name_v, "_colorcodes.xlsx"))
configFile_v <- file.path(inDir_v, paste0(name_v, "_gatingConfig.csv"))

### Read in meta
if (file_ext(metaFile_v) == "csv") {
  meta_dt <- fread(metaFile_v)
} else if (file_ext(metaFile_v) == "xlsx") {
  meta_dt <- as.data.table(read_excel(metaFile_v))
} else {
  stop("Only csv and xlsx are supported for metaFile_v")
}

if (!cohort_v) {
  
  ### Get samples
  samples_v <- unique(meta_dt[[idCol_v]])
  
  ### Generate report for each sample
  for (i in 1:length(samples_v)) {
    
    ### Get sample
    currSample_v <- samples_v[i]
    
    ### Run Markdown
    rmarkdown::render(markdown_v, 
                      params = list(pt = currSample_v,
                                    proj = name_v,
                                    cellFile = cellDensityFile_v,
                                    funcFile = funcDensityFile_v,
                                    metaFile = metaFile_v,
                                    colorFile = colorFile_v,
                                    configFile = configFile_v,
                                    idCol = idCol_v,
                                    uniqCol = uniqCol_v,
                                    metaCols = origMetaCols_v),
                      output_file = file.path(outDir_v, paste0(name_v, "_", currSample_v, ".html")))
  }

} else {
  
  rmarkdown::render(markdown_v, 
                    params = list(pt = NULL,
                                  proj = name_v,
                                  cellFile = cellDensityFile_v,
                                  funcFile = funcDensityFile_v,
                                  metaFile = metaFile_v,
                                  colorFile = colorFile_v,
                                  configFile = configFile_v,
                                  idCol = idCol_v,
                                  uniqCol = uniqCol_v,
                                  metaCols = origMetaCols_v),
                    output_file = file.path(outDir_v, paste0(name_v, "_cohort.html")))
  
} # fi