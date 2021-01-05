
library(jsonlite)
library(tidyverse)


d<-fromJSON("../output/test3.json",simplifyDataFrame = T) %>% 
  filter(phase == "test-vwp") %>% 
  mutate(trialnum = as.character(trial_index - 1))


#trial1_gaze<-d$gaze_data[1] %>% fromJSON(simplifyDataFrame = T)

d2<-map_dfr(d$gaze_data,fromJSON, simplifyDataFrame = T, .id="trialnum") 

d3<-left_join(d, d2, by="trialnum") 
'%>% 
  filter(str_detect(trialID, "test"))'


d3 = d3 %>% 
  mutate(
    portTL_1 = x0,
    portTL_2 = y0,
    portTL_3 = x0 + w,
    portTL_4 = y0 + h,
    portTR_1 = x4,
    portTR_2 = y0,
    portTR_3 = x4 + w,
    portTR_4 = y0 + h,
    portBL_1 = x0,
    portBL_2 = y4,
    portBL_3 = x0 + w,
    portBL_4 = y4 + h,
    portBR_1 = x4,
    portBR_2 = y4,
    portBR_3 = x4 + w,
    portBR_4 = y4 + h,
    gaze_location = case_when(
      (x > portTL_1 & x < portTL_3 & y > portTL_2 & y < portTL_4) ~ 'TL',
      (x > portTR_1 & x < portTR_3 & y > portTR_2 & y < portTR_4) ~ 'TR',
      (x > portBL_1 & x < portBL_3 & y > portBL_2 & y < portBL_4) ~ 'BL',
      (x > portBR_1 & x < portBR_3 & y > portBR_2 & y < portBR_4) ~ 'BR'
      ),
  target_location = case_when(
    str_sub(picTL, 10, -1) == target_pic ~ 'TL',
    str_sub(picTR, 10, -1) == target_pic ~ 'TR',
    str_sub(picBL, 10, -1) == target_pic ~ 'BL',
    str_sub(picBR, 10, -1) == target_pic ~ 'BR'
    ),
  target_look = if_else(gaze_location == target_location, 1, 0),
  time_ds = round(t/100)*100,
  click_acc = if_else(clicked_on == target_location,1,0)) 


d3_summ = d3 %>% group_by(cond,time_ds) %>% summarize(mean_target_look = mean(target_look, na.rm=T))

ggplot(d3_summ %>% filter(time_ds<10000))+
  geom_point(aes(x=time_ds, y=mean_target_look, color = cond))+
  geom_smooth(aes(x=time_ds, y=mean_target_look, color = cond), method = 'loess')+
  geom_vline(aes(xintercept=1000))+
  theme_bw()


d3.1 = d3 %>% filter(trial_index <= 21)
d3.2 = d3 %>% filter(trial_index > 21)
d3.1_summ = d3.1 %>% group_by(cond,time_ds) %>% summarize(mean_target_look = mean(target_look, na.rm=T))
d3.2_summ = d3.2 %>% group_by(cond,time_ds) %>% summarize(mean_target_look = mean(target_look, na.rm=T))

ggplot(d3.1_summ %>% filter(time_ds<10000))+
  geom_point(aes(x=time_ds, y=mean_target_look, color = cond))+
  geom_smooth(aes(x=time_ds, y=mean_target_look, color = cond), method = 'loess')+
  geom_vline(aes(xintercept=1000))+
  theme_bw()

ggplot(d3.2_summ %>% filter(time_ds<10000))+
  geom_point(aes(x=time_ds, y=mean_target_look, color = cond))+
  geom_smooth(aes(x=time_ds, y=mean_target_look, color = cond), method = 'loess')+
  geom_vline(aes(xintercept=1000))+
  theme_bw()
