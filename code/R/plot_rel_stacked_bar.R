source("./code/R/00_setup.R")
source("./code/R/01_load_data.R")
source("./code/R/02_process_ps.R")

# display top n most abundant genera
n_display <- 10

fname <- "./figures/abund_size_stacked.png"

genus_size <- get_rel_genus(ps) %>%
  dplyr::select(Sample, size.mm, size.name, Genus, Abundance) %>%
  # Rename genera outside top n_display as "Other"
  mutate(
    Genus = ifelse(is.na(Genus) | !(Genus %in% high_ab_genera[1:n_display]), "Other", Genus)
  ) %>%
  group_by(Sample, size.mm, size.name, Genus) %>%
  summarise(
    Abundance = sum(Abundance),
    .groups = "drop"
  ) %>%
  mutate(Genus = factor(Genus, levels = c(high_ab_genera[1:n_display], "Other")))
  
#n_display <- length(unique(genus_size$Genus)) - 1

p <- ggplot(genus_size, aes(x = Sample, y = Abundance, fill = fct_rev(Genus))) +
  # group samples by size
  facet_grid(. ~ size.name, scales = "free_x", space = "free_x", switch = "x") +  
  geom_col(width = 0.95) + # space between same size
  scale_fill_manual(
    values = c("gray", met.brewer(taxa_pal, n_display)),
    name = "Genera"
  ) +
  labs(
    x = "Size",
    y = "Relative Abundance [%]"
  ) +
  theme_minimal(base_size = 10) +
  theme(
    axis.text.x = element_blank(),    # hide sample labels
    axis.ticks.x = element_blank(),
    strip.placement = "outside",      # place strips below the panel
    strip.text.x = element_text(size = 10, margin = margin(t = 5))
  )

# Save plot
ggsave(fname, plot = p, width = 6, height = 4, dpi = 300)