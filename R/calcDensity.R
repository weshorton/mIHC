calcDensity <- function(data_dt, meta_dt = NULL, areaCol_v = "Area", idCol_v = "Sample_ID", metaCols_v = NULL) {
  #' Calculate Density
  #' @description
    #' Convert mIHC cell counts into cell densities. Current format is for the area column to be recorded
    #' in the metadata file. Sometimes it's in the data file. This should be able to handle either.
  #' @param data_dt data output by gating. File form is usually "StudyCounts"
  #' @param meta_dt metadata file containing the area column
  #' @param areaCol_v column to use as area for density calculations. Default is 'Area'
  #' @param idCol_v column in both data_dt and meta_dt that identifies samples
  #' @param metaCols_v columns to ignore during density calculation (optional)
  #' @return data.table that is same as input except each cell is a density instead of a count. Also 'Area' column removed
  #' @export

  ### If no metadata, make sure data has Area column
  if (is.null(meta_dt)) {

    cat(sprintf("No metadata provided. Checking data_dt for area column.\n"))
    if (!areaCol_v %in% colnames(data_dt)) stop("No metadata provided and data_dt does not have area column. Check arguments.\n")

  ### If metadata, check for area column in data and meta.data
  ### If both have one, make sure they're the same value
  ### If not in data, make sure it is in meta.data. Then merge
  } else {
    
    if ("Area" %in% colnames(data_dt)) {
      cat(sprintf("Metadata provided and data has Area column. Checking that they're equal.\n"))
      checkArea_v <- all.equal(data_dt[[areaCol_v]], meta_dt[[areaCol_v]])
      if (!is.logical(checkArea_v)) stop("Area columns in provided data and metadata don't match. Make sure they do!\n")
      mergeCols_v <- c(idCol_v, areaCol_v)
    } else {
      if (!areaCol_v %in% colnames(meta_dt)) stop("Metadata doesn't have area column and neither does data. Can't get density without area!\n")
      mergeCols_v <- idCol_v
    }

    data_dt <- merge(data_dt, meta_dt[,mget(c(idCol_v, areaCol_v)),drop = F], by = mergeCols_v, sort = F)

  } # fi

  ### Get columns to calc
  calcCols_v <- setdiff(colnames(data_dt), c(areaCol_v, idCol_v, metaCols_v))

  ### Extract metadata columns to add back later
  metaCols_v <- c(idCol_v, metaCols_v)
  temp_dt <- data_dt[,mget(metaCols_v), drop = F]

  ### Calculate
  data_dt <- data_dt[, lapply(.SD, function(x) x / get(areaCol_v)), .SDcols = calcCols_v]

  ### Add back meta
  data_dt <- cbind(temp_dt, data_dt)

  ### Return
  return(data_dt)

} # calcDensity
