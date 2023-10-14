#!/usr/local/bin/Rscript

#########################
### WRANGLE MIHC DATA ###
#########################

### View the github page readme for more information about the inputs to this script.

    
###
### Dependencies ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Libraries
suppressMessages(library(wrh.rUtils))
libs_v <- c("readxl", "data.table", "ggplot2", "tools", "openxlsx", "mIHC", "optparse")
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
    c("-F", "--funcDir"),
    type = "character",
    default = "CSV/FunctionalCounts_CSV",
    help = "Relative path to the directory of the functional counts."
  ),
  make_option(
    c("-f", "--dataFile"),
    type = "character",
    default = "_studycounts.csv",
    help = "Either the name of studycounts.csv file that will be found within dataDir, or the suffix that will be used with name argument to locate file"
  ),
  make_option(
    c("-m", "--metaFile"),
    type = "character",
    default = "_metadata.xlsx",
    help = "Either the name of metadata file found within dataDir, or the suffix that will be used with name argument"
  ),
  make_option(
    c("-c", "--colorFile"),
    type = "character",
    default = "_colorcodes.xlsx",
    help = "Either the name of color reference file found within dataDir, or the suffix that will be used with the name argument"
  ),
  make_option(
    c("-g", "--gatingFile"),
    type = "character",
    default = "_gatingConfig.csv",
    help = "Either the name of gating configuration file found within dataDir, or the suffix that will be used with the name argument."
  ),
  make_option(
    c("-n", "--name"),
    type = "character",
    help = "Project name"
  ),
  make_option(
    c("-i", "--idCol"),
    type = "character",
    default = "Sample_ID",
    help = "Column name that maps to other files and is a unique row identifier."
  ),
  make_option(
   c("-S", "--sampleCol") ,
   type = "character",
   default = "sampleName",
   help = "Column name to use for sample IDs for aggregation in averageROIs"
  ),
  make_option(
    c("-e", "--exlcludeCols"),
    type = "character",
    default = NULL,
    help = "Comma-sep, no spaces string of meta.data columns that might be present in data that need to be ignored."
  ),
  make_option(
    c("--metaCol"),
    type = "character",
    default = NULL,
    help = "Used if subsetting functional data list by a different ID than its names. Used in Cell Death so far."
  ),
  make_option(
    c("--subByMeta"),
    type = "logical",
    default = FALSE,
    help = "Logical indicating whether or not to subset functional data list by a meta.data column instead of its names. Used in Cell Death so far"
  )
)

### Parse command line
p <- OptionParser(usage = "%proj -b baseDir -d dataDir -F funcDir -f dataFile -m metaFile -c colorFile -g gatingFile -n name -i idCol
                  -S sampleCol -e excludeCols --metaCol --subByMeta",
                  option_list = optlist)
args <- parse_args(p)
opt <- args$options

### Assign to variables
baseDir_v <- args$baseDir
dataDir_v <- file.path(baseDir_v, args$dataDir)
funcDir_v <- file.path(baseDir_v, args$funcDir)
dataFile_v <- args$dataFile
metaFile_v <- args$metaFile
colorFile_v <- args$colorFile
gatingFile_v <- args$gatingFile
name_v <- args$name
idCol_v <- args$idCol
sampleCol_v <- args$sampleCol
excludeCols_v <- args$excludeCols
metaCol_v <- args$metaCol
subByMeta_v <- args$subByMeta

### Handle multiple column arguments
if (!is.null(excludeCols_v)) excludeCols_v <- splitComma(excludeCols_v)

### Handle alternative arguments for file names.
dataFile_v <- ifelse(file.exists(file.path(dataDir_v, dataFile_v)), file.path(dataDir_v, dataFile_v),
                     file.path(dataDir_v, paste0(name_v, args$dataFile)))

metaFile_v <- ifelse(file.exists(file.path(dataDir_v, metaFile_v)), file.path(dataDir_v, metaFile_v),
                     file.path(dataDir_v, paste0(name_v, args$metaFile)))

colorFile_v <- ifelse(file.exists(file.path(dataDir_v, colorFile_v)), file.path(dataDir_v, colorFile_v),
                     file.path(dataDir_v, paste0(name_v, args$colorFile)))

gatingFile_v <- ifelse(file.exists(file.path(dataDir_v, gatingFile_v)), file.path(dataDir_v, gatingFile_v),
                     file.path(dataDir_v, paste0(name_v, args$gatingFile)))


###
### Load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Read in data, meta, colors, and gating
data_dt <- readCSVOrExcel(dataFile_v)
meta_dt <- readCSVOrExcel(metaFile_v)
colors_dt <- readCSVOrExcel(colorFile_v)
gate_dt <- readCSVOrExcel(gatingFile_v)

###
### Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###


# Check sample names and pop IDs between files

### Data and meta sample IDs
missingSamples_lsv <- list("meta" = setdiff(data_dt[[idCol_v]], meta_dt[[idCol_v]]),
                           "data" = setdiff(meta_dt[[idCol_v]], data_dt[[idCol_v]]))
invisible(sapply(names(missingSamples_lsv), function(x) {
  if (length(missingSamples_lsv[[x]]) > 0) {
    warning(sprintf("Missing %s samples from %s. Check inputs!\n", length(missingSamples_lsv[[x]]), x))
}}))

### Gating Populations
gatingPops_v <- gate_dt[Class != "Functional", Class]
gatingFxnl_v <- gsub("^Areap_|p$", "", gate_dt[Class == "Functional", Gate])

### Color populations
colorPops_v <- colors_dt$Population

### Check Gating against colors
missingColorPops_v <- setdiff(gatingPops_v, colorPops_v)
missingColorFxnl_v <- setdiff(gatingFxnl_v, colorPops_v)

if (length(missingColorPops_v) > 0) {
  warning(sprintf("Missing %s pops in color file:\n%s\n", 
                  length(missingColorPops_v), paste(missingColorPops_v, collapse = "; ")))
}

if (length(missingColorFxnl_v) > 0) {
  warning(sprintf("Missing %s pops in color file:\n%s\n", 
                  length(missingColorFxnl_v), paste(missingColorFxnl_v, collapse = "; ")))
}

### Check gating against data
missingDataPops_v <- setdiff(gatingPops_v, colnames(data_dt))
missingDataFxnl_v <- setdiff(gatingFxnl_v, colnames(data_dt))

if (length(missingDataPops_v) > 0) {
  warning(sprintf("Missing %s pops in data file:\n%s\n", 
                  length(missingDataPops_v), paste(missingDataPops_v, collapse = "; ")))
}

if (length(missingDataFxnl_v) > 0) {
  warning(sprintf("Missing %s pops in data file:\n%s\n", 
                  length(missingDataFxnl_v), paste(missingDataFxnl_v, collapse = "; ")))
}

###
### Convert to Densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

density_dt <- calcDensity(data_dt = data_dt, 
                          meta_dt = meta_dt, 
                          areaCol_v = "Area", 
                          idCol_v = idCol_v, 
                          metaCols_v = excludeCols_v)

###
### Average By Slide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

avgDens_dt <- averageROIs(data_dt = density_dt,
                          meta_dt = meta_dt)

avgCount_dt <- averageROIs(data_dt = data_dt,
                          meta_dt = meta_dt)



### TEMPORARY!!! one of the cell labels is misspelled. Rather than re-run the whole gating, just going to fix it here
colnames(avgDens_dt)[which(colnames(avgDens_dt) == "Ki67+ Tumor Cells")] <- "KI67+ Tumor Cells"
colnames(avgCount_dt)[which(colnames(avgCount_dt) == "Ki67+ Tumor Cells")] <- "KI67+ Tumor Cells"

###
### Write out average densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

write.table(avgDens_dt,
            file = file.path(dataDir_v, paste0(gsub("_$", "", name_v), "_slideAvg_cellDensity.csv")),
            sep = ",", quote = F, row.names = F)

write.table(avgCount_dt,
            file = file.path(dataDir_v, paste0(gsub("_$", "", name_v), "_slideAvg_cellCount.csv")),
            sep = ",", quote = F, row.names = F)


###
### Functional Counts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

###
### Load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Read in functional counts
functional_lsdt <- readDir(dir_v = funcDir_v, pattern_v = "*.csv")

### Remove extra rowname column
functional_lsdt <- sapply(functional_lsdt, function(x) {
  if ("V1" %in% colnames(x)) x[["V1"]] <- NULL
  return(x)
}, simplify = F, USE.NAMES = T)

### Remove name prefix
names(functional_lsdt) <- gsub("FunctCounts_", "", names(functional_lsdt))

### Change class to Class
functional_lsdt <- sapply(functional_lsdt, function(x) {
  colnames(x)[colnames(x) == "class"] <- "Class"
  return(x)
}, simplify = F, USE.NAMES = T)

###
### Convert to Densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###


### In order for this to work with calcDensity, have to make a dummy metadata dt with an area for
### each cell type as if they were patient IDs.
functionalDensity_lsdt <- sapply(names(functional_lsdt), function(x) {
  y <- functional_lsdt[[x]]
  z <- data.table("Class" = y$Class, "Area" = rep(meta_dt[Sample_ID == x, Area], nrow(y))) 
  out <- calcDensity(data_dt = y, meta_dt = z, areaCol_v = "Area", idCol_v = "Class", metaCols_v = excludeCols_v)
}, simplify = F)


###
### Average By Slide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Get unique IDs to average 
uniq_v <- unique(meta_dt[[sampleCol_v]])

if (subByMeta_v) {
  fMeta_dt <- meta_dt
} else {
  fMeta_dt <- NULL
}

### Average density for each
avgFD_lsdt <- sapply(uniq_v, function(x) functionalAverageROIs(functionalDensity_lsdt, id_v = x, col_v = "Class",
                                                               meta_dt = fMeta_dt, metaCol_v = metaCol_v, sampleCol_v = idCol_v),
                    simplify = F, USE.NAMES = T)


### Average counts for each
avgF_lsdt <- sapply(uniq_v, function(x) functionalAverageROIs(functional_lsdt, id_v = x, col_v = "Class",
                                                              meta_dt = fMeta_dt, metaCol_v = metaCol_v, sampleCol_v = idCol_v),
                    simplify = F, USE.NAMES = T)

###
### Write out average counts and densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

myOpenXWriteWkbk(data_ls = avgFD_lsdt, file_v = file.path(dataDir_v, paste0(gsub("_$", "", name_v), "_slideAvg_funcDensity.xlsx")))
myOpenXWriteWkbk(data_ls = avgF_lsdt, file_v = file.path(dataDir_v, paste0(gsub("_$", "", name_v), "_slideAvg_funcCount.xlsx")))