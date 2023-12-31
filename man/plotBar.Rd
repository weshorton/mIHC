% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plotBar.R
\name{plotBar}
\alias{plotBar}
\title{Make Stacked Bar of Functional Markers for Different Populations}
\usage{
plotBar(
  plotCol_v,
  plotName_v = simpleCap(gsub("\\\\.", " ", gsub("^.*_", "", currPlotCol_v))),
  color_dt,
  colorCol_v = "Population",
  config_dt,
  configCol_v = "Class",
  meta_dt,
  data_lsdt,
  mergeCol_v = "Slide",
  metaCol_v = "timepoint",
  ylab_v = bquote("Marker Density (cells / mm"^2 * ")"),
  xlab_v = metaCol_v,
  fillLab_v = "Cell Type"
)
}
\arguments{
\item{plotCol_v}{column name from config_dt that indicates which populations to plot and in what order. Column name format is "PlotType_Plot.Name"}

\item{plotName_v}{name to use as plot title. Default is to remove "PlotType_" from plotCol_v and substitute "." for " ".}

\item{color_dt}{data.table of hex codes. Column "colorCol_v" must have values that match column names of data_dt. Must have column "Hex" containing hex codes}

\item{colorCol_v}{column name that contains entires that match columns in data_dt}

\item{config_dt}{gating configuration reference file. must have plotCol_v and values in configCol must be in data_dt. Must have "Gate" column.}

\item{configCol_v}{column from configuration that maps to values in data_dt. Default is "Class"}

\item{meta_dt}{metadata file. must share mergeCol_v with data_dt}

\item{data_lsdt}{data to plot. list of functional data.tables. List names must be values in meta_dt[\link{mergeCol_v}] and other columns must be functional values in config_dt[\link{configCol_v}]}

\item{mergeCol_v}{column to use to merge data with metadata}

\item{metaCol_v}{column to use to separate samples (x-axis of bar-plot)}
}
\value{
grid object (gtable, gtree, grob, gDesc) containing stacked bar plot and a table of the counts
}
\description{
Functional Marker bar plots. Add better description
}
