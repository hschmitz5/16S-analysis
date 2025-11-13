# display top n most abundant genera
n_display <- 10

fname <- "./figures/abund_size_stacked.png"
  
# Average per Genus across replicates
genus_size <- get_rel_genus(ps) %>%
  mutate(Genus = as.character(Genus)) %>%  # ensure it's character
  group_by(Genus, size.mm, size.name) %>%
  summarise(
    mean_ab = mean(Abundance),
    sd_ab = sd(Abundance),
    .groups = "drop") %>%
  mutate(
    Genus = ifelse(is.na(Genus) | !(Genus %in% high_ab_genera[1:n_display]), "Other", Genus)
  ) %>%
  group_by(Genus, size.mm, size.name) %>%
  summarise(
    mean_ab = sum(mean_ab),
    sd_ab = ifelse(unique(Genus) == "Other", NA_real_, sd_ab),
    .groups = "drop"
  ) %>%
  mutate(Genus = factor(Genus, levels = c(high_ab_genera[1:n_display], "Other")))
  
#n_display <- length(unique(genus_size$Genus)) - 1

p <- ggplot(genus_size, aes(x = size.name, y = mean_ab, fill = fct_rev(Genus))) +
  geom_col(width = 0.7) +  # stacked by default
  scale_fill_manual(
    values = c("gray", met.brewer(taxa_pal, n_display)),
    name = "Genera"
  ) +
  scale_y_continuous(
    expand = expansion(mult = c(0, 0.1))  # Add 10% space above
  ) +
  labs(
    # title = paste0("Genera = ", n_display),
    x = "Size",
    y = "Mean Relative Abundance [%]"
  ) +
  theme_minimal(base_size = 16)

# Save plot
ggsave(fname, plot = p, width = 8, height = 4, dpi = 300)