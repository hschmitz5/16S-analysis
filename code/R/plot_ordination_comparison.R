rm(list = ls())
library(cowplot)
source("./code/R/00_setup.R")
source("./code/R/01_load_data.R")
source("./code/R/02_process_ps.R")

fname_ord <- "./figures/ordination-comparison.png"

# load phyloseq object for all sample sizes
ps_full <- readRDS("./data/ps_ASV_full.rds")

# ps: subset
ps.ord1 <- ordinate(ps, "PCoA", "wunifrac")
# ps_full: all sample groups
ps.ord2 <- ordinate(ps_full, "PCoA", "wunifrac")

cols <- met.brewer(size_pal, n_sizes)

p1 <- plot_ordination(ps, ps.ord1, type="samples", color="size.name") +
  scale_color_manual(values = cols) +
  labs(title="Granular biomass", color = "Size") +
  theme_minimal(base_size = 12) +
  theme(plot.title = element_text(size = 12)) +
  guides(color = "none")

p2 <- plot_ordination(ps_full, ps.ord2, type="samples", color="size.name") +
  scale_color_manual(values = c("gray", cols)) +
  labs(title="Flocs & granules", color = "Size") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 12),   
    legend.position = "bottom"
  ) +
  guides(color = guide_legend(nrow = 1))

# Extract the legend
leg <- get_legend(p2)

# Remove legend from p2
p2_clean <- p2 + theme(legend.position = "none")

ordination_plot <- (p1 | p2_clean) /
  patchwork::wrap_elements(full = leg) +   # add legend
  plot_layout(heights = c(10, 1)) +        # allocate space: 10 units for plots, 1 unit for legend
  plot_annotation(
    title = "PCoA (wunifrac)"
  ) &
  theme(
    plot.title = element_text(hjust = 0.5)  # center the title
  )

ggsave(fname_ord, plot = ordination_plot, width = 8, height = 3, dpi = 300)