######## Replication of definitions and hypothesis in Al Abri, Goran, 2019 ####

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

try2 %>% subset(y %in% c('y1','y50','y100','y300','y400', 'y500','y600','y700')) %>% ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+geom_hline(yintercept = 1, size=1.5)

# E. Illustration with redefined function #####

rm(i)
try = matrix(nrow=length(x),ncol=length(y))

for(i in 1:length(x)){
  try[,i] = damage(x[i])*(1+ exp(-(0.2*(growth(x[i])+growth(y))/50))*(poiss(growth(x[i]),growth(y))*phi(y) -1))
}
try3          = as.data.frame(try)
colnames(try3) = c(paste0("y",y))
try3          = cbind(try3,x)
try4          = pivot_longer(try3,starts_with('y'),names_to="y",values_to="value")

try4 %>% subset(y %in% c('y1','y50','y100','y300','y400', 'y500','y600','y700')) %>% ggplot(aes(x=x,y=value, color=y))+
  geom_line(size=1.5)+geom_hline(yintercept = 1, size=1.5)

