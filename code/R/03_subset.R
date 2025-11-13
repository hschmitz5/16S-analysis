get_avg_genus <- function(ps){
  # Average per Genus across all samples
  genus_avg <- get_rel_genus(ps) %>%
    filter(!is.na(Genus)) %>%
    group_by(Genus) %>%
    summarise(
      mean_ab = mean(Abundance),
      sd_ab = sd(Abundance),
      .groups = "drop") %>%
    filter(mean_ab > rel_ab_cutoff) %>%
    arrange(desc(mean_ab)) 
}

get_avg_OTUs <- function(ps){
  # Many genera have multiple ASVs in which one ASV is almost zero
  # Few have ASVs with a non-negligible abundance
  OTU_avg <- get_rel_ASV(ps) %>%
    filter(!is.na(Genus)) %>%
    group_by(Genus, OTU) %>%
    summarise(
      mean_ab = mean(Abundance),
      sd_ab = sd(Abundance),
      .groups = "drop") %>%
    filter(mean_ab > rel_ab_cutoff) %>%
    arrange(desc(mean_ab)) 
}

# Define genera above rel_ab_cutoff
genus_avg <- get_avg_genus(ps_ASV)
high_ab_genera <- genus_avg$Genus
rm(genus_avg)

# Define OTUs above rel_ab_cutoff
OTU_avg <- get_avg_OTUs(ps_ASV)
high_ab_OTUs <- OTU_avg$OTU
rm(OTU_avg)