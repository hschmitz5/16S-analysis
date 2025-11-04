suppressPackageStartupMessages({
  # ---- Packages ----
  library(phyloseq)
  library(tidyverse)
  #library(picante)
  #library(indicspecies)
  library(ComplexHeatmap)
  library(readxl)
  # optional
  #library(MetBrewer) # fun color palettes
  #library(vegan)
})
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, cache = TRUE)