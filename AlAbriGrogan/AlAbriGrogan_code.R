######## Replication of definitions and hypothesis in Al Abri, Goran, 2019 ####
lapply(c("dplyr",'tidyr',  "magrittr", "ggplot2"), require, character.only=T)

# A. Define functions as in Table 1 ####

damage = function(x){
  return(exp(-1*(0.1/x)))
}
growth = function(x){
  return(0.25*((5+x)*x^0.47))
}
poiss = function(x,y){
  return(1 - exp(-(0.02*(x+y)/50)))
}

phi = function(x){
  return(1-exp(-0.93*x^0.93))
}

# B. Define x and y ####

x = seq(0,750, by=0.5)
y = seq(0,750, by=0.5)

# C. Plot each function #####

illu1 = data.frame(x,damage(x),growth(x),poiss(x,y=growth(10)),phi(x))

illu1 %>% ggplot(aes(x=x,y=damage.x.))+geom_line()
illu1 %>% ggplot(aes(x=x, y=growth.x.))+geom_line()
illu1 %>% ggplot(aes(x=x, y=poiss.x..y...growth.10..))+geom_line()
illu1 %>% ggplot(aes(x=x, y=phi.x.))+geom_line()

# D. Evaluation of the formulation from the paper ####
try = matrix(nrow=length(x),ncol=length(y))
for(i in 1:length(x)){
  try[,i]  =  damage(x[i])*poiss(growth(x[i]),y=growth(y))*(1+phi(y))
}
try           = as.data.frame(try)
colnames(try) = c(paste0("y",y))
try           = cbind(try,x)
try2          = pivot_longer(try,starts_with('y'),names_to="y",values_to="value")

try2 %>% 
  subset(y %in% c('y1','y50','y100','y300','y400', 'y500','y600','y700')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_discrete(breaks=c('y1','y50','y100','y300','y400', 'y500','y600','y700'))

# E. Illustration with redefined function #####

rm(i)
try = matrix(nrow=length(x),ncol=length(y))

for(i in 1:length(x)){
  try[,i] = damage(x[i])*(1+ exp(-(0.2*(growth(x[i])+growth(y))/50))*(poiss(growth(x[i]),growth(y))*phi(y) -1))
}
try3           = as.data.frame(try)
colnames(try3) = c(paste0("y",y))
try3           = cbind(try3,x)
try4           = pivot_longer(try3,starts_with('y'),names_to="y",values_to="value")

try4 %>% 
  subset(y %in% c('y1','y50','y100','y300','y400', 'y500','y600','y700')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_discrete(breaks=c('y1','y50','y100','y300','y400', 'y500','y600','y700'))

# F. Evaluation of the impact of forest being bounded by fmax=100
x = seq(0,500, by=2)
y = seq(0,500, by=2)

try = matrix(nrow=length(x),ncol=length(y))

for(i in 1:length(x)){
  try[i,]  =  damage(x[i])*poiss(growth(x[i]),y=growth(y))*(1+phi(y))
}
try           = as.data.frame(try)
colnames(try) = c(paste0("y",y))
try           = cbind(try,x)
try_keep      = try[,c('x','y0','y10','y50','y100')]
try2          = pivot_longer(try,starts_with('y'),names_to="y",values_to="value")

try2 %>%
  subset(y %in% c('y0','y10','y50','y100')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_discrete(breaks=c('y0','y10','y50','y100','y400', 'y500','y600','y700'))

# With new function 
rm(i)
try = matrix(nrow=length(x),ncol=length(y))

for(i in 1:length(x)){
  try[i,] = damage(x[i])*(1+ exp(-(0.2*(growth(x[i])+growth(y))/50))*(poiss(growth(x[i]),growth(y))*phi(y) -1))
}
try3           = as.data.frame(try)
colnames(try3) = c(paste0("y",y))
try3           = cbind(try3,x)
try3_keep      = try3[,c('x','y0','y10','y50','y100')]
try4           = pivot_longer(try3,starts_with('y'),names_to="y",values_to="value")

try4 %>% 
  subset(y %in% c('y0','y10','y50','y100')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_discrete(breaks=c('y0','y10','y50','y100','y400', 'y500','y600','y700'))

# Check the differential in probability caused by the wrong definition
try_keep_final2 = cbind(try_keep, try3_keep[,c('y0','y10','y50','y100')])
colnames(try_keep_final2) = c("x",'y0_old',"y10_old","y50_old","y100_old",'y0_new',"y10_new","y50_new",'y100_new')

try_keep_final2 = try_keep_final2 %>% mutate(diff0  = y0_new-y0_old,
                                             diff10 = y10_new-y10_old, 
                                             diff50 = y50_new-y50_old, 
                                             diff100 = y100_new-y100_old)
try_keep_final2b = try_keep_final2 %>% 
  select(x,diff0,diff10, diff50, diff100) %>% 
  pivot_longer(starts_with("diff"),values_to = "diff",names_to="y")

try_keep_final2b %>% ggplot(aes(x=x,y=diff, color=y ))+geom_line()

try_keep = try_keep %>% 
  pivot_longer(starts_with('y'), names_to='y', values_to = "value") %>% 
  cbind(.,"old")
colnames(try_keep) = c("x","y","value","formulation")

try3_keep = try3_keep %>% 
  pivot_longer(starts_with("y"), names_to = "y", values_to="value") %>% 
  cbind(.,"new")
colnames(try3_keep) = colnames(try_keep)

try_keep_final = rbind(try_keep, try3_keep)
try_keep_final$formulation = as.factor(try_keep_final$formulation)
try_keep_final %>% 
  ggplot(aes(x=x, y=value, color=y, shape=formulation))+
  geom_point(size=1.5)+
  geom_hline(yintercept = 1)+
  scale_shape_manual(values=c(1,8))+
  scale_color_manual(values=c("gold1","darkorange1","coral", "red"), breaks=c('y0','y10','y50','y100'))+
  theme_minimal()

