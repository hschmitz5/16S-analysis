get_ancom_taxa <- function(ancom_fname, high_ab_genera, write2excel) {
  
  output <- readRDS(ancom_fname)
  
  all_sig_taxa <- output$res %>%
    rename(Genus = taxon) %>%
    # Combines diff_size* and passed_ss* together
    pivot_longer(
      cols = matches("diff_size\\.name|passed_ss_size\\.name"),
      names_to = c(".value","size"),
      names_pattern = "(diff|passed_ss)_size\\.name(.*)"
    ) %>%
    filter(diff & passed_ss & !is.na(Genus)) %>%   
    pull(Genus) %>%
    unique() 
    
  # --- Write Data to Excel
  if (isTRUE(write2excel)) {
    # names of significant taxa
    high_DA_taxa <- high_ab_genera[high_ab_genera %in% all_sig_taxa]
    low_DA_taxa <- all_sig_taxa[!all_sig_taxa %in% high_DA_taxa]
    
    # Make a single data frame with two columns
    taxa_df <- data.frame(
      high_abundance = c(sort(high_DA_taxa), rep(NA, length(low_DA_taxa) - length(high_DA_taxa))),
      low_abundance  = sort(low_DA_taxa)
    )
    # Write to Excel
    write_xlsx(taxa_df, path = "../results/ANCOM_taxa.xlsx")
  } 
  return(all_sig_taxa)
}

get_aldex_taxa <- function(aldex_fname, p_threshold, effect_threshold, high_ab_genera, write2excel) {
  
  output <- readRDS(aldex_fname) 
  # Join taxonomy with aldex results
  taxonomy <- get_taxonomy(ps_ASV)
  
  all_sig_taxa <- output %>%
    mutate(
      sig_taxa = map(res, ~ .x %>%
                       rownames_to_column("Genus") %>%
                       filter(wi.eBH < p_threshold & abs(effect) > effect_threshold
                              & !is.na(Genus)) %>%
                       pull(Genus)
      )
    ) %>%
    pull(sig_taxa) %>%
    unlist() %>%
    unique() 
  
  # --- Write Data to Excel
  if (isTRUE(write2excel)) {
    # names of significant taxa
    high_DA_taxa <- high_ab_genera[high_ab_genera %in% all_sig_taxa]
    low_DA_taxa <- all_sig_taxa[!all_sig_taxa %in% high_DA_taxa]
    
    # Make a single data frame with two columns
    taxa_df <- data.frame(
      high_abundance = c(sort(high_DA_taxa), rep(NA, length(low_DA_taxa) - length(high_DA_taxa))),
      low_abundance  = sort(low_DA_taxa)
    )
    # Write to Excel
    write_xlsx(taxa_df, path = "../results/ALDEx2_taxa.xlsx")
  }
  return(all_sig_taxa)
}

get_common_taxa <- function() {
  # names of significant taxa
  all_taxa_ancom <- get_ancom_taxa(ancom_fname, write2excel = FALSE)
  high_ancom <- high_ab_genera[high_ab_genera %in% all_taxa_ancom]
  
  all_taxa_aldex <- get_aldex_taxa(aldex_fname, p_threshold = 0.05, effect_threshold = 1, write2excel = FALSE)
  high_aldex <- high_ab_genera[high_ab_genera %in% all_taxa_aldex]
  
  common_taxa <- intersect(high_ancom, high_aldex) 
  
  return(common_taxa)
}