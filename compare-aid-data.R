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
  mutate(n=sum(!is.na(unocha)))%>%
  group_by(year) %>%
  mutate(mean_aid=mean(Hum_plus_ER_aid_tot,na.r=T))

# Check correlation with AidData in overlap years - 0.8
vars<- df[, sapply(df, is.numeric)]
cor(vars,use = "complete.obs")

# Plot 2010-2019 by country
ggplot(subset(df,n>0)) + 
  geom_line(aes(year,Hum_plus_ER_aid_tot,group=iso3c),colour="black") + 
  geom_line(aes(year,unocha,group=iso3c), colour="red") + facet_wrap(~iso3c)

# Find ratio for mean aid level - 6.5
unocha_short<-df %>%
  filter(year<2014)

ratio<-mean(unocha_short$mean_unocha/unocha_short$mean_aid, na.rm=T)


# Join to disaster aid data
df<-full_join(df_AID_dis50k_y,unocha_long) %>%
  filter(year>2009,year<2014) %>%
  group_by(iso3c) %>%
  mutate(n=sum(!is.na(unocha)))

means <- c()
for (year in unique(df$year)) {
  value <- mean(df$unocha[df$year <= year],na.rm=T)
  means <- c(means, value)
}  # Divide by ratio from analysis in compare-aid-data.R
means_df <- data.frame(year = unique(df$year), mean_unocha2 = means)

df <-df %>%
  left_join(means_df)

# Only 0.4 correlation with disaster aid...
vars<- df[, sapply(df, is.numeric)]
cor(vars,use = "complete.obs")

# Find ratio for mean aid level - 3.9 (13.9 median)
ratio<-mean(df$mean_unocha2/df$year_mean_Hum_plus_ERaid, na.rm=T)


