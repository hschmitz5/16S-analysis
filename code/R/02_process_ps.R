get_metadata <- function(ps){
  metadata <- as.data.frame(as.matrix(ps@sam_data)) %>%
  rownames_to_column("Sample") %>%
  mutate(size.mm = factor(size.mm, levels = size$ranges),
         size.name = factor(size.name, levels = size$name))
}

get_taxonomy <- function(ps){
  taxonomy <- as.data.frame(as.matrix(ps@tax_table)) %>%
  rownames_to_column("OTU") 
}

convert_rel <- function(ps){
  table_rel_long <- ps %>%
  # convert to relative abundance
  phyloseq::transform_sample_counts(function(x) x*100/sum(x)) %>%
  # combine with taxonomy and metadata
  phyloseq::psmelt() 
  
  return(table_rel_long)
}
