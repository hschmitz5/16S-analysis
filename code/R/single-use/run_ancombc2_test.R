rm(list = ls())

library(phyloseq)
library(ANCOMBC)

# Read in your data
ps_ASV <- readRDS("../data/ps_ASV.rds") 

# Get taxa names
taxa_names_all <- taxa_names(ps_ASV)

# Randomly sample 150 taxa (or fewer if there aren’t that many)
n_taxa <- min(150, length(taxa_names_all))
set.seed(123)  # for reproducibility
taxa_subset <- sample(taxa_names_all, n_taxa)

# Subset the phyloseq object
ps_small <- prune_taxa(taxa_subset, ps_ASV)

contrast_mats = list(
  # monotonically increasing
  matrix(c(1, 0, 0, 0, -1, 1, 0, 0, 0, -1, 1, 0, 0, 0, -1, 1),
         nrow = 4, byrow = TRUE),
  # monotonically decreasing
  matrix(c(-1, 0, 0, 0, 1, -1, 0, 0, 0, 1, -1, 0, 0, 0, 1, -1),
         nrow = 4, byrow = TRUE)
)

set.seed(456)  # for reproducibility
output <- ancombc2(
  data = ps_small, tax_level = "Genus",
  fix_formula = "size.name",    
  group = "size.name",
  struc_zero = TRUE,
  global = TRUE, pairwise = TRUE, dunnet = TRUE, trend = TRUE,  
  trend_control = list(contrast = contrast_mats,
                       node = list(4, 4),
                       solver = "ECOS",
                       B = 10)
)

saveRDS(output, file = "./results/ancombc2_test.rds")