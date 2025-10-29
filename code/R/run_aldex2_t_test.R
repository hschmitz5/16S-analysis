metadata <- get_metadata(ps_filt)

# Generate pairwise combinations
pair_samples <- combn(size$name, 2) %>%
  t() %>%
  as.data.frame(stringsAsFactors = FALSE) %>%
  rename(size1 = V1, size2 = V2) %>%
  # identify samples that are in each size
  mutate(
    samples_size1 = map(size1, ~ metadata %>% filter(size.name == .x) %>% pull(Sample)),
    samples_size2 = map(size2, ~ metadata %>% filter(size.name == .x) %>% pull(Sample)),
    samples = map2(samples_size1, samples_size2, ~ c(.x, .y))
  ) %>%
  dplyr::select(size1, size2, samples) %>%
  # function runs aldex2 on each sample combination
  mutate(
    res = map(samples, function(samples_in_pair) {
      # Subset counts table
      reads <- as.data.frame(ps_filt@otu_table) %>%
        dplyr::select(all_of(samples_in_pair))
      
      # Get conditions
      conds <- metadata$size.name[match(samples_in_pair, metadata$Sample)]
      
      # Run ALDEx2
      aldex(reads, conds, denom = "all", test = "t", effect = TRUE)
    })
  )

saveRDS(pair_samples, file = "../results/aldex_t.rds")

# # Create adjacent pairs
# pair_samples <- data.frame(
#   size1 = size$name[-length(size$name)],  # all except last
#   size2 = size$name[-1]                   # all except first
# ) %>%

# ---- Kruskal Wallis test ----
#
# x <- aldex.clr(reads, conds, mc.samples=128, denom="all")
# kw.test <- aldex.kw(x)
# 
# saveRDS(x, file = "../results/aldex_clr_result.rds")
# saveRDS(kw.test, file = "../results/aldex_kw_result.rds")