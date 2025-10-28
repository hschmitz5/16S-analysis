size_factored <- c("0-0.85", "0.85-1.4", "1.4-2", "2-2.8", "2.8-4", ">4")
#size_midpoint <- c(0.425, 1.125, 1.7, 2.4, 3.4, 4.5)
size_name <- c("XS", "S", "M", "L", "XL", "XXL")
n_sizes <- length(size_factored)
n_replicates  <- 3

# Import QIIME2 data as phyloseq object
ps <- qiime2R::qza_to_phyloseq(
  features = "../data/table_dada2.qza",
  tree = "../data/rooted_tree.qza",
  taxonomy = "../data/taxonomy.qza",
  metadata = "../data/sample-metadata.tsv"
)

ps@sam_data$size.mm <- factor(ps@sam_data$size.mm, levels = size_factored, ordered = TRUE)
#ps@sam_data$size.midpoint <- size_midpoint[as.numeric(ps@sam_data$size.mm)]
ps@sam_data$size.name <- size_name[as.numeric(ps@sam_data$size.mm)]

# Other Data
eps <- read_excel("../data/EPS_loss.xlsx", range = cell_cols("A:E"))
df <- read_excel("../data/EPS_loss.xlsx", range = cell_cols("G:K"))
eps$size.mm <- factor(eps$size.mm, levels = size_factored, ordered = TRUE)
df$size.mm <- factor(df$size.mm, levels = size_factored, ordered = TRUE)