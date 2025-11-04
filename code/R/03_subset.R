rel_ab_cutoff <- 0.5 # %

# If a genus has multiple ASVs, they're added together
genus_sum <- table_rel_long %>%
  group_by(Sample, size.mm, Genus) %>%
  summarise(sum_ab = sum(Abundance), .groups = "drop") 

# Average per Genus across all samples
genus_avg <- genus_sum %>%
  group_by(Genus) %>%
  summarise(
    mean_ab = mean(sum_ab),
    sd_ab = sd(sum_ab),
    .groups = "drop") %>%
  filter(mean_ab > rel_ab_cutoff) %>%
  arrange(desc(mean_ab)) %>%
  # Factor the genus based on relative abundance
  mutate(Genus = forcats::fct_reorder(Genus, mean_ab, .desc = TRUE))

# Define Genus factor levels
genus_names <- levels(genus_avg$Genus)

# Average per Genus across replicates
genus_size <- genus_sum %>%
  filter(Genus %in% genus_names) %>%
  group_by(Genus, size.mm) %>%
  summarise(
    mean_ab = mean(sum_ab),
    sd_ab = sd(sum_ab),
    .groups = "drop") %>%  
  mutate(Genus = factor(Genus, levels = genus_names))

### If you're interested in ASVs (not agglomerating genera)
### Many genera have multiple ASVs in which one ASV is almost zero
### Few have ASVs with a non-negligible abundance
top_asvs <- convert_rel(ps_ASV) %>%
  filter(!is.na(Genus)) %>%
  group_by(Genus, OTU) %>%
  summarise(
    mean_ab = mean(Abundance), 
    sd_ab = sd(Abundance),
    .groups = "drop") %>%  
  arrange(desc(mean_ab)) %>%  
  filter(mean_ab > rel_ab_cutoff)

OTU_names <- top_asvs$OTU
