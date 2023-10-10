# mIHC
Functions for data wrangling and plotting of mIHC reports

## Set Up

Within a given project directory, there will be a `CSV` directory that contains the image results. Need more info here about how these are created. These files are used to make themain data file: `XX_studycounts.csv`. We also use them for the functional information. The first thing that we must do is to combine all of the functional information, calculate densities, and also group samples by any grouping variables. 

The `wrangleCounts.R` script works to accomplish this. There is still work to be done on improving this portion of the pipeline. 
This is a command-line script. Refer below and to the script help for determining arguments. It is advised to log your runs somewhere.

### Inputs into wrangleCounts.R

1. Base Directory - path to the pase project directory

1. Data Directory - relative path to where the following files can be found

1. Data File - this is of the format "ProjectName\_VersionNumber\_studycounts.csv
	+ Rows: Unique samples
		+ Format is [Prefix]\_[A-Z0-9]+ROI[0-9]+
			+ Prefix is a string describing source material
			+ First [A-Z0-9]+ is patient identifier
			+ Second is ROI Identifier
	+ Columns: Area; Cell types; Functional Markers
	+ Values: Area of the region; number of cells of cell type found; number of cells with functional marker

1. Metadata file
	+ Rows: Same as in Data File
	+ Columns: Various sample descriptors indicating how samples are related to one another and treatment/tissue

1. Color File
	+ Rows: Cell Population names; Functional Markers. These must be the same as the columns in Data File and the rows in Gating File
	+ Columns: Hex code to use for that population

1. Gating File
	+ Rows: Cell Population Name; Functional Markers. These must be the same as the columns in Data File and the rows in Gating File
	+ Columns: The gating values used to identify the population; plots to make
	+ Values: gates; number indicating inclusion and order in plot

1. Path to Functional Directory
	+ One file per row in Data File/Metadata File
	+ Rows correspond to cell populations
	+ Columns: functional markers
	+ Values: Number of cells expressing marker

1. Project Name - Used to name output files and can also be used to read in appropriate input files

1. Unique Column - Specify which column of metadata contains unique sample identifiers

### Run wrangleCounts.R

Either run directly on the command line, or (recommended) make a quick bash script to supply and record your arguments. After running, check to make sure the desired outputs have been made.

### Outputs of wrangleCounts.R

1. Throws  warnings if any of the populations or samples are mis-matched between the various input files
1. Updates metadata column to contain standard columns **overwrites input metadata file**
1. Converts count data to density
1. Averages both count and density data by ROI  
	+ **writes output: paste0(name_v, "\_slideAvg\_cell[Count/Density].csv")** 
1. Do the same (density conversion and average) for functional markers.  
	+  **writes output: paste0(name_v, "\_slideAvg\_func[Count/Density].csv**


## Running Reports


