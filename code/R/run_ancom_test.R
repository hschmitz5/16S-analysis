library(ANCOMBC)

data(atlas1006, package = "microbiome")

# Subset to baseline
pseq = phyloseq::subset_samples(atlas1006, time == 0)

# Re-code the bmi group
meta_data = microbiome::meta(pseq)
meta_data$bmi = recode(meta_data$bmi_group,
                       obese = "obese",
                       severeobese = "obese",
                       morbidobese = "obese")

# Note that by default, levels of a categorical variable in R are sorted 
# alphabetically. In this case, the reference level for `bmi` will be 
# `lean`. To manually change the reference level, for instance, setting `obese`
# as the reference level, use:
meta_data$bmi = factor(meta_data$bmi, levels = c("obese", "overweight", "lean"))
# You can verify the change by checking:
# levels(meta_data$bmi)

# Create the region variable
meta_data$region = recode(as.character(meta_data$nationality),
                          Scandinavia = "NE", UKIE = "NE", SouthEurope = "SE", 
                          CentralEurope = "CE", EasternEurope = "EE",
                          .missing = "unknown")

phyloseq::sample_data(pseq) = meta_data

# Subset to lean, overweight, and obese subjects
pseq = phyloseq::subset_samples(pseq, bmi %in% c("lean", "overweight", "obese"))
# Discard "EE" as it contains only 1 subject
# Discard subjects with missing values of region
pseq = phyloseq::subset_samples(pseq, ! region %in% c("EE", "unknown"))

print(pseq)

set.seed(123)

pseq_perm = pseq
meta_data_perm = microbiome::meta(pseq_perm)
meta_data_perm$bmi = sample(meta_data_perm$bmi)

phyloseq::sample_data(pseq_perm) = meta_data_perm

set.seed(123)
output = ancombc2(data = pseq_perm, tax_level = "Genus",
                  fix_formula = "bmi", rand_formula = NULL,
                  p_adj_method = "holm", pseudo_sens = TRUE,
                  prv_cut = 0, lib_cut = 1000, s0_perc = 0.05,
                  group = "bmi", struc_zero = TRUE, neg_lb = TRUE)

set.seed(123)
# It should be noted that we have set the number of bootstrap samples (B) equal 
# to 10 in the 'trend_control' function for computational expediency. 
# However, it is recommended that users utilize the default value of B, 
# which is 100, or larger values for optimal performance.
output = ancombc2(data = pseq, tax_level = "Family",
                  fix_formula = "age + region + bmi", rand_formula = NULL,
                  p_adj_method = "holm", pseudo_sens = TRUE,
                  prv_cut = 0.10, lib_cut = 1000, s0_perc = 0.05,
                  group = "bmi", struc_zero = TRUE, neg_lb = TRUE,
                  alpha = 0.05, n_cl = 2, verbose = TRUE,
                  global = TRUE, pairwise = TRUE, dunnet = TRUE, trend = TRUE,
                  iter_control = list(tol = 1e-2, max_iter = 20, 
                                      verbose = TRUE),
                  em_control = list(tol = 1e-5, max_iter = 100),
                  lme_control = lme4::lmerControl(),
                  mdfdr_control = list(fwer_ctrl_method = "holm", B = 100),
                  trend_control = list(contrast = list(matrix(c(1, 0, -1, 1),
                                                              nrow = 2, 
                                                              byrow = TRUE),
                                                       matrix(c(-1, 0, 1, -1),
                                                              nrow = 2, 
                                                              byrow = TRUE),
                                                       matrix(c(1, 0, 1, -1),
                                                              nrow = 2, 
                                                              byrow = TRUE)),
                                       node = list(2, 2, 1),
                                       solver = "ECOS",
                                       B = 10))

saveRDS(output, file = "../results/ancombc2_test.rds")
