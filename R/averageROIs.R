averageROIs <- function(data_dt, sampleCol_v = "Sample_ID", prefix_v = "", split_v = "ROI",
                        splitLabs_v = c("Patient", "Sample"), by_v = "Patient", metaCols_v = NULL,
                        meta_dt = NULL, mergeCol_v = NULL) {
  #' Average ROIs
  #' @description
    #' Calculate average values for ROIs originating from same sample (i.e. patient+timepoint)
  #' @param data_dt table of multiplex results. Can be original counts (StudyCounts) or densities calculated from those
  #' @param sampleCol_v name of column that contains the sample IDs to use for aggregation
  #' @param prefix_v character vector that is prefix of values in sampleCol_v. Default is blank (no prefix). Whatever
  #' is provided will be erased from the sample id.
  #' @param split_v character vector of what to split sampleCol_v on in order to separate out patient from samples
  #' @param splitLabs_v character vector containing names of what to call results of sampleCol_v splitting
  #' @param by_v what to aggregate by. Default is Patient, but could be treatment or something if included in the name
  #' @param metaCols_v columns to exclude from aggregation
  #' @return data.table with same columns. Rows are now summarized by by_v.
  #' @export

  ### Remove meta columns
  if (!is.null(metaCols_v)) {
    cat(sprintf("Removing %s column(s) from data. Make sure this is recorded elsewhere.\n", paste0(metaCols_v, collapse = ", ")))
    data_dt[,(metaCols_v) := NULL]
  } # fi

  ###
  ### Sample_ID often has multiple pieces of information in it. split into component parts
  ###

  ### Split sample column
  split_dt <- as.data.table(do.call(rbind, strsplit(gsub(prefix_v, "", data_dt[[sampleCol_v]]), split = split_v)))
  colnames(split_dt) <- splitLabs_v

  ### Add back
  data_dt <- cbind(data_dt, split_dt)

  ###
  ### If Sample_ID may not contain the correct grouping info, if not, have to add it.
  ###

  if (!(by_v %in% colnames(data_dt))) {

    cat(sprintf("Grouping column %s not in data. Merging with provided metadata on %s column.\n", by_v, mergeCol_v))
    if (is.null(meta_dt)) stop("Must specify meta_dt if by_v not in data_dt")

    data_dt <- merge(data_dt, meta_dt, by = mergeCol_v, sort = F)

  }

  ### Summarize
  sdCols_v <- setdiff(colnames(data_dt), c(sampleCol_v, splitLabs_v, by_v))
  data_dt <- data_dt[, lapply(.SD, mean, na.rm = T), by = by_v, .SDcols = sdCols_v]

  ### Output
  return(data_dt)

}

