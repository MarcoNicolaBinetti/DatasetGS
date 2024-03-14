sum1 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Sudan", year == 2006) %>%
group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum2 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Pakistan", year == 2005) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum3 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "United States", year == 2005) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum4 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Senegal", year == 2018) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum5 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Zambia", year == 2005) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum6 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Ethiopia", year == 2005) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum7 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Turkey", year == 1999) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum8 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Haiti", year == 2010) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

sum9 <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "China", year == 2008) %>%
  group_by(source_country,event_text) %>%
  summarise(dates=list(unique(event_date)),
            sources=list(unique(source_name)))

dlist <- list("Sudan" = sum1, "Pakistan" = sum2, "USA" = sum3, "Senegal" = sum4,
              "Zambia" =sum5, "Ethiopia" = sum6,"Turkey"=sum7,
              "Haiti" = sum8,"China"=sum9)

write.xlsx(dlist,"./examples/normative_agreement.xlsx")

pak <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Pakistan", year == 2005,date_month<"Oct 2005") %>%
  pull(source_country) %>%
  unique()

usa <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "United States", year == 2005) %>%
  pull(source_country) %>%
  unique()

tur <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "Turkey", year == 1999) %>%
  pull(source_country) %>%
  unique()

chn <- df_ICWES_g2g_dis50k %>%
  filter(target_country == "China", year == 2008,date_month<"May 2008") %>%
  pull(source_country) %>%
  unique()



