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
    default = "_V1_studycounts.csv",
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
    default = "colorcodes.xlsx",
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
    c("-u", "--uniqueCol"),
    type = "character",
    help = "Column name to set unique sample identity for aggregation. So far have seen 'Slide' for amtec, 'Tumor' for Zar, and 'Sample_ID' for Mdr01"
  )
)

### Parse command line
p <- OptionParser(usage = "%proj -b baseDir -d dataDir -F funcDir -f dataFile -m metaFile -c colorFile -g gatingFile -n name -u uniqueCol",
                  option_list = optlist)
args <- parse_args(p)
opt <- args$options

### Assign to variables
baseDir_v <- args$baseDir
dataDir_v <- file.path(baseDir_v, args$dataDir)
funcDir_v <- file.path(baseDir_v, args$funcDir)
dataFile_v <- file.path(dataDir_v, args$dataFile)
metaFile_v <- file.path(dataDir_v, args$metaFile)
colorFile_v <- file.path(dataDir_v, args$colorFile)
gatingFile_v <- file.path(dataDir_v, args$gatingFile)
name_v <- args$name
uniqCol_v <- args$uniqueCol

### Handle alternative arguments for file names.
dataFile_v <- ifelse(file.exists(dataFile_v), dataFile_v,
                     file.path(baseDir_v, paste0(name_v, args$dataFile)))

metaFile_v <- ifelse(file.exists(metaFile_v), metaFile_v,
                     file.path(baseDir_v, paste0(name_v, args$metaFile)))

colorFile_v <- ifelse(file.exists(colorFile_v), colorFile_v,
                     file.path(baseDir_v, paste0(name_v, args$colorFile)))

gatingFile_v <- ifelse(file.exists(gatingFile_v), gatingFile_v,
                     file.path(baseDir_v, paste0(name_v, args$gatingFile)))


###
### Study Counts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Testing
baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/MdR01/"
dataDir_v <- file.path(baseDir_v, "data")
dataFile_v <- file.path(dataDir_v, "MdR01_V1_studycounts.csv")
metaFile_v <- file.path(dataDir_v, "MdR01_Metadata.xlsx")
colorFile_v <- file.path(dataDir_v, "MdR01_colorcodes.xlsx")
gatingFile_v <- file.path(dataDir_v, "MdR01_gatingConfig.csv")
funcDir_v <- "CSVs/FunctionalCounts_CSV"
name_v <- "MdR01"

###
### Load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Read in data, meta, colors, and gating
data_dt <- readCSVOrExcel(dataFile_v)
meta_dt <- readCSVOrExcel(metaFile_v)
colors_dt <- readCSVOrExcel(colorFile_v)
gate_dt <- readCSVOrExcel(gatingFile_v)


### CAREFUL!!!!!
### On at least one run there were two monocyte columns and we needed to combine them.
### Be sure to check if this affects you
monoCols_v <- which(colnames(data_dt) == "Monocytes")
if (length(monoCols_v) > 1) {
  cat(sprintf("More than one monocyte column found. Adding cell counts together into one column.\n"))
  monoCount_v <- rowSums(data_dt[,monoCols_v,with=F])
  data_dt$Monocytes <- NULL
  data_dt$Monocytes <- monoCount_v
}

### Add columns to metadata
if (!"Prefix" %in% colnames(meta_dt)) meta_dt[,Prefix := gsub("_.*$", "", Sample_ID)]
if (!"Sample_ID" %in% colnames(meta_dt)) stop("Sample_ID not found and no replacement")
if (!"ROI" %in% colnames(meta_dt)) meta_dt[,ROI := gsub("^.*ROI0|^.*ROI|\\..*$", "", Sample_ID)]

### For MdR01 project, have to add new tumor ID and also remove meta.data sample ID file extension
if (name_v == "MdR01") {
  if (!"fullTumorID" %in% colnames(meta_dt)) {
    meta_dt$fullTumorID <- meta_dt$`Tumor_ID`
    colnames(meta_dt) <- gsub(" ", "_", colnames(meta_dt))
    meta_dt[,Tumor_ID := gsub("T$|B$|L$|R$|-", "", Tumor_ID)]
    meta_dt[, Sample_ID := gsub("\\..*$", "", Sample_ID)]
  } # fi
} # fi

###
### Check ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

# Check sample names and pop IDs between files

### Data and meta sample IDs
missingSamples_lsv <- list("meta" = setdiff(data_dt$Sample_ID, meta_dt$Sample_ID),
                           "data" = setdiff(meta_dt$Sample_ID, data_dt$Sample_ID))
invisible(sapply(names(missingSamples_lsv), function(x) {
  if (length(missingSamples_lsv[[x]]) > 0) {
    warning(sprintf("Missing %s samples from %s. Check inputs!\n", length(missingSamples_lsv[[x]]), x))
}}))

### Gating Populations
gatingPops_v <- gate_dt[Class != "Functional", Class]
gatingFxnl_v <- gsub("^Areap_|p$", "", gate_dt[Class == "Functional", Gate])

### Check Gating against colors
missingColorPops_v <- setdiff(gatingPops_v, colors_dt$Population)
missingColorFxnl_v <- setdiff(gatingFxnl_v, colors_dt$Population)

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

### Write out again with updated info
if (file_ext(metaFile_v) == "csv") {
  write.table(meta_dt, metaFile_v)
} else if (file_ext(metaFile_v) == "xlsx") {
  writexl::write_xlsx(meta_dt, metaFile_v)
} 

###
### Convert to Densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

density_dt <- calcDensity(data_dt = data_dt, meta_dt = meta_dt, areaCol_v = "Area", idCol_v = "Sample_ID", metaCols_v = NULL)

###
### Average By Slide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### TO DO - MAKE THESE SPLIT LABS, MERGE COLS, ETC. NON-HARDCODED

### ### Right now can only one on run prefix (shouldn't ever have two anyway I think)
prefix_v <- paste0(unique(meta_dt$Prefix), "_")
if (length(prefix_v) > 1)  stop("Multiple different prefixes")

avgDens_dt <- averageROIs(data_dt = density_dt, sampleCol_v = "Sample_ID", prefix_v = prefix_v,
                          split_v = "ROI", splitLabs_v = c("Tumor_ID", "ROI"), by_v = "Sample_ID", metaCols_v = NULL,
                          meta_dt = meta_dt[,mget(c("Sample_ID", "Tumor_ID"))], mergeCol_v = "Sample_ID")

avgCount_dt <- averageROIs(data_dt = data_dt, sampleCol_v = "Sample_ID", prefix_v = prefix_v,
                          split_v = "ROI", splitLabs_v = c("Tumor_ID", "ROI"), by_v = "Sample_ID", metaCols_v = NULL,
                          meta_dt = meta_dt[,mget(c("Sample_ID", "Tumor_ID"))], mergeCol_v = "Sample_ID")

### TEMPORARY!!! one of the cell labels is misspelled. Rather than re-run the whole gating, just going to fix it here
# colnames(avgDens_dt)[which(colnames(avgDens_dt) == "Ki67+ Tumor Cells")] <- "KI67+ Tumor Cells"
# colnames(avgCount_dt)[which(colnames(avgCount_dt) == "Ki67+ Tumor Cells")] <- "KI67+ Tumor Cells"

###
### Write out average densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

write.table(avgDens_dt,
            file = file.path(dataDir_v, paste0(name_v, "_slideAvg_cellDensity.csv")),
            sep = ",", quote = F, row.names = F)

write.table(avgCount_dt,
            file = file.path(dataDir_v, paste0(name_v, "_slideAvg_cellCount.csv")),
            sep = ",", quote = F, row.names = F)


###
### Functional Counts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

###
### Load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Read in functional counts
functional_lsdt <- readDir(dir_v = file.path(baseDir_v, funcDir_v), pattern_v = "*.csv")

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
  out <- calcDensity(data_dt = y, meta_dt = z, areaCol_v = "Area", idCol_v = "Class", metaCols_v = NULL)
}, simplify = F)

###
### Average By Slide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Get unique IDs to average (slide is original, added Tumor for Zar)
uniq_v <- avgDens_dt[[uniqCol_v]]

### Average density for each
avgFD_lsdt <- sapply(uniq_v, function(x) functionalAverageROIs(functionalDensity_lsdt, id_v = x, col_v = "Class"),
                    simplify = F, USE.NAMES = T)

### Average counts for each
avgF_lsdt <- sapply(uniq_v, function(x) functionalAverageROIs(functional_lsdt, id_v = x, col_v = "Class"),
                    simplify = F, USE.NAMES = T)

###
### Write out average counts and densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

myOpenXWriteWkbk(data_ls = avgFD_lsdt, file_v = file.path(dataDir_v, paste0(name_v, "_slideAvg_funcDensity.xlsx")))
myOpenXWriteWkbk(data_ls = avgF_lsdt, file_v = file.path(dataDir_v, paste0(name_v, "_slideAvg_funcCount.xlsx")))