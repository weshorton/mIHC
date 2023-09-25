plotBar <- function(plotCol_v, plotName_v = simpleCap(gsub("\\.", " ", gsub("^.*_", "", currPlotCol_v))), color_dt, colorCol_v = "Population",
                    config_dt, configCol_v = "Class", meta_dt, data_lsdt, mergeCol_v = "Slide", metaCol_v = "timepoint",
                    ylab_v = bquote('Marker Density (cells / mm'^2*')'), xlab_v = metaCol_v, fillLab_v = "Cell Type") {
  #' Make Stacked Bar of Functional Markers for Different Populations
  #' @description Functional Marker bar plots. Add better description
  #' @param plotCol_v column name from config_dt that indicates which populations to plot and in what order. Column name format is "PlotType_Plot.Name"
  #' @param plotName_v name to use as plot title. Default is to remove "PlotType_" from plotCol_v and substitute "." for " ".
  #' @param color_dt data.table of hex codes. Column "colorCol_v" must have values that match column names of data_dt. Must have column "Hex" containing hex codes
  #' @param colorCol_v column name that contains entires that match columns in data_dt
  #' @param config_dt gating configuration reference file. must have plotCol_v and values in configCol must be in data_dt. Must have "Gate" column.
  #' @param configCol_v column from configuration that maps to values in data_dt. Default is "Class"
  #' @param meta_dt metadata file. must share mergeCol_v with data_dt
  #' @param data_lsdt data to plot. list of functional data.tables. List names must be values in meta_dt[[mergeCol_v]] and other columns must be functional values in config_dt[[configCol_v]]
  #' @param mergeCol_v column to use to merge data with metadata
  #' @param metaCol_v column to use to separate samples (x-axis of bar-plot)
  #' @return grid object (gtable, gtree, grob, gDesc) containing stacked bar plot and a table of the counts
  #' @export

  ### Subset config data
  subConfig_dt <- config_dt[!is.na(get(plotCol_v)), mget(c(configCol_v, "Gate", plotCol_v))]
  subConfig_dt <- subConfig_dt[get(plotCol_v) != "",]

  ### Grab which functional markers to plot (or all if not specified)
  funcMarkers_v <- gsub("Areap_|p$", "", subConfig_dt[get(plotCol_v) == "T", Gate])
  if (length(funcMarkers_v) == 0) funcMarkers_v <- setdiff(colnames(data_lsdt[[1]]), configCol_v)

  ### Remove functional markers from config table
  ### Ensure plot column is numeric
  subConfig_dt <- subConfig_dt[get(plotCol_v) != "T",]
  subConfig_dt[[plotCol_v]] <- as.numeric(subConfig_dt[[plotCol_v]])

  ### Sort configCol_v values based on plotCol_v
  levels_v <- subConfig_dt[[configCol_v]][order(subConfig_dt[[plotCol_v]])]

  ### Subset data for specific functional markers
  subData_lsdt <- sapply(names(data_lsdt), function(x) {
    y <- data_lsdt[[x]]
    yy <- y[get(configCol_v) %in% levels_v,
            mget(c(configCol_v, grep(paste(funcMarkers_v, collapse = "|"), colnames(y), value = T)))]
    yy[[metaCol_v]] <- meta_dt[get(mergeCol_v) == x, get(metaCol_v)]
    return(yy)
  }, simplify = F, USE.NAMES = T)

  ### Combine Data and sort
  data_dt <- do.call(rbind, subData_lsdt)
  setkeyv(data_dt, metaCol_v)

  ### Melt for ggplot
  melt_dt <- melt(data_dt, id.vars = c(configCol_v, metaCol_v))

  ### Remove _func suffix from color names in the data (so they match names in color table)
  melt_dt$variable <- gsub("_func", "", melt_dt$variable)

  ### Remove "+" from color table
  color_dt[[colorCol_v]] <- gsub("\\+", "", color_dt[[colorCol_v]])

  ### Subset colors
  color_dt <- color_dt[get(colorCol_v) %in% unique(melt_dt$variable),]

  ### Make plot
  plot_gg <- ggplot(data = melt_dt, aes(x = !!sym(configCol_v), y = value, fill = variable)) +
    geom_bar(position = "stack", stat = "identity") +
    big_label() + angle_x() +
    facet_wrap(as.formula(paste0("~", metaCol_v))) +
    scale_fill_manual(values = color_dt$Hex, breaks = color_dt[[colorCol_v]]) +
    ggtitle(plotName_v) + labs(y = ylab_v, x = xlab_v, fill = fillLab_v)

  ### Make count table
  display_dt <- round(data_dt[,mget(setdiff(colnames(data_dt), c(configCol_v, metaCol_v)))], digits = 2)
  display_dt <- cbind(data_dt[,mget(c(configCol_v, metaCol_v))], display_dt)
  display_grob <- tableGrob(display_dt, rows = NULL, theme = ttheme_default(base_size = 16))

  ### Make output
  return(ggpubr::as_ggplot(arrangeGrob(grobs = list(display_grob, plot_gg), ncol = 2)))

} # plotBar
