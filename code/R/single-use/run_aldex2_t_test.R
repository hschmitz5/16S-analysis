rm(list = ls())

library(tidyverse)
library(digest)
library(phyloseq)
library(ALDEx2)

size1 <- c("M", "L", "XL", "XXL")
size2 <- c("S", "S", "S", "S")     # reference group

ps_ASV <- readRDS("./data/ps_ASV.rds") 

# Remove taxa not seen more than 3 times (reads) in at least 20% of the samples.
# This protects against an OTU with small mean & trivially large C.V.
ps_filt = filter_taxa(ps_ASV, function(x) sum(x > 3) >= (0.2*length(x)), TRUE)

# Agglomerate by Genus
ps_genus <- tax_glom(ps_filt, taxrank = "Genus")

metadata <- as.data.frame(as.matrix(ps_genus@sam_data)) %>%
  rownames_to_column("Sample") 

taxonomy <- as.data.frame(as.matrix(ps_genus@tax_table)) %>%
  rownames_to_column("OTU")

# Generate pairwise combinations
pair_samples <- cbind(size1, size2) %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  # identify samples that are in each size
  mutate(
    comparison = paste0(size1, "-", size2),
    # define sample names in pairwise combination (ordering size1 first)
    samples = map2(size1, size2, ~ {
      samples_x <- metadata %>% filter(size.name == .x) %>% pull(Sample)
      samples_y <- metadata %>% filter(size.name == .y) %>% pull(Sample)
      c(samples_x, samples_y)
    }),
    conds = map(samples, ~ metadata$size.name[match(.x, metadata$Sample)]),
    res = pmap(list(comparison, samples, conds), function(comp_name, samples_in_pair, conds_in_pair) {
      # generate deterministic seed
      seed_val <- strtoi(substr(digest::digest(comp_name), 1, 8), base = 16)
      set.seed(seed_val)
      
      # subset reads table
      reads <- as.data.frame(ps_genus@otu_table) %>%
        rownames_to_column(var = "OTU") %>%
        left_join(taxonomy, by = "OTU") %>%
        column_to_rownames(var = "Genus") %>%
        dplyr::select(all_of(samples_in_pair))
      
      # run ALDEx2 once, using conds_in_pair
      aldex(reads, conds_in_pair, denom = "all", test = "t", effect = TRUE)
    })
  ) %>%
  dplyr::select(comparison, conds, res)

saveRDS(pair_samples, file = "./results/aldex_t.rds")