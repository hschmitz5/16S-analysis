get_ps <- function(){
  # Import QIIME2 data as phyloseq object
  ps <- qiime2R::qza_to_phyloseq(
    features = "../data/table_dada2.qza",
    tree = "../data/rooted_tree.qza",
    taxonomy = "../data/taxonomy.qza",
    metadata = "../data/sample-metadata.tsv"
  )
  ps@sam_data$size.mm <- factor(ps@sam_data$size.mm, levels = size$ranges, ordered = TRUE)
  ps@sam_data$size.name <- size$name[as.numeric(ps@sam_data$size.mm)]
  
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
  
  return(ps_filt)
}

get_metadata <- function(ps_filt){
  metadata <- as.data.frame(as.matrix(ps_filt@sam_data)) %>%
    rownames_to_column("Sample") %>%
    mutate(size.mm = factor(size.mm, levels = size$ranges, ordered = TRUE))
}

convert_rel <- function(ps_filt){
  table_rel_long <- ps_filt %>%
    # convert to relative abundance
    phyloseq::transform_sample_counts(function(x) x*100/sum(x)) %>%
    # combine with taxonomy and metadata
    phyloseq::psmelt()
  
  return(table_rel_long)
}