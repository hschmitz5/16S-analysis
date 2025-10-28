suppressPackageStartupMessages({
  # ---- Packages ----
  library(qiime2R)
  library(phyloseq)
  library(tidyverse)
  library(ANCOMBC)
  library(ALDEx2)
  library(picante)
  #library(indicspecies)
  library(readxl)
  # optional
  library(MetBrewer) # fun color palettes
  #library(vegan)
})
knitr::opts_chunk$set(echo = TRUE, message = FALSE, warning = FALSE, cache = TRUE)