size_factored <- c("0-0.85", "0.85-1.4", "1.4-2", "2-2.8", "2.8-4", ">4")
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

# Load PNPS data
pnps <- read_excel("../data/PNPS_conc.xlsx")
pnps.lb <- pnps[, 2:5]
pnps.tb <- pnps[, c(2, 6:8)]