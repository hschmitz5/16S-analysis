rm(list=ls())
source("./code/R/00_setup.R")
source("./code/R/01_load_data.R")
source("./code/R/02_process_ps.R")

rel_table <- get_rel_genus(ps_ASV) %>%
  dplyr::select(Genus, Sample, Abundance) %>%
  pivot_wider(names_from=Sample, values_from = Abundance) %>%
  filter(!is.na(Genus)) %>%
  column_to_rownames("Genus") %>%
  t()

metadata_tmp <- get_metadata(ps_ASV) %>%
  dplyr::select(Sample, size.name)

# Reorder to match sam_name
rel_table <- rel_table[sam_name, ]

metadata <- metadata_tmp[match(sam_name, metadata_tmp$Sample), ]  # reorder
rownames(metadata) <- metadata$Sample                     # set row names
metadata$Sample <- NULL                                   # remove the column


asv_dist <- vegdist(rel_table, method = "bray")

permanova <- adonis2(asv_dist ~ size.name, data = metadata)

print(permanova)

## pairwise permanova
#install.packages("remotes")
#remotes::install_github("pmartinezarbizu/pairwiseAdonis/pairwiseAdonis")
library(pairwiseAdonis)

pairwise_results <- pairwise.adonis2(
  asv_dist ~ size.name,
  data = metadata,
  strata = 'size.name'
)
