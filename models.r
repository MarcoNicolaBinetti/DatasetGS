


# Required packages
library(magrittr) # for pipes
library(nnet) # for the multinom()-function
library(MASS) # for the multivariate normal distribution

# The package
library(MNLpred)

# Plotting the predicted probabilities:
library(ggplot2)
library(scales)


# The data:
data("gles")

# Multinomial logit model:
mod1 <- multinom(vote ~ egoposition_immigration + 
                   political_interest + 
                   income + gender + ostwest, 
                 data = gles,
                 Hess = TRUE)


summary(mod1)



summary(gles$egoposition_immigration)




multinom_model4 <- multinom(complete_formula, data = df_scaled,
                            Hess = TRUE)

mod1<-multinom_model4
gles<-df_scaled

pred1 <- mnl_pred_ova(model = mod1,
                      data = gles,
                      x = "count_HO_lag_1",
                      by = 0.1,
                      seed = "random", # default
                      nsim = 100, # faster
                      probs = c(0.025, 0.975)) # default


pred1$plotdata %>% head()



ggplot(data = pred1$plotdata, aes(x = count_HO_lag_1, 
                                  y = mean,
                                  ymin = lower, ymax = upper)) +
  geom_ribbon(alpha = 0.1) + # Confidence intervals
  geom_line() + # Mean
  facet_wrap(.~ GlobSol, scales = "free_y", ncol = 2) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) + # % labels
  scale_x_continuous(breaks = c(0,0.1,0.2,0.3,0.4,.5,0.6,0.8,0.9,1)) +
  theme_bw() +
  labs(y = "Predicted probabilities",
       x = "Head") # Always label your axes ;)



pred1 <- mnl_pred_ova(model = mod1,
                      data = gles,
                      x = "trade_part_lag_1",
                      by = 0.1,
                      seed = "random", # default
                      nsim = 100, # faster
                      probs = c(0.025, 0.975)) # default


pred1$plotdata %>% head()

ggplot(data = pred1$plotdata, aes(x = trade_part_lag_1, 
                                  y = mean,
                                  ymin = lower, ymax = upper)) +
  geom_ribbon(alpha = 0.1) + # Confidence intervals
  geom_line() + # Mean
  facet_wrap(.~ GlobSol, scales = "free_y", ncol = 2) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) + # % labels
  scale_x_continuous(breaks = c(0,0.1,0.2,0.3,0.4,.5,0.6,0.8,0.9,1)) +
  theme_bw() +
  labs(y = "Predicted probabilities",
       x = "Trade") # Always label your axes ;)



pred1 <- mnl_pred_ova(model = mod1,
                      data = gles,
                      x = "nat_rents_lag_1",
                      by = 0.1,
                      seed = "random", # default
                      nsim = 100, # faster
                      probs = c(0.025, 0.975)) # default


pred1$plotdata %>% head()

ggplot(data = pred1$plotdata, aes(x = nat_rents_lag_1, 
                                  y = mean,
                                  ymin = lower, ymax = upper)) +
  geom_ribbon(alpha = 0.1) + # Confidence intervals
  geom_line() + # Mean
  facet_wrap(.~ GlobSol, scales = "free_y", ncol = 2) +
  scale_y_continuous(labels = percent_format(accuracy = 1)) + # % labels
  scale_x_continuous(breaks = c(0,0.1,0.2,0.3,0.4,.5,0.6,0.8,0.9,1)) +
  theme_bw() +
  labs(y = "Predicted probabilities",
       x = "NR") # Always label your axes ;)

