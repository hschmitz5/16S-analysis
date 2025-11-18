rm(list = ls())
source("./code/R/00_setup.R")
source("./code/R/01_load_data.R")
source("./code/R/02_process_ps.R")

fname_ord <- "./figures/ordination-PCoA.png"

# load phyloseq object for all sample sizes
ps_full <- readRDS("./data/ps_ASV_full.rds")

# ps_full: all sample groups
ps.ord <- ordinate(ps_full, "PCoA", "wunifrac")

cols <- c("gray", met.brewer(size_pal, n_sizes))

p <- plot_ordination(ps_full, ps.ord, type="samples", color="size.name") +
  scale_color_manual(values = cols) +
  labs(title="PCoA (wunifrac)", color = "Size") +
  theme_minimal(base_size = 12) +
  theme(
    plot.title = element_text(size = 12)
  ) 

ordination_plot <- p

ggsave(fname_ord, plot = ordination_plot, width = 5, height = 3, dpi = 300)