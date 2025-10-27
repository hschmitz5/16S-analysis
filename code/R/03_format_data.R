taxonomy <- as.data.frame(ps_rel@tax_table) %>% 
  rownames_to_column("seq")

metadata <- as.data.frame(as.matrix(ps_rel@sam_data)) %>%
  rownames_to_column("sample") %>%
  mutate(size.mm = factor(size.mm, levels = size_factored, ordered = TRUE))

table_abs <- as.data.frame(ps_filt@otu_table) 

table_rel <- as.data.frame(ps_rel@otu_table) %>% 
  rownames_to_column("seq")

# convert table_rel to long data frame
table_rel_long <- table_rel %>% 
  pivot_longer(cols = !seq, names_to = "sample", values_to = "rel_ab") %>% # make a "long" dataframe
  left_join(taxonomy, join_by(seq)) %>% # join taxonomy by the sequence ID
  left_join(metadata, join_by(sample)) # join metadata by the sample ID

# ---- optional ------
# This can help to double check results in Excel

#library(writexl)

# removes some columns from taxonomy
#tax_short <- taxonomy %>%
#  group_by(Genus,Species,seq) %>%
#  summarise()

# Adds table_rel to taxonomy
#table_rel_wide <-  tax_short %>%
#  left_join(table_rel, join_by(seq))  # join taxonomy by the sequence ID

#write_xlsx(table_rel_wide, "./results/table_rel_wide.xlsx")