% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/twdtwApply.R
\docType{methods}
\name{twdtwApply}
\alias{twdtwApply}
\alias{twdtwApply,twdtwTimeSeries-method}
\alias{twdtwApply-twdtwTimeSeries}
\alias{twdtwApply,twdtwRaster-method}
\alias{twdtwApply-twdtwRaster}
\title{Apply TWDTW analysis}
\usage{
twdtwApply(x, y, resample = TRUE, length = NULL, weight.fun = NULL,
  dist.method = "Euclidean", step.matrix = symmetric1, n = NULL,
  span = NULL, min.length = 0, theta = 0.5, ...)

\S4method{twdtwApply}{twdtwTimeSeries}(x, y, resample, length, weight.fun,
  dist.method, step.matrix, n, span, min.length, theta, keep = FALSE,
  ...)

\S4method{twdtwApply}{twdtwRaster}(x, y, resample, length, weight.fun,
  dist.method, step.matrix, n, span, min.length, theta, breaks = NULL,
  from = NULL, to = NULL, by = NULL, overlap = 0.5,
  filepath = "", ...)
}
\arguments{
\item{x}{An object of class twdtw*. This is the target time series. 
Usually, it is a set of unclassified time series.}

\item{y}{An object of class \link[dtwSat]{twdtwTimeSeries}. 
The temporal patterns.}

\item{resample}{Resample the patterns to have the same length. Default is TRUE.
See \link[dtwSat]{resampleTimeSeries} for details.}

\item{length}{An integer. Length of patterns used with \code{patterns.length}. 
If not declared the length of the output patterns will be the length of 
the longest pattern.}

\item{weight.fun}{A function. Any function that receives and performs a 
computation on a matrix. The function receives a matrix of time differences 
in days and returns a matrix of time-weights. If not declared the time-weight 
is zero. In this case the function runs the standard version of the dynamic 
time warping. See details.}

\item{dist.method}{A character. Method to derive the local cost matrix.
Default is ''Euclidean'' see \code{\link[proxy]{dist}} in package 
\pkg{proxy}.}

\item{step.matrix}{See \code{\link[dtw]{stepPattern}} in package \pkg{dtw} 
\insertCite{Giorgino:2009}{dtwSat}.}

\item{n}{An integer. The maximun number of matches to perform. 
NULL will return all matches.}

\item{span}{A number. Span between two matches, \emph{i.e.} the minimum
interval between two matches; for details see \insertCite{Muller:2007}{dtwSat}. 
If not declared it removes all overlapping matches of the same pattern. To include 
overlapping matches of the same pattern use \code{span=0}.}

\item{min.length}{A number between 0 an 1. This argument removes overfittings.
Minimum length after warping. Percentage of the original pattern length. Default is 0.5, 
meaning that the matching cannot be shorter than half of the pattern length.}

\item{theta}{Numeric between 0 and 1. The weight of the time 
for the TWDTW computation. Use \code{theta=0} to cancel the time-weight, 
\emph{i.e.} to run the original DTW algorithm. Default is 0.5, meaning that 
the time has the same weight as the curve shape in the TWDTW analysis.}

\item{...}{Arguments to pass to \code{\link[raster]{writeRaster}} and 
\code{\link[raster]{pbCreate}}}

\item{keep}{Preserves the cost matrix, inputs, and other internal structures. 
Default is FALSE. For plot methods use \code{keep=TRUE}.}

\item{breaks}{A vector of class \code{\link[base]{Dates}}. This replaces the arguments \code{from},
\code{to}, and \code{by}.}

\item{from}{A character or \code{\link[base]{Dates}} object in the format "yyyy-mm-dd".}

\item{to}{A \code{\link[base]{character}} or \code{\link[base]{Dates}} object in the format "yyyy-mm-dd".}

\item{by}{A \code{\link[base]{character}} with the interval size, \emph{e.g.} "6 month".}

\item{overlap}{A number between 0 and 1. The minimum overlapping 
between one match and the interval of classification. Default is 0.5, 
\emph{i.e.} an overlap minimum of 50\%.}

\item{filepath}{A character. The path at which to save the raster with results. If not provided the 
function saves in the current work directory.}
}
\value{
An object of class twdtw*.
}
\description{
This function performs a multidimensional Time-Weighted DTW 
analysis and retrieves the matches between the temporal patterns and 
a set of time series \insertCite{Maus:2019}{dtwSat}.
}
\details{
The linear \code{linearWeight} and \code{logisticWeight} weight functions 
can be passed to \code{twdtwApply} through the argument \code{weight.fun}. This will 
add a time-weight to the dynamic time warping analysis. The time weight 
creates a global constraint useful for analysing time series with phenological cycles
of vegetation that are usually bound to seasons. In previous studies by 
\insertCite{Maus:2016}{dtwSat} the logistic weight had better results than the 
linear for land cover classification. 
See \insertCite{Maus:2016,Maus:2019}{dtwSat} for details about the method.
}
\examples{
# Applying TWDTW analysis to objects of class twdtwTimeSeries
log_fun = logisticWeight(-0.1, 100)
ts = twdtwTimeSeries(MOD13Q1.ts.list)
patt = twdtwTimeSeries(MOD13Q1.patterns.list)
mat1 = twdtwApply(x=ts, y=patt, weight.fun=log_fun)
mat1

\dontrun{
# Parallel processin
require(parallel)
mat_list = mclapply(as.list(ts), mc.cores=2, FUN=twdtwApply, y=patt, weight.fun=log_fun)
mat2 = twdtwMatches(alignments=mat_list)
}
\dontrun{
  
# Example of TWDTW analysis using raster files 
library(dtwSat)
library(caret) 

# Load raster data 
evi  <- brick(system.file("lucc_MT/data/evi.tif",  package = "dtwSat"))
ndvi <- brick(system.file("lucc_MT/data/ndvi.tif", package = "dtwSat"))
red  <- brick(system.file("lucc_MT/data/red.tif",  package = "dtwSat"))
blue <- brick(system.file("lucc_MT/data/blue.tif", package = "dtwSat"))
nir  <- brick(system.file("lucc_MT/data/nir.tif",  package = "dtwSat"))
mir  <- brick(system.file("lucc_MT/data/mir.tif",  package = "dtwSat"))
doy  <- brick(system.file("lucc_MT/data/doy.tif",  package = "dtwSat"))
timeline <- 
  scan(system.file("lucc_MT/data/timeline", package = "dtwSat"), what="date")

# Create raster time series 
rts <- twdtwRaster(evi, ndvi, red, blue, nir, mir, timeline = timeline, doy = doy)

# Load field samples and projection 
field_samples <- 
  read.csv(system.file("lucc_MT/data/samples.csv", package = "dtwSat"))
proj_str <- 
  scan(system.file("lucc_MT/data/samples_projection", package = "dtwSat"), 
       what = "character")

# Split samples for training (10\%) and validation (90\%) using stratified sampling 
set.seed(1)
I <- unlist(createDataPartition(field_samples$label, p = 0.1))
training_samples <- field_samples[I, ]
validation_samples <- field_samples[-I, ]

# Get time series form raster
training_ts <- getTimeSeries(rts, y = training_samples, proj4string = proj_str)
validation_ts <- getTimeSeries(rts, y = validation_samples, proj4string = proj_str)

# Create temporal patterns 
temporal_patterns <- createPatterns(training_ts, freq = 8, formula = y ~ s(x))

# Set TWDTW weight function 
log_fun <- logisticWeight(-0.1, 50)

# Run serial TWDTW analysis 
r_twdtw <-
  twdtwApply(x = rts, y = temporal_patterns, weight.fun = log_fun, progress = 'text')

# or Run parallel TWDTW analysis
beginCluster()
r_twdtw <- 
  twdtwApplyParallel(x = rts, y = temporal_patterns, weight.fun = log_fun, progress = 'text')
endCluster()

# Plot TWDTW distances for the first year 
plot(r_twdtw, type = "distance", time.levels = 1)

# Classify raster based on the TWDTW analysis 
r_lucc <- twdtwClassify(r_twdtw, progress = 'text')

# Plot TWDTW classification results 
plot(r_lucc, type = "map")

# Assess classification 
twdtw_assess <- 
  twdtwAssess(object = r_lucc, y = validation_samples, 
              proj4string = proj_str, conf.int = .95) 

# Plot map accuracy 
plot(twdtw_assess, type = "accuracy")

# Plot area uncertainty 
plot(twdtw_assess, type = "area")

# Plot misclassified samples  
plot(twdtw_assess, type = "map", samples = "incorrect") 

# Get latex table with error matrix 
twdtwXtable(twdtw_assess, table.type = "matrix")

# Get latex table with error accuracy 
twdtwXtable(twdtw_assess, table.type = "accuracy")

# Get latex table with area uncertainty 
twdtwXtable(twdtw_assess, table.type = "area")

}

}
\references{
\insertAllCited{}
}
\seealso{
\code{\link[dtwSat]{twdtwMatches-class}}, 
\code{\link[dtwSat]{twdtwTimeSeries-class}}, 
\code{\link[dtwSat]{twdtwRaster-class}}, 
\code{\link[dtwSat]{getTimeSeries}}, and 
\code{\link[dtwSat]{createPatterns}}
}
\author{
Victor Maus, \email{vwmaus1@gmail.com}
}
