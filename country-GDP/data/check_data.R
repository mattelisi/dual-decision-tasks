# 
rm(list=ls())
hablar::set_wd_to_script_path()

library(tidyverse)
d <-read_delim("ml01")
str(d)

d$decision <- rep(1:2, (nrow(d)/2))
d$logGDPratio <- d$log_gdp_2 - d$log_gdp_1
d$alGDP <- abs(d$logGDPratio)
d$bin <- cut(d$alGDP, breaks=c(0,1,2,5.5))
d$decision <- factor(d$decision)

d %>%
  group_by(decision, bin) %>%
  summarise(alGDP =mean(alGDP ),
            p_right = mean(rr),
            se = mlisi::binomSEM(accuracy),
            accuracy = mean(accuracy),
            RT= mean(RT)) %>%
  ggplot(aes(x=alGDP, y=accuracy, color=decision, group=decision))+
  geom_point() +
  geom_errorbar(aes(ymin=accuracy-se, ymax=accuracy+se))+
  stat_smooth(data=d, method='glm',method.args=list(family=binomial('probit'))) +
  coord_cartesian(xlim = c(0,3))+
  labs(x="|log GDP ratio|")

