readCSVOrExcel <- function(file_v) {
  if (file_ext(file_v) == "csv") {
    out_dt <- fread(file_v)
  } else if (file_ext(file_v) %in% c("xlsx", "xls")) {
    out_dt <- as.data.table(readxl::read_excel(file_v))
  } else {
    stop("Only csv and xlsx are supported for metaFile_v")
  }
  return(out_dt)
}
