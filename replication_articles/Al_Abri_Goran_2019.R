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

x = seq(0,1000, by=0.1)


exp_dam_10 = damage(x)*poiss(growth(x), y=growth(10))*(1+phi(10))

data = data.frame(x,exp_dam_10,c(rep("10",length(exp_dam_10))))
data %>% ggplot(aes(x=x, y=exp_dam_10))+geom_line()
data %>% ggplot(aes(x=x, y=growth.x.))+geom_line()
names(data) = c("x","y","f_kt")

exp_dam_50 = damage(x)*poiss(growth(x), y=growth(50))*(1+phi(50))
data2 = data.frame(x,exp_dam_50,c(rep("50",length(exp_dam_50))))
names(data2) = c("x","y","f_kt")


exp_dam_100 = damage(x)*poiss(growth(x), y=growth(100))*(1+phi(100))
data3 = data.frame(x,exp_dam_100,c(rep("100",length(exp_dam_100))))
names(data3) = c("x","y","f_kt")

exp_dam_2000 = damage(x)*poiss(growth(x), y=growth(2000))*(1+phi(2000))
data4 = data.frame(x,exp_dam_2000,c(rep("2000",length(exp_dam_2000))))
names(data4) = c("x","y","f_kt")
data_full = rbind(data,data2,data3,data4)

data_full %>% ggplot(aes(x=x,y=y, color=f_kt))+geom_line(size=1.5)+geom_hline(yintercept = 1, size=1.5)
plot(damage(x))

plot(poiss(growth(x),y=growth(2000))*(1+phi(2000)))

plot(poiss(growth(x),y=growth(2000)))
plot(1+phi(2000))

plot(phi(x))


# Part 2 with modified function


exp_dam_10= damage(x)*poiss(growth(x), y=growth(10))*(exp(-(0.02*(x+10)/50))+phi(10))

data = data.frame(x,exp_dam_10,c(rep("10",length(exp_dam_10))))
data %>% ggplot(aes(x=x, y=exp_dam_10))+geom_line()
data %>% ggplot(aes(x=x, y=growth.x.))+geom_line()
names(data) = c("x","y","f_kt")

exp_dam_50 = damage(x)*poiss(growth(x), y=growth(50))*(exp(-(0.02*(x+50)/50)) +phi(50))
data2 = data.frame(x,exp_dam_50,c(rep("50",length(exp_dam_50))))
names(data2) = c("x","y","f_kt")


exp_dam_100 = damage(x)*poiss(growth(x), y=growth(100))*(exp(-(0.02*(x+100)/50))+phi(100))
data3 = data.frame(x,exp_dam_100,c(rep("100",length(exp_dam_100))))
names(data3) = c("x","y","f_kt")

exp_dam_2000 = damage(x)*poiss(growth(x), y=growth(2000))*(exp(-(0.02*(x+2000)/50))+phi(2000))
data4 = data.frame(x,exp_dam_2000,c(rep("2000",length(exp_dam_2000))))
names(data4) = c("x","y","f_kt")
data_full = rbind(data,data2,data3,data4)

data_full %>% ggplot(aes(x=x,y=y, color=f_kt))+geom_line(size=1.5)+geom_hline(yintercept = 1, size=1.5)

# Correlation between two distributions
x = seq(0,1000, by=0.1)

data5 = data.frame(x, poiss(x,y=10), phi(x))

data5 %>% ggplot(aes(x=x, y=poiss.x..y...10.))+geom_line()
data5 %>% ggplot(aes(x=x, y=phi.x.))+geom_line()
y = seq(0,1000, by=0.1)
cor(poiss(x,y),phi(x), method = "spearman")
cor.test(poiss(x,y),phi(x))
