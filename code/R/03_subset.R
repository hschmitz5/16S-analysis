# ps_genus must be agglomerated to genus level
get_avg_genus <- function(ps_genus){
  # Average per Genus across all samples
  genus_avg <- convert_rel(ps_genus) %>% # genus_sum
    group_by(Genus) %>%
    summarise(
      mean_ab = mean(Abundance),
      sd_ab = sd(Abundance),
      .groups = "drop") %>%
    filter(mean_ab > rel_ab_cutoff) %>%
    arrange(desc(mean_ab)) %>%
    # Factor the genus based on relative abundance
    mutate(Genus = forcats::fct_reorder(Genus, mean_ab, .desc = TRUE))
  
  return(genus_avg)
}

get_size_genus <- function(ps_genus){
  n_display <- 10 # shown in stacked bar plot
  
  table_rel_new <- convert_rel(ps_genus) %>%
    mutate(
      Genus = ifelse(Genus %in% genus_names[1:n_display], Genus, "Other")
    )
  
  # Average per Genus across replicates
  genus_size <- table_rel_new %>%
    group_by(Genus, size.mm, size.name) %>%
    summarise(
      mean_ab = mean(Abundance),
      sd_ab = sd(Abundance),
      .groups = "drop") %>%  
    mutate(Genus = factor(Genus, levels = c(genus_names, "Other")))
  
  return(genus_size)
}

# must use non-agglomerated data
get_top_asvs <- function(ps_ASV){
  # Many genera have multiple ASVs in which one ASV is almost zero
  # Few have ASVs with a non-negligible abundance
  top_asvs <- convert_rel(ps_ASV) %>%
    filter(!is.na(Genus)) %>%
    group_by(Genus, OTU) %>%
    summarise(
      mean_ab = mean(Abundance), 
      sd_ab = sd(Abundance),
      .groups = "drop") %>%  
    arrange(desc(mean_ab)) %>%  
    filter(mean_ab > rel_ab_cutoff)
  
  return(top_asvs)
}

# Define genera above rel_ab_cutoff
genus_avg <- get_avg_genus(ps_genus)
genus_names <- levels(genus_avg$Genus)
rm(genus_avg)

# Define OTUs above rel_ab_cutoff
top_asvs <- get_top_asvs(ps_ASV)
OTU_names <- top_asvs$OTU
rm(top_asvs)
