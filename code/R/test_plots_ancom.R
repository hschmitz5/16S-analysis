fname <- "./results/ancombc2_test.rds"

output <- readRDS(fname)

res_prim = output$res

names(res_prim)

# df_age = res_prim %>%
#   dplyr::select(taxon, ends_with("age")) 
# df_fig_age = df_age %>%
#   dplyr::filter(diff_age == 1) %>%  
#   dplyr::arrange(desc(lfc_age)) %>%
#   dplyr::mutate(direct = ifelse(lfc_age > 0, "Positive LFC", "Negative LFC"),
#                 color = ifelse(diff_robust_age, "aquamarine3", "black"))
# df_fig_age$taxon = factor(df_fig_age$taxon, levels = df_fig_age$taxon)
# df_fig_age$direct = factor(df_fig_age$direct, 
#                            levels = c("Positive LFC", "Negative LFC"))
# 
# fig_age = df_fig_age %>%
#   ggplot(aes(x = taxon, y = lfc_age, fill = direct)) + 
#   geom_bar(stat = "identity", width = 0.7, color = "black", 
#            position = position_dodge(width = 0.4)) +
#   geom_errorbar(aes(ymin = lfc_age - se_age, ymax = lfc_age + se_age), 
#                 width = 0.2, position = position_dodge(0.05), color = "black") + 
#   labs(x = NULL, y = "Log fold change", 
#        title = "Log fold changes as one unit increase of age") + 
#   scale_fill_discrete(name = NULL) +
#   scale_color_discrete(name = NULL) +
#   theme_bw() + 
#   theme(plot.title = element_text(hjust = 0.5),
#         panel.grid.minor.y = element_blank(),
#         axis.text.x = element_text(angle = 60, hjust = 1,
#                                    color = df_fig_age$color))
# fig_age

#### bmi

df_bmi = res_prim %>%
  dplyr::select(taxon, contains("bmi")) 

df_fig_bmi1 = df_bmi %>%
  dplyr::filter(diff_bmilean == 1 | 
                  diff_bmioverweight == 1) %>%
  dplyr::mutate(lfc1 = ifelse(diff_bmioverweight == 1, 
                              round(lfc_bmioverweight, 2), 0),
                lfc2 = ifelse(diff_bmilean == 1, 
                              round(lfc_bmilean, 2), 0)) %>%
  tidyr::pivot_longer(cols = lfc1:lfc2, 
                      names_to = "group", values_to = "value") %>%
  dplyr::arrange(taxon)

df_fig_bmi2 = df_bmi %>%
  dplyr::filter(diff_bmilean == 1 | 
                  diff_bmioverweight == 1) %>%
  dplyr::mutate(lfc1 = ifelse(diff_robust_bmioverweight, 
                              "aquamarine3", "black"),
                lfc2 = ifelse(diff_robust_bmilean, 
                              "aquamarine3", "black")) %>%
  tidyr::pivot_longer(cols = lfc1:lfc2, 
                      names_to = "group", values_to = "color") %>%
  dplyr::arrange(taxon)

df_fig_bmi = df_fig_bmi1 %>%
  dplyr::left_join(df_fig_bmi2, by = c("taxon", "group"))

df_fig_bmi$group = recode(df_fig_bmi$group, 
                          `lfc1` = "Overweight - Obese",
                          `lfc2` = "Lean - Obese")
df_fig_bmi$group = factor(df_fig_bmi$group, 
                          levels = c("Overweight - Obese",
                                     "Lean - Obese"))

lo = floor(min(df_fig_bmi$value))
up = ceiling(max(df_fig_bmi$value))
mid = (lo + up)/2
fig_bmi = df_fig_bmi %>%
  ggplot(aes(x = group, y = taxon, fill = value)) + 
  geom_tile(color = "black") +
  scale_fill_gradient2(low = "blue", high = "red", mid = "white", 
                       na.value = "white", midpoint = mid, limit = c(lo, up),
                       name = NULL) +
  geom_text(aes(group, taxon, label = value, color = color), size = 4) +
  scale_color_identity(guide = "none") +
  labs(x = NULL, y = NULL, title = "Log fold changes as compared to obese subjects") +
  theme_minimal() +
  theme(plot.title = element_text(hjust = 0.5))
fig_bmi