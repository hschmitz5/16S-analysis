rm(list = ls())

library(ALDEx2)

ps <- readRDS("./data/ps_genus.rds") 
size_name <- levels(ps@sam_data$size.name)

metadata <- as.data.frame(as.matrix(ps@sam_data)) %>%
  rownames_to_column("Sample") 

# Generate pairwise combinations
pair_samples <- combn(size_name, 2) %>%
  t() %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  rename(size1 = V1, size2 = V2) %>%
  # identify samples that are in each size
  mutate(
    comparison = paste0(size1, "-", size2),
    # define sample names in pairwise combination (ordering size1 first)
    samples = map2(size1, size2, ~ {
      samples_x <- metadata %>% filter(size.name == .x) %>% pull(Sample)
      samples_y <- metadata %>% filter(size.name == .y) %>% pull(Sample)
      c(samples_x, samples_y)
    }),
    conds = map(samples, function(samples_in_pair) {
      # Get conditions
      conds <- metadata$size.name[match(samples_in_pair, metadata$Sample)]
    }),
    res = map(samples, function(samples_in_pair) {
      # Subset counts table
      reads <- as.data.frame(ps@otu_table) %>%
        dplyr::select(all_of(samples_in_pair))
      # Get conditions
      conds <- metadata$size.name[match(samples_in_pair, metadata$Sample)]
      # Run ALDEx2
      aldex(reads, conds, denom = "all", test = "t", effect = TRUE)
    })
  ) %>%
  dplyr::select(comparison, conds, res)

saveRDS(pair_samples, file = "./results/aldex_t.rds")

# ---- Kruskal Wallis test ----
# 
# reads <- as.data.frame(ps_filt@otu_table)
# conds <- metadata$size.name
# 
# x <- aldex.clr(reads, conds, mc.samples=128, denom="all")
# kw.test <- aldex.kw(x)
# 
# saveRDS(x, file = "../results/aldex_clr_result.rds")
# saveRDS(kw.test, file = "../results/aldex_kw_result.rds")
#
# sig_features <- kw.test %>%
#   filter(kw.eBH < 0.1 & kw.ep < 0.05)