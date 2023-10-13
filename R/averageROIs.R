averageROIs <- function(data_dt, idCol_v = "Sample_ID", summarizeCol_v = "sampleName", meta_dt, metaCols_v = NULL) {
  #' Average ROIs
  #' @description
    #' Calculate average values for ROIs/replicates for a given sample.
  #' @param data_dt table of multiplex results
  #' @param idCol_v column that maps beween metadata and data
  #' @param summarizeCol_v column used to summarize ROIs 
  #' @param meta_dt meta data that maps to data_dt on idCol_v and has summarizeCol_v as a column.
  #' @param metaCols_v not really used. If data_dt happens to have other columns besides idCol_v and measurement columns, can use this to exclude them.
  #' @return data.tabel with same number of columns, rows summarized by summarizeCol_v
  #' @export
  
  ### Remove meta columns
  if (!is.null(metaCols_v)) {
    cat(sprintf("Removing %s column(s) from data. Make sure this is recorded elsewhere.\n", paste0(metaCols_v, collapse = ", ")))
    data_dt[,(metaCols_v) := NULL]
  } # fi
  
  ### Merge
  data_dt <- merge(meta_dt[,mget(c(idCol_v, summarizeCol_v))], data_dt, by = idCol_v, sort = F)
  
  ### Summarize
  sdCols_v <- setdiff(colnames(data_dt), c(idCol_v, summarizeCol_v))
  data_dt <- data_dt[,lapply(.SD, mean, na.rm = T), by = summarizeCol_v, .SDcols = sdCols_v]
  
  ### Return
  return(data_dt)
  
}