sam_name <- c("20A", "20B", "20C", "14A", "14B", "14C", "10A", "10B", "10C",
              "7A", "7B", "7C", "5A", "5B", "5C")

ancom_fname <- "../results/ancombc2_genus.rds"
aldex_fname <- "../results/aldex_t.rds"

# absolute counts
ps_ASV <- readRDS("../data/ps_ASV.rds") 

# define sample names
size <- data.frame(
  ranges = levels(ps_ASV@sam_data$size.mm),
  name = levels(ps_ASV@sam_data$size.name)
)

# define dimensions of sample grouping 
n_replicates  <- 3
n_sizes <- length(size$ranges)

# Other Data
eps <- read_excel("../data/EPS_loss.xlsx", range = cell_cols("A:E"))
rheology <- read_excel("../data/EPS_loss.xlsx", range = cell_cols("G:K"))
eps$size.mm <- factor(eps$size.mm, levels = size$ranges, ordered = TRUE)
rheology$size.mm <- factor(rheology$size.mm, levels = size$ranges, ordered = TRUE)
# Spring Pot coefficient
mu <- c(4.19, 3.21, 2.58, 2.39, 1.84)