source("./code/R/00_setup.R")
source("./code/R/01_load_data.R")
source("./code/R/02_process_ps.R")

fname_ord <- "./figures/ordination-PCoA.png"

ps.ord1 <- ordinate(ps_ASV, "PCoA", "wunifrac")
ps.ord2 <- ordinate(ps_ASV, "PCoA", "unifrac")
# Alternative
# ps.ord <- ordinate(ps_filt, "NMDS", "bray")

cols <- met.brewer(size_pal, n_sizes) 

p1 <- plot_ordination(ps_ASV, ps.ord1, type="samples", color="size.name") + 
  scale_color_manual(values=cols) + 
  labs(
    title="PCoA (wunifrac)",
    color = "Size") 

p2 <- plot_ordination(ps_ASV, ps.ord2, type="samples", color="size.name") + 
  scale_color_manual(values=cols) + 
  labs(
    title="PCoA (unifrac)",
    color = "Size") 

ordination_plot <- p1 + p2 +
  plot_layout(guides = "collect") & 
  theme_minimal(base_size = 12) +  # ensures base_size is applied
  theme(legend.position = "bottom")

ggsave(fname_ord, plot = ordination_plot, width = 8, height = 3, dpi = 300)