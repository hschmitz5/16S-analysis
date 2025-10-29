# define sample names
size <- data.frame(
  ranges = c("0-0.85", "0.85-1.4", "1.4-2", "2-2.8", "2.8-4", ">4"), # mm
  name = c("XS", "S", "M", "L", "XL", "XXL")
)

# define dimensions of sample grouping
n_sizes <- length(size$ranges)
n_replicates  <- 3

# Other Data
eps <- read_excel("../data/EPS_loss.xlsx", range = cell_cols("A:E"))
rheology <- read_excel("../data/EPS_loss.xlsx", range = cell_cols("G:K"))
eps$size.mm <- factor(eps$size.mm, levels = size$ranges, ordered = TRUE)
rheology$size.mm <- factor(rheology$size.mm, levels = size$ranges, ordered = TRUE)