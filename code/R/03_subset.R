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
    arrange(desc(mean_ab)) %>%
    # Factor the genus based on relative abundance
    mutate(Genus = forcats::fct_reorder(Genus, mean_ab, .desc = TRUE))
  
  return(genus_avg)
}

get_size_genus <- function(ps){
  # display top n most abundant genera
  n_display <- 10 
  
  # Average per Genus across replicates
  genus_size <- get_rel_genus(ps) %>%
    group_by(Genus, size.mm, size.name) %>%
    summarise(
      mean_ab = mean(Abundance),
      sd_ab = sd(Abundance),
      .groups = "drop") %>%  
    mutate(
      Genus = ifelse(Genus %in% high_ab_genera[1:n_display], Genus, "Other")
    ) %>%
    group_by(Genus, size.mm, size.name) %>%
    summarise(
      mean_ab = sum(mean_ab),
      sd_ab = ifelse(unique(Genus) == "Other", NA_real_, sd_ab),
      .groups = "drop"
    ) %>%
    mutate(Genus = factor(Genus, levels = c(high_ab_genera, "Other")))
  
  return(genus_size)
}

# must use non-agglomerated data
get_top_asvs <- function(ps){
  # Many genera have multiple ASVs in which one ASV is almost zero
  # Few have ASVs with a non-negligible abundance
  top_asvs <- get_rel_ASV(ps) %>%
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
genus_avg <- get_avg_genus(ps_ASV)
high_ab_genera <- levels(genus_avg$Genus)
rm(genus_avg)

# Define OTUs above rel_ab_cutoff
top_asvs <- get_top_asvs(ps_ASV)
OTU_names <- top_asvs$OTU
rm(top_asvs)
