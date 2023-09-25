readCSVOrExcel <- function(file_v) {
  #' Read csv of excel
  #' @description Read in csv file or first worksheet of an excel workbook
  #' @param file_v path to file to be read in
  #' @return data.table
  #' @export
 
  if (file_ext(file_v) == "csv") {
    out_dt <- fread(file_v)
  } else if (file_ext(file_v) %in% c("xlsx", "xls")) {
    out_dt <- as.data.table(readxl::read_excel(file_v))
  } else {
    stop("Only csv and xlsx are supported for metaFile_v")
  }
  return(out_dt)
}
