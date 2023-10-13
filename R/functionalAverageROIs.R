functionalAverageROIs <- function(functional_lsdt, id_v, col_v = "class", meta_dt = NULL, metaCol_v = NULL, sampleCol_v = "Sample_ID") {
  #' Average Functional ROIs
  #' @description
  #' Calculate average functional values for ROIs originating from same sample (i.e. patient+timepoint)
  #' @param functional_lsdt list of functional tables (either counts or density), one for each patient+timepoint+ROI
  #' @param id_v sample ID that will be averaged over.
  #' @param col_v column name in each functional data.table that is the identifier (i.e. not a functional value)
  #' @param meta_dt associated metadata table that can be used for subsetting functional_lsdt
  #' @param metaCol_v column from meta_dt to use for subsetting
  #' @param sampleCol_v column from meta_dt whose values match names(functional_lsdt)
  #' @details Given a list of functional data tables, subset in one of two ways and calculate averages.
  #' Subset 1: grep(id_v, names(functional_lsdt)) 
  #' Subset 2: meta_dt[get(metaCol_v) == id_v, get(sampleCol_v)]
  #' @return data.table containing the averaged results of id_v
  #' @export

  ### Be sure only functional tables belonging to id_v are in the input
  if (is.null(meta_dt)) {
    data_lsdt <- functional_lsdt[grep(id_v, names(functional_lsdt))]
  } else {
    samples_v <- meta_dt[get(metaCol_v) == id_v, get(sampleCol_v)]
    data_lsdt <- functional_lsdt[samples_v]
  }

  ### If id_v only has one ROI, nothing to do
  ### If id_v has multiple ROIs, average them
  if (length(data_lsdt) == 1) {

    return(data_lsdt[[1]])

  } else {

    ### Convert to data.frame so that ID isn't included in average
    data_lsdf <- lapply(data_lsdt, function(x) wrh.rUtils::convertDFT(x, col_v = col_v))

    ### Sum and then divide by number of ROIs
    data_df <- Reduce(`+`, data_lsdf) / length(data_lsdf)

    ### Convert back and return
    return(wrh.rUtils::convertDFT(data_df, newName_v = col_v))

  } # fi
} # funcitonalAverageROIs

