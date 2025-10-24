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

# Remove taxa not seen more than 3 times (reads) in at least 1/6 of the samples. 
# This protects against an OTU with small mean & trivially large C.V.
ps_filt = filter_taxa(ps_filt_r, function(x) sum(x > 3) >= (0.2*length(x)), TRUE)

# relative abundance
ps_rel <- phyloseq::transform_sample_counts(ps_filt, function(x) x*100/sum(x))  # convert to %