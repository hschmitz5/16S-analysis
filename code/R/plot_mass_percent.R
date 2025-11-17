library(ggplot2)
library(dplyr)

# Data -------------------------------------------------------------
fname <- "./figures/mass-percent.png"

x0 <- c(0, 0.21, 0.43, 0.60, 1.4, 2.0, 2.8, 4.0, 5.0)   # sieve boundaries
labels <- c("< 0.21", "0.21 - 0.43", "0.43 - 0.60", 
            "0.60 - 1.4", "1.4 - 2.0", "2.0 - 2.8", 
            "2.8 - 4.0", "> 4.0")
y <- c(27.29, 19.05, 5.05, 11.88, 7.59, 9.85, 10.62, 8.67)

colors <- c("black", "gray", "#444444", "#663171", "#cf3a36",
            "#ea7428", "#e2998a", "#0c7156")

# Compute widths and midpoints -------------------------------------

w <- diff(x0)  # bar widths
mid <- x0[-length(x0)] + w/2  # midpoint x-coordinates

df <- data.frame(
  mid = mid,
  width = w,
  percent = y,
  label = labels,
  color = colors
)

df$label <- factor(df$label, levels = labels)

# Plot --------------------------------------------------------------

p <- ggplot(df, aes(x = mid, y = percent, fill = label, width = width)) +
  geom_bar(stat = "identity", alpha = 0.8) +
  scale_fill_manual(values = colors, name = "") +
  scale_x_continuous(breaks = x0[-length(x0)], labels = x0[-length(x0)]) +
  labs(x = "Sieve Range [mm]",
       y = "Mass Percent [%]") +
  theme_minimal(base_size = 12) +
  theme(
    legend.position = "top",
    axis.text.x = element_text(angle = 45, hjust = 1)
  ) +
  guides(
    fill = guide_legend(byrow = TRUE)   
  )

# Save figure -------------------------------------------------------

ggsave(fname, p, width = 6, height = 5, dpi = 300)

# Display
print(p)
