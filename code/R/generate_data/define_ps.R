# Clear environment
rm(list = ls())

library(qiime2R)
library(phyloseq)

# define sample names
size <- data.frame(
  ranges = c("0.43-0.85","0.85-1.4", "1.4-2", "2-2.8", "2.8-4", ">4"),
  name = c("XS", "S", "M", "L", "XL", "XXL")
)

# Import QIIME2 data as phyloseq object
ps <- qiime2R::qza_to_phyloseq(
  features = "./data/qiime/table_dada2.qza",
  tree = "./data/qiime/rooted_tree.qza",
  taxonomy = "./data/qiime/taxonomy.qza",
  metadata = "./data/qiime/sample-metadata.tsv"
)

ps@sam_data$size.mm <- factor(ps@sam_data$size.mm, levels = size$ranges)
ps@sam_data$size.name <- factor(size$name[as.numeric(ps@sam_data$size.mm)], levels = size$name)
  
#### Filter ####
  
# remove Mitochondria and Chloroplasts (removes Eukaryotes)
ps_filt0 <- phyloseq::subset_taxa(ps, ! Family %in% c("Mitochondria", "Chloroplast"))
# remove unclassified sequences
ps_filt0 <- phyloseq::subset_taxa(ps, Kingdom != "Unassigned")
  
# define minimum depth to rarefy
rarefy_level <- min(sample_sums(ps_filt0))  # lowest number of ASVs per sample
# apply rarefaction
ps_filt <-rarefy_even_depth(
  ps_filt0, rarefy_level, rngseed = 7, replace = TRUE, trimOTUs = TRUE, verbose = TRUE
)

saveRDS(ps_filt, file = "./data/ps_ASV_full.rds")

# remove XS granules
ps_sub <- subset_samples(ps_filt, size.mm != "0.43-0.85")
  
saveRDS(ps_sub, file = "./data/ps_ASV_subset.rds")