# This script compares AidData with a potential extension to 2021.

# Using the previous version of this dataset - UNOCHA Global Humanitarian Overview:
# https://data.humdata.org/dataset/global-humanitarian-overview-2024-figures

# The new 2024 release currently has errors in the years - once UNOCHA fix this we can get 2010-2021.
# For now we have 2010-2019 from the 2021 release.

# Includes only funding linked to a humanitarian response plan, regional plan or flash appeal
# This means the responses are coordinated by the UN, so need to consider normative agreement bias.

# Covers 38/124 countries receiving funding in AidData in the overlapping period
n_distinct(df_aid_sec$iso3c[df_aid_sec$year>2009&df_aid_sec$Hum_plus_ER_aid_tot>0])

unocha<-read_excel("UNOCHA Funding received.xlsx")

unocha_long <-pivot_longer(unocha,2:11, names_to="year", values_to="unocha") %>%
  dplyr::rename(iso3c=`Country Code`)
  
unocha_long$year<-as.numeric(unocha_long$year)
unocha_long<-drop_na(unocha_long,unocha)

unocha_long<-unocha_long%>% group_by(year) %>%
mutate(mean_unocha=mean(unocha)) %>% ungroup()


# Join to full aid data
df<-full_join(df_aid_sec,unocha_long) %>%
  filter(year>2009,year<2020) %>%
  group_by(iso3c) %>%
  mutate(n=sum(!is.na(unocha)))

# Check correlation with AidData in overlap years: 90 per cent!
vars<- df[, sapply(df, is.numeric)]
cor(vars,use = "complete.obs")

# Plot 2010-2019 by country
ggplot(subset(df,n>0)) + 
  geom_line(aes(year,Hum_plus_ER_aid_tot,group=iso3c),colour="black") + 
  geom_line(aes(year,unocha,group=iso3c), colour="red") + facet_wrap(~iso3c)

# Find ratio for mean aid level
unocha_short<-df %>%
  filter(year<2014)

ratio<-mean(unocha_short$mean_unocha/unocha_short$year_mean_Hum_plus_ERaid, na.rm=T)



