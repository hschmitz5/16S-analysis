#fname <- "../results/ancombc2_genus.rds" 
get_bc_abund <- function(fname) {
  
  output <- readRDS(fname)
  
  bc_out <- output$bias_correct_log_table
  
  taxonomy <- get_taxonomy(ps_ASV)
  metadata <- get_metadata(ps_ASV)
  
  bc_long <- bc_out %>%
    rownames_to_column("OTU") %>%
    pivot_longer(-OTU, names_to = "Sample", values_to = "bc_abund") %>%
    inner_join(taxonomy, by = "OTU") %>%
    inner_join(metadata, by = "Sample") %>%
    dplyr::select(Sample, size.mm, size.name, Genus, bc_abund) 
  
  return(bc_long)
}
