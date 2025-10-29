# Identify top ASVs by mean abundance (excluding NA Genera)
top_asvs <- table_rel_long %>%
  filter(!is.na(Genus)) %>%
  group_by(Genus, seq) %>%
  summarise(mean_ab = mean(rel_ab), .groups = "drop") %>%  
  arrange(desc(mean_ab)) %>%  
  slice_head(n = n_asv) 

# Sum abundances of selected ASVs per sample
genus_sum <- table_rel_long %>%
  filter(seq %in% top_asvs$seq) %>%
  group_by(sample, size.mm, Genus) %>%
  summarise(sum_ab = sum(rel_ab), .groups = "drop") 

# Average per Genus across all samples
genus_avg <- genus_sum %>%
  group_by(Genus) %>%
  summarise(
    mean_ab = mean(sum_ab),
    sd_ab = sd(sum_ab),
    .groups = "drop"
  ) %>%
  arrange(desc(mean_ab)) %>%
  # Factor the genus based on relative abundance
  mutate(Genus = forcats::fct_reorder(Genus, mean_ab, .desc = TRUE))

# Define Genus factor levels
genus_levels <- levels(genus_avg$Genus)

top_asvs <- top_asvs %>%
  mutate(Genus = factor(Genus, levels = genus_levels))

# Average per Genus across replicates
genus_size <- genus_sum %>%
  group_by(Genus, size.mm) %>%
  summarise(
    mean_ab = mean(sum_ab),
    sd_ab = sd(sum_ab)
  ) %>%
  mutate(Genus = factor(Genus, levels = genus_levels))

### Names
genus_names <- genus_avg$Genus 
seq_names <- top_asvs$seq