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
    help = "Column name to set unique sample identity for aggregation. So far have seen 'Sample_ID' for amtec, 'Tumor' for Zar, and 'Sample_ID' for Mdr01"
  ),
  make_option(
   c("--sampleCol") ,
   type = "character",
   default = "Sample_ID",
   help = "Column name to use for sample IDs for aggregation in averageROIs"
  ),
  make_option(
    c("-S", "--splitCol"),
    type = "character",
    default = "ROI",
    help = "Column name to split on? Need to update this."
  ),
  make_option(
    c("-l", "--splitLabs"),
    type = "character",
    default = 'Tumor_ID,ROI',
    help = "Column names to call the results of sampleCol splitting (Comma-sep, no spaces).
    AMTEC - 'Tumor_ID,ROI'
    Zar - 'Slide,Sample'"
  ),
  make_option(
    c("-B", "--by"),
    type = "character",
    default = "Sample_ID",
    help = "Column name to aggregate by."
  ),
  make_option(
    c("-G", "--getCols"),
    type = "character",
    default = 'Sample_ID,Tumor_ID',
    help = "Column names to grab from meta.data. (Comma-sep, no spaces).
    AMTEC - 'Sample_ID,Tumor_ID'
    Zar - 'Sample_ID,Tumor'"
  ),
  make_option(
    c("-M", "--mergeCol"),
    type = "character",
    default = "Sample_ID",
    help = "Column shared between data and meta to merge on."
  ),
  make_option(
    c("-e", "--exlcludeCols"),
    type = "character",
    default = NULL,
    help = "Comma-sep, no spaces string of meta.data columns that might be present in data that need to be ignored."
  )
)

### Parse command line
p <- OptionParser(usage = "%proj -b baseDir -d dataDir -F funcDir -f dataFile -m metaFile -c colorFile -g gatingFile -n name -u uniqueCol
                  --sampleCol -S splitCol -l splitLabs -B by -G getCols -M mergeCol -e excludeCols",
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
sampleCol_v <- args$sampleCol
splitCol_v <- args$splitCol
splitLabs_v <- args$splitLabs
by_v <- args$by
getCols_v <- args$getCols
mergeCol_v <- args$mergeCol
excludeCols_v <- args$excludeCols

### Handle multiple column arguments
if (!is.null(splitLabs_v)) splitLabs_v <- splitComma(splitLabs_v)
if (!is.null(getCols_v)) getCols_v <- splitComma(getCols_v)
if (!is.null(excludeCols_v)) excludeCols_v <- splitComma(excludeCols_v)

### Handle alternative arguments for file names.
dataFile_v <- ifelse(file.exists(dataFile_v), dataFile_v,
                     file.path(dataDir_v, paste0(name_v, args$dataFile)))

metaFile_v <- ifelse(file.exists(metaFile_v), metaFile_v,
                     file.path(dataDir_v, paste0(name_v, args$metaFile)))

colorFile_v <- ifelse(file.exists(colorFile_v), colorFile_v,
                     file.path(dataDir_v, paste0(name_v, args$colorFile)))

gatingFile_v <- ifelse(file.exists(gatingFile_v), gatingFile_v,
                     file.path(dataDir_v, paste0(name_v, args$gatingFile)))


###
### Study Counts ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

# ### Testing
# baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/MdR01/"
# dataDir_v <- file.path(baseDir_v, "data")
# dataFile_v <- file.path(dataDir_v, "MdR01_V1_studycounts.csv")
# metaFile_v <- file.path(dataDir_v, "MdR01_Metadata.xlsx")
# colorFile_v <- file.path(dataDir_v, "MdR01_colorcodes.xlsx")
# gatingFile_v <- file.path(dataDir_v, "MdR01_gatingConfig.csv")
# funcDir_v <- "CSVs/FunctionalCounts_CSV"
# name_v <- "MdR01"
# uniqCol_v <- "Sample_ID"

### Amtec Test
baseDir_v <- "/Volumes/wrh_padlock3/projects/SS/newTests/AMTEC/"
dataDir_v <- file.path(baseDir_v, "data")
dataFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_studycounts.csv")
metaFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_metadata.xlsx")
colorFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_colorcodes.xlsx")
gatingFile_v <- file.path(dataDir_v, "AMTEC2023March_V2_gatingConfig.csv")
funcDir_v <- "CSV/FunctionalCounts_CSV"
name_v <- "AMTEC2023March_V2"
uniqCol_v <- "Slide"
sampleCol_v <- "Sample_ID"
splitCol_v <- "ROI"
splitLabs_v <- c("Slide", "ROI")
# by_v <- "Sample_ID"
by_v <- "Slide"
# getCols_v <- c("Sample_ID", "Tumor_ID")
getCols_v <- c("Sample_ID", "Slide")
excludeCols_v <- NULL
mergeCol_v <- "Sample_ID"


###
### Load ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Read in data, meta, colors, and gating
data_dt <- readCSVOrExcel(dataFile_v)
meta_dt <- readCSVOrExcel(metaFile_v)
colors_dt <- readCSVOrExcel(colorFile_v)
gate_dt <- readCSVOrExcel(gatingFile_v)

### Make new file to save original metadata before altering it. Also check extension.
if (file_ext(metaFile_v) == "csv") {
  origMetaFile_v <- file.path(dataDir_v, "origMeta.csv")
} else if (file_ext(metaFile_v) == "xlsx") {
  origMetaFile_v <- file.path(dataDir_v, "origMeta.xlsx")
} else {
  stop("Meta file must be .csv or .xlsx\n")
} # fi

### If the origMetaFile is already run, we want to load that as meta_dt here
if (file.exists(origMetaFile_v)) {
  cat(sprintf("Wrangle has been run previously. Loading the original metadata file: %s\n", origMetaFile_v))
  cat(sprintf("This means that %s will be overwritten, so save it if you want to compare.\n", metaFile_v))
  meta_dt <- readCSVOrExcel(origMetaFile_v)
} else {
  cat(sprintf("Saving input meta to: %s\n", origMetaFile_v))
  if (file_ext(origMetaFile_v) == "csv") {
    write.table(meta_dt, origMetaFile_v)
  } else {
    writexl::write_xlsx(meta_dt, origMetaFile_v)
  }
}

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

### Add columns to metadata - change out sample_id
if (!"Prefix" %in% colnames(meta_dt)) meta_dt[,Prefix := gsub("_.*$", "", Sample_ID)]
prefix_v <- paste0(unique(meta_dt$Prefix), "_")
if (length(prefix_v) > 1)  stop("Multiple different prefixes")
if (!"Sample_ID" %in% colnames(meta_dt)) stop("Sample_ID not found and no replacement")
if (!"Slide" %in% colnames(meta_dt)) meta_dt[,Slide := gsub("_|ROI.*$", "", gsub(prefix_v, "", Sample_ID))]
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

### Write out again with updated info
cat(sprintf("Writing cleaned metadata to: %s\n", metaFile_v))
if (file_ext(metaFile_v) == "csv") {
  write.table(meta_dt, metaFile_v)
} else if (file_ext(metaFile_v) == "xlsx") {
  writexl::write_xlsx(meta_dt, metaFile_v)
} 

###
### Convert to Densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Which variable corresponds to idcol? could by sampleCol or by or mergeCol, most likely. sampleCol
### changed idCol_v = "Sample_ID" to idCol_v = sampleCol_v
density_dt <- calcDensity(data_dt = data_dt, 
                          meta_dt = meta_dt, 
                          areaCol_v = "Area", 
                          idCol_v = sampleCol_v, 
                          metaCols_v = excludeCols_v)

###
### Average By Slide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

avgDens_dt <- averageROIs(data_dt = density_dt, 
                          sampleCol_v = sampleCol_v, 
                          prefix_v = prefix_v,
                          split_v = splitCol_v, 
                          splitLabs_v = splitLabs_v, 
                          by_v = by_v, 
                          metaCols_v = excludeCols_v,
                          meta_dt = meta_dt[,mget(getCols_v)], 
                          mergeCol_v = mergeCol_v)

avgCount_dt <- averageROIs(data_dt = data_dt, 
                          sampleCol_v = sampleCol_v, 
                          prefix_v = prefix_v,
                          split_v = splitCol_v, 
                          splitLabs_v = splitLabs_v, 
                          by_v = by_v, 
                          metaCols_v = excludeCols_v,
                          meta_dt = meta_dt[,mget(getCols_v)], 
                          mergeCol_v = mergeCol_v)


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
  out <- calcDensity(data_dt = y, meta_dt = z, areaCol_v = "Area", idCol_v = "Class", metaCols_v = excludeCols_v)
}, simplify = F)

###
### Average By Slide ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

### Get unique IDs to average (slide is original, added Tumor for Zar)
#uniq_v <- avgDens_dt[[uniqCol_v]]
uniq_v <- unique(meta_dt[[uniqCol_v]])

### Average density for each
avgFD_lsdt <- sapply(uniq_v, function(x) functionalAverageROIs(functionalDensity_lsdt, id_v = x, col_v = "Class"),
                    simplify = F, USE.NAMES = T)

### Average counts for each
avgF_lsdt <- sapply(uniq_v, function(x) functionalAverageROIs(functional_lsdt, id_v = x, col_v = "Class"),
                    simplify = F, USE.NAMES = T)

###
### Write out average counts and densities ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
###

myOpenXWriteWkbk(data_ls = avgFD_lsdt, file_v = file.path(dataDir_v, paste0(gsub("_$", "", name_v), "_slideAvg_funcDensity.xlsx")))
myOpenXWriteWkbk(data_ls = avgF_lsdt, file_v = file.path(dataDir_v, paste0(gsub("_$", "", name_v), "_slideAvg_funcCount.xlsx")))