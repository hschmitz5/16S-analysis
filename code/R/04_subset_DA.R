get_ancom_taxa <- function(fname_in, p_threshold, high_ab_genera, write2excel = FALSE, fname_out = NULL) {
  
  output <- readRDS(fname_in)
  
  all_sig_taxa <- output$res %>%
    # Combines diff_size* and passed_ss* together
    pivot_longer(
      cols = matches("q_size\\.name|passed_ss_size\\.name"),
      names_to = c(".value","size"),
      names_pattern = "(q|passed_ss)_size\\.name(.*)"
    ) %>%
    filter(q < p_threshold & passed_ss == TRUE & !is.na(taxon)) %>%   
    pull(taxon) %>%
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
    write_xlsx(taxa_df, path = fname_out)
  } 
  return(all_sig_taxa)
}

get_aldex_taxa <- function(fname_in, p_threshold, effect_threshold, high_ab_genera, 
                           write2excel = FALSE, fname_out = NULL) {
  
  output <- readRDS(fname_in) 
  
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
    write_xlsx(taxa_df, path = fname_out)
  }
  return(all_sig_taxa)
}

get_common_taxa <- function(ancom_fname, aldex_fname, p_threshold, effect_threshold, high_ab_genera) {
  # names of significant taxa
  all_taxa_ancom <- get_ancom_taxa(ancom_fname, p_threshold)
  high_ancom <- high_ab_genera[high_ab_genera %in% all_taxa_ancom]
  
  all_taxa_aldex <- get_aldex_taxa(aldex_fname, p_threshold, effect_threshold)
  high_aldex <- high_ab_genera[high_ab_genera %in% all_taxa_aldex]
  
  common_taxa <- intersect(high_ancom, high_aldex) 
  
  return(common_taxa)
}