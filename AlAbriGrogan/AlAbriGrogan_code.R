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
lambda = function(x,y){
  return(exp(-(0.02*(x+y)/50)))
}

phi = function(x){
  return(1-exp(-0.93*x^0.93))
}

# B. Define x and y, and color gradient####

x = seq(0,750, by=0.5)
y = seq(0,750, by=0.5)
palette_col = c('#fefb0b','#ffe500','#ffce00','#ffb600','#ff9d00','#ff8300','#ff6700',
                '#ff4500','#ff0000')

# C. Plot each function #####

illu1 = data.frame(x,damage(x),growth(x),poiss(x,y=growth(10)),phi(x))

illu1 %>% ggplot(aes(x=x,y=damage.x.))+geom_line()
illu1 %>% ggplot(aes(x=x, y=growth.x.))+geom_line()
illu1 %>% ggplot(aes(x=x, y=poiss.x..y...growth.10..))+geom_line()
illu1 %>% ggplot(aes(x=x, y=phi.x.))+geom_line()

# D. Evaluation of the formulation from the paper ####
try = matrix(nrow=length(x),ncol=length(y))
for(i in 1:length(x)){
  try[i,]  =  damage(x[i])*poiss(growth(x[i]),y=growth(y))*(1+phi(y))
}
try           = as.data.frame(try)
colnames(try) = c(paste0("y",y))
try           = cbind(try,x)
try2          = pivot_longer(try,starts_with('y'),names_to="y",values_to="value")

try2 %>% 
  subset(y %in% c('y0','y50','y100','y300','y400', 'y500','y600','y700')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_manual(values=palette_col, 
                     breaks=c('y0','y1','y50','y100','y300','y400', 'y500','y600','y700'))
# E. Illustration with redefined function #####

rm(i)
try = matrix(nrow=length(x),ncol=length(y))

for(i in 1:length(x)){
  try[i,] = damage(x[i])*(1+ lambda(x=growth(x[i]),y=growth(y))*(poiss(growth(x[i]),growth(y))*phi(y) -1))
}
try3           = as.data.frame(try)
colnames(try3) = c(paste0("y",y))
try3           = cbind(try3,x)
try4           = pivot_longer(try3,starts_with('y'),names_to="y",values_to="value")

try4 %>% 
  subset(y %in% c('y0','y50','y100','y300','y400', 'y500','y600','y700')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_manual(values=palette_col, 
                     breaks=c('y0','y50','y100','y300','y400', 'y500','y600','y700'))
# F. Evaluation of the impact of forest being bounded by fmax=100
fmax=100

x = seq(0,fmax, by=1)
y = seq(0,fmax, by=1)

# Small if loop to use the proper color palette
if(fmax<=100){
  palette_col2 = c("#fefb0b","#ffce00","#ff9d00",
                            "#ff6700","#ff0000")
}else{
  palette_col2 = palette_col
}

try = matrix(nrow=length(x),ncol=length(y))

for(i in 1:length(x)){
  try[i,]  =  damage(x[i])*poiss(growth(x[i]),y=growth(y))*(1+phi(y))
}
try           = as.data.frame(try)
colnames(try) = c(paste0("y",y))
try           = cbind(try,x)
try_keep      = try[,c('x','y0','y1','y10','y50','y100')]
try2          = pivot_longer(try,starts_with('y'),names_to="y",values_to="value")

try2 %>%
  subset(y %in% c('y0',"y1",'y10','y50','y100')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_manual(values=palette_col2, 
                     breaks=c('y0',"y1","y10",'y50','y100','y300','y400', 'y500','y600','y700'))
# With new function 
rm(i)
try = matrix(nrow=length(x),ncol=length(y))

for(i in 1:length(x)){
  try[i,] = damage(x[i])*poiss(growth(x[i]),y=growth(y))*(1+lambda(growth(x[i]),growth(y))*phi(y))
}
try3           = as.data.frame(try)
colnames(try3) = c(paste0("y",y))
try3           = cbind(try3,x)
try3_keep      = try3[,c('x','y0',"y1",'y10','y50','y100')]
try4           = pivot_longer(try3,starts_with('y'),names_to="y",values_to="value")

try4 %>% 
  subset(y %in% c('y0',"y1",'y10','y50','y100')) %>% 
  ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+
  geom_hline(yintercept = 1, size=1.5)+
  scale_color_manual(values=palette_col2, 
                     breaks=c('y0','y1',"y10",'y50','y100','y300','y400', 'y500','y600','y700'))
# Representation: 

try_keep2 = try_keep %>% 
  pivot_longer(starts_with('y'), names_to='y', values_to = "value") %>% 
  cbind(.,"old")
colnames(try_keep2) = c("x","y","value","formulation")

try_keep4 = try3_keep %>% 
  pivot_longer(starts_with("y"), names_to = "y", values_to="value") %>% 
  cbind(.,"new")
colnames(try_keep4) = colnames(try_keep2)

try_keep_final = rbind(try_keep2, try_keep4)
try_keep_final$formulation = as.factor(try_keep_final$formulation)
try_keep_final %>% 
  ggplot(aes(x=x, y=value, color=y, shape=formulation))+
  geom_point(size=1.5)+
  geom_hline(yintercept = 1)+
  scale_shape_manual(values=c(1,8))+
  scale_color_manual(values=palette_col2, breaks=c('y0',"y1",'y10','y50','y100'))+
  theme_minimal()

try_keep_final %>% 
  ggplot(aes(x=x, y=value, color=y, shape=formulation))+
  geom_point(size=1.5)+
  scale_shape_manual(values=c(1,8))+
  scale_color_manual(values=palette_col2, breaks=c('y0',"y1",'y10','y50','y100'))+
  theme_minimal()
# Compute the difference in probability for that range

max_diff = try_keep_final %>% subset(x==fmax&y=="y100")
max_diff = (max_diff[1,3]-max_diff[2,3])/max_diff[2,3]
print(paste0("The maximum overestimation results in a ",100*round(max_diff,2),"% overestimation of expected damage"))

med_diff = try_keep_final %>% subset(x==fmax&y=="y50")
med_diff = (med_diff[1,3]-med_diff[2,3])/med_diff[2,3]
print(paste0("The median overestimation results in a ",100*round(med_diff,2),"% overestimation of expected damage"))

min_diff = try_keep_final %>% subset(x==fmax&y=="y0")
min_diff = (min_diff[1,3]-min_diff[2,3])/min_diff[2,3]
print(paste0("The minimum overestimation results in a ",100*round(min_diff,2),"% overestimation of expected damage"))

min1_diff = try_keep_final %>% subset(x==fmax&y=="y1")
min1_diff = (min1_diff[1,3]-min1_diff[2,3])/min1_diff[2,3]
print(paste0("The minimum overestimation results in a ",100*round(min1_diff,2),"% overestimation of expected damage"))

