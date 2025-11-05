library(ANCOMBC)

ps_genus <- readRDS("./ps_genus.rds") 

contrast_mats = list(
  # monotonically increasing
  matrix(c(1, 0, 0, 0, -1, 1, 0, 0, 0, -1, 1, 0, 0, 0, -1, 1),
         nrow = 4, byrow = TRUE),
  # monotonically decreasing
  matrix(c(-1, 0, 0, 0, 1, -1, 0, 0, 0, 1, -1, 0, 0, 0, 1, -1),
         nrow = 4, byrow = TRUE)
)

set.seed(123)
output <- ancombc2(
  data = ps_genus, 
  tax_level = "Genus",
  fix_formula = "size.name",    
  group = "size.name",
  struc_zero = TRUE,
  global = TRUE, pairwise = TRUE, dunnet = TRUE, trend = TRUE,  
  trend_control = list(contrast = contrast_mats,
                       node = list(4, 4),
                       solver = "ECOS",
                       B = 100)
)

saveRDS(output, file = "./ancombc2_genus.rds")
