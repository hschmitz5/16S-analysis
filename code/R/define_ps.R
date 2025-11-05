# Clear environment
rm(list = ls())

library(qiime2R)
library(phyloseq)

# define sample names
size <- data.frame(
  ranges = c("0.85-1.4", "1.4-2", "2-2.8", "2.8-4", ">4"),
  name = c("S", "M", "L", "XL", "XXL")
)

# Import QIIME2 data as phyloseq object
ps0 <- qiime2R::qza_to_phyloseq(
  features = "./data/qiime/table_dada2.qza",
  tree = "./data/qiime/rooted_tree.qza",
  taxonomy = "./data/qiime/taxonomy.qza",
  metadata = "./data/qiime/sample-metadata.tsv"
)
  
# remove 0-0.85 mm granules
ps <- subset_samples(ps0, size.mm != "0-0.85")

ps@sam_data$size.mm <- factor(ps@sam_data$size.mm, levels = size$ranges)
ps@sam_data$size.name <- factor(size$name[as.numeric(ps@sam_data$size.mm)], 
                                levels = size$name)
  
#### Filter ####
  
# remove Mitochondria and Chloroplasts (removes Eukaryotes)
ps_filt0 <- phyloseq::subset_taxa(ps, ! Family %in% c("Mitochondria", "Chloroplast"))
# remove unclassified sequences
ps_filt0 <- phyloseq::subset_taxa(ps, Kingdom != "Unassigned")
  
# define minimum depth to rarefy
rarefy_level <- min(sample_sums(ps_filt0))  # lowest number of ASVs per sample
# apply rarefaction
ps_filt_r <-rarefy_even_depth(
  ps_filt0, rarefy_level, rngseed = 7, replace = TRUE, trimOTUs = TRUE, verbose = TRUE
)
  
# Remove taxa not seen more than 3 times (reads) in at least 20% of the samples. 
# This protects against an OTU with small mean & trivially large C.V.
ps_filt = filter_taxa(ps_filt_r, function(x) sum(x > 3) >= (0.2*length(x)), TRUE)

saveRDS(ps_filt, file = "./data/ps_ASV.rds")

ps_genus <- tax_glom(ps_filt, taxrank = "Genus")

saveRDS(ps_genus, file = "./data/ps_genus.rds")