suppressPackageStartupMessages({
  # ---- Packages ----
  library(tidyverse)
  library(phyloseq)
  library(ComplexHeatmap)
  library(readxl)
  library(writexl)
  #library(vegan)
  # colors
  library(RColorBrewer)
  library(MetBrewer) # fun color palettes
})
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, cache = TRUE)