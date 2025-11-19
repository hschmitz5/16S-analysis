library(ggpattern)
source("./code/R/00_setup.R")
source("./code/R/01_load_data.R")

# Data -------------------------------------------------------------
fname <- "./figures/mass-percent.png"

x0 <- c(0, 0.21, 0.43, 0.60, 1.4, 2.0, 2.8, 4.0, 5.0)   # sieve boundaries
labels <- c("< 0.21", "0.21 - 0.43", "0.43 - 0.60", 
            "0.60 - 1.4", "1.4 - 2.0", "2.0 - 2.8", 
            "2.8 - 4.0", "> 4.0")
mass_percent <- c(27.29, 19.05, 5.05, 11.88, 7.59, 9.85, 10.62, 8.67)

colors <- c("black", "white", "gray", met.brewer(size_pal, n_sizes))

patterns <- c("none", "stripe", "none", "none", "none", "none", "none", "none")

df <- data.frame(
  xmin = x0[-length(x0)],  # removes last element
  xmax = x0[-1],           # removes first element 
  ymin = 0,
  ymax = mass_percent,
  label = factor(labels, levels = labels),
  color = colors,
  pattern = patterns
)

# Plot --------------------------------------------------------------

p <- ggplot(df) +
  geom_rect_pattern(
    aes(xmin = xmin, xmax = xmax, ymin = ymin, ymax = ymax, fill = label, pattern = label),
    color = "black", linewidth = 0.2,  # outline
    pattern_fill = "black", 
    pattern_angle = 45,
    pattern_density = 0.1,
    pattern_spacing = 0.04,
    pattern_key_scale_factor = 0.5
  ) +
  scale_fill_manual(values = colors) +
  scale_pattern_manual(values = patterns) +
  # control x-axis tick labels
  scale_x_continuous(
    breaks = x0[-length(x0)],
    labels = x0[-length(x0)]
  ) +
  labs(
    x = "Granule Diameter [mm]",
    y = "Mass Percentage [%]",
    fill = "",
    pattern = ""
  ) +
  theme_minimal(base_size = 14) +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 45, hjust = 1),
    panel.grid.minor.x = element_blank()
  ) +
  guides(
    fill = guide_legend(byrow = TRUE)
  )

# Save figure -------------------------------------------------------

ggsave(fname, p, width = 6, height = 5, dpi = 300)

# Display
print(p)
