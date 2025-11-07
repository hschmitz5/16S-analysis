# The bias corrected data are only comparable for individual taxa changes
# This means you cannot make a combined plot like a stacked bar plot unfortunately

library(dplyr)
library(ggplot2)
library(patchwork)

# Load Data
table_bc_long <- get_bc_abund("./results/ancombc2_genus.rds") %>%
  mutate(Genus = factor(Genus, levels = genus_names)) 

table_rel_long <- convert_rel(ps_genus) %>%
  dplyr::select(Sample, size.mm, size.name, Genus, Abundance) %>%
  mutate(Genus = factor(Genus, levels = genus_names))

# Filter both datasets for the same genera
table_bc_long_filt <- table_bc_long %>% filter(Genus %in% high_ab_taxa)
table_rel_long_filt <- table_rel_long %>% filter(Genus %in% high_ab_taxa)

# Merge into one long-format dataframe
merged_long <- full_join(table_bc_long_filt, table_rel_long_filt, 
                         by = c("Sample", "Genus", "size.mm", "size.name")) %>%
  pivot_longer(cols = c(bc_abund, Abundance),
               names_to = "Metric", values_to = "Value")


# ---- Plotting -------

# Compute per-Genus scale & shift
genus_scales <- merged_long %>%
  filter(Genus %in% high_ab_taxa) %>%
  group_by(Genus) %>%
  summarise(
    bc_min = min(Value[Metric == "bc_abund"], na.rm = TRUE),
    bc_max = max(Value[Metric == "bc_abund"], na.rm = TRUE),
    ab_min = min(Value[Metric == "Abundance"], na.rm = TRUE),
    ab_max = max(Value[Metric == "Abundance"], na.rm = TRUE)
  ) %>%
  mutate(
    scale_factor = (bc_max - bc_min) / (ab_max - ab_min),
    shift = bc_min - ab_min * scale_factor
  )

# Add scaled values to merged_long
merged_scaled <- merged_long %>%
  filter(Genus %in% high_ab_taxa) %>%
  left_join(genus_scales, by = "Genus") %>%
  mutate(
    Value_scaled = ifelse(Metric == "Abundance", Value * scale_factor + shift, Value)
  )

plots <- list()  # store individual plots

for (g in high_ab_taxa) {
  df <- merged_scaled %>% filter(Genus == g)
  
  p <- ggplot(df, aes(x = size.name, y = Value_scaled, color = Metric)) +
    geom_point(position = position_jitter(width = 0.2), size = 3) +
    scale_y_continuous(
      name = "Bias-corrected abundance",
      sec.axis = sec_axis(~ (. - unique(df$shift)) / unique(df$scale_factor),
                          name = "Relative abundance [%]")
    ) +
    scale_color_manual(values = c("bc_abund" = "blue", "Abundance" = "red")) +
    theme_bw() +
    theme(
      axis.text.x = element_text(angle = 45, hjust = 1),
      legend.position = "top"
    ) +
    labs(title = g, x = "Size class", color = "Metric")
  
  plots[[g]] <- p
}

# Stack all vertically
combined_plot <- wrap_plots(plots, ncol = 4)

# Save the plot
ggsave("figures/all_high_ab_taxa.png", combined_plot,
       width = 36,
       height = 2 * length(plots),  # ~4 inches per subplot
       dpi = 300,
       limitsize = FALSE)
