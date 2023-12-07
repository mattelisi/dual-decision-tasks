rm(list=ls())

hablar::set_wd_to_script_path()

library(tidyverse)

d <- read.delim('01ml')
str(d)

m0 <- glm(accuracy ~ 0 + contrast, family=binomial("probit"), d)
summary(m0)

d$log_contrast <- log(d$contrast)
m1 <- glm(accuracy ~ 0 + I(log_contrast-min(log_contrast)), family=binomial("probit"), d)
summary(m1)

AIC(m0)
AIC(m1)

# sigmas
sigma_m0 <- 1/coef(m0)
sigma_m1 <- 1/coef(m1)

# custom functions
erf <- function(x) 2 * pnorm(x * sqrt(2)) - 1
erf.inv <- function(x) qnorm((x + 1)/2)/sqrt(2)

quantile_fun <- function(p, sigma){
  x <- sigma * sqrt(2) * erf.inv(2*p-1)
  return(x)
}

quantile_fun(0.8, sigma_m0)
exp(quantile_fun(0.8, sigma_m1)+min(d$log_contrast))



library(tidyverse)
library(mlisi)


dag <- d %>%
  group_by(contrast) %>%
  summarise(se = binomSEM(accuracy),
            accuracy = mean(accuracy),
            N = n()) %>%
  mutate(log_contrast = log(contrast)) 

ggplot(dag, aes(x=contrast, y=accuracy))+
  geom_point()+
  geom_errorbar(aes(ymin=accuracy-se, ymax=accuracy+se), width=0) +
  stat_smooth(data=d, method="glm",method.args=list(family=binomial('probit')))+
  geom_vline(xintercept=quantile_fun(0.8, sigma_m0), lty=2)

ggplot(dag, aes(x=log_contrast, y=accuracy))+
  geom_point()+
  geom_errorbar(aes(ymin=accuracy-se, ymax=accuracy+se), width=0) +
  stat_smooth(data=d, method="glm",method.args=list(family=binomial('probit')))+
  geom_vline(xintercept=(quantile_fun(0.8, sigma_m1)), lty=2)
