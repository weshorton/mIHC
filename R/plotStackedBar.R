plotStackedBar <- function(plotCol_v, plotName_v = simpleCap(gsub("\\.", " ", gsub("^.*_", "", currPlotCol_v))), color_dt, colorCol_v = "Population",
                           config_dt, configCol_v = "Class", meta_dt, data_dt, mergeCol_v = "Slide", metaCol_v = "timepoint",
                           ylab_v = bquote('Cell Density (cells / mm'^2*')'), xlab_v = metaCol_v, fillLab_v = "Cell Type") {
  #' Make Stacked Bar of Population Densities
  #' @description Pop density stacked bars. Add better description later
  #' @param plotCol_v column name from config_dt that indicates which populations to plot and in what order. Column name format is "PlotType_Plot.Name"
  #' @param plotName_v name to use as plot title. Default is to remove "PlotType_" from plotCol_v and substitute "." for " ".
  #' @param color_dt data.table of hex codes. Column "colorCol_v" must have values that match column names of data_dt. Must have column "Hex" containing hex codes
  #' @param colorCol_v column name that contains entires that match columns in data_dt
  #' @param config_dt gating configuration reference file. must have plotCol_v and values in configCol must be in data_dt.
  #' @param configCol_v column from configuration that maps to values in data_dt. Default is "Class"
  #' @param meta_dt metadata file. must share mergeCol_v with data_dt
  #' @param data_dt data to plot. must share mergeCol_v with meta_dt and other columns must be values in config_dt[[configCol_v]]
  #' @param mergeCol_v column to use to merge data with metadata
  #' @param metaCol_v column to use to separate samples (x-axis of bar-plot)
  #' @return grid object (gtable, gtree, grob, gDesc) containing stacked bar plot and a table of the counts
  #' @export

  ### Subset config data
  subConfig_dt <- config_dt[!is.na(get(plotCol_v)), mget(c(configCol_v, plotCol_v))]

  ### Sort configCol_v values based on plotCol_v
  levels_v <- subConfig_dt[[configCol_v]][order(subConfig_dt[[plotCol_v]])]

  ### Merge data and metadata together while also subseting columns of data to only have those also in subConfig_dt
  ### Set key to order for plot
  merge_dt <- merge(meta_dt[,mget(c(mergeCol_v, metaCol_v))], data_dt[,mget(c(mergeCol_v, subConfig_dt[[configCol_v]]))],
                    by = mergeCol_v, sort = F)
  setkeyv(merge_dt, metaCol_v)

  ### Melt for ggplot
  melt_dt <- melt(merge_dt, id.vars = c(mergeCol_v, metaCol_v))

  ### Subset colors
  subColor_dt <- color_dt[get(colorCol_v) %in% subConfig_dt[[configCol_v]],]

  ### Order output based on levels made earlier
  melt_dt$variable <- factor(melt_dt$variable, levels = levels_v)
  subColor_dt <- subColor_dt[match(levels_v, subColor_dt[[colorCol_v]])]

  ### Make plot
  plot_gg <- ggplot(data = melt_dt, aes(x = !!sym(metaCol_v), y = value, fill = variable)) +
    geom_bar(position = "stack", stat = "identity") +
    big_label() +
    scale_fill_manual(values = subColor_dt$Hex, breaks = subColor_dt[[colorCol_v]]) +
    ggtitle(plotName_v) + labs(y = ylab_v, x = xlab_v, fill = fillLab_v)

  ### Make count table
  display_dt <- wrh.rUtils::myT(merge_dt[, mget(c(metaCol_v, levels_v))], newName_v = configCol_v)
  display_dt <- wrh.rUtils::convertDFT(round(wrh.rUtils::convertDFT(display_dt, col_v = configCol_v), digits = 2), newName_v = configCol_v)
  display_grob <- tableGrob(display_dt, rows = NULL, theme = ttheme_default(base_size = 16))

  ### Make output
  # return(invisible(grid.arrange(grobs = list(display_grob, plot_gg), ncol = 2)))
  return(ggpubr::as_ggplot(arrangeGrob(grobs = list(display_grob, plot_gg), ncol = 2)))

} # plotStackedBar

