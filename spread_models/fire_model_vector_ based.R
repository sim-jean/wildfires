#### ELLIPTICAL FIRE MODEL ####
library(sf)
library(dplyr)
library(concaveman)
library(ggplot2)
## Worflow description ## 

# 1. Initial matrix

xc         <- 1 
yc         <- 2 # y_c or k
a          <- 5 # major axis length
b          <- 2 # minor axis length
phi        <- -pi/8 # angle of major axis with x axis phi or tau

t          <- seq(0, 2*pi, 0.15) 
X          <- xc + a*cos(t)*cos(phi) - b*sin(t)*sin(phi)
Y          <- yc + a*cos(t)*cos(phi) + b*sin(t)*cos(phi)
plot(X,Y,pch=19, col='blue')
coord_mat  <- data.frame(X,Y,index=0,period=1)


# 2. Spread parameters
a          <- c(5,5,5,5)#c(9,4,3,8)
b          <- c(2,2,2,2)
phi        <-c(pi/3, pi/3, pi/3,pi/3)
max_time   <- 4
new_coord  <- list(coord_mat)

for(time in 1:max_time){
  new_coord2 <- data.frame()
  for(i in 1:nrow(new_coord[[time]])){
    # C'est ici qu'il faut changer : les mécanismes de diffusion ne sont pas fous. Il faudrait les relier à une configuration 
    # du landscape
    # On pourrait peut être définir une fonction de diffusion en fonction des paramètres du landscape et la moduler en fonction des
    # prévisions de vent. 
    if(new_coord[[time]][i,2]<0 & new_coord[[time]][i,1]>3){
      X         <- new_coord[[time]][i,1] + 0.13*cos(t)*cos(phi) - 0.2*sin(t)*sin(phi)
      Y         <- new_coord[[time]][i,2] + 0.13*cos(t)*cos(phi) + 0.2*sin(t)*cos(phi)
    }else if(new_coord[[time]][i,2]>=0 & new_coord[[time]][i,1]<2){
      X         <- new_coord[[time]][i,1] + 0.4*cos(t)*cos(phi) -0.1*sin(t)*sin(phi)
      Y         <- new_coord[[time]][i,2] + 0.4*cos(t)*cos(phi) + 0.1*sin(t)*cos(phi)
    } else{
      X         <- new_coord[[time]][i,1] + 0.2*cos(t)*cos(phi) -0.03* sin(t)*sin(phi)
      Y         <- new_coord[[time]][i,2] + 0.2*cos(t)*cos(phi) +0.03* sin(t)*cos(phi)
    }
    
    df          <- data.frame(index=c(i),X,Y, period=time)
    new_coord2  <- rbind(new_coord2, df)
  }
  try2          <- rbind(coord_mat, new_coord2)
  #try2 %>% mutate(index2 = as.factor(ifelse(try2$index>0, 1,0))) %>% ggplot(aes(x=X,y=Y))+geom_point(aes(color=index2), size=0.1)
  try3          <- st_as_sf(new_coord2[,2:3], coords=c("X","Y"))
  
  #boundary2 <- try3 %>% summarise(geometry=st_combine(geometry)) %>% st_convex_hull()%>%  st_boundary()
 
   boundary <- try3 %>% 
    summarise(geometry=st_combine(geometry)) %>% 
    concaveman()%>%
    st_boundary() %>% 
    st_as_sf()%>%
    st_coordinates()%>% 
    as.data.frame() %>% 
    select(X,Y) %>% mutate(index=0,
                           period=time)

  
  #new_coord2[try4,]%>%ggplot(aes(x=x1,y=y1))+geom_point()
  new_coord[[time+1]] <- boundary
  #assign(paste0("front_",time), boundary)
  print(time)
}
#try2[try4,4] <- 1
#try2[is.na(try2$V4),4] <- 0
# try2 %>% mutate(index2 = as.factor(ifelse(try2$index>0, 1,0))) %>% ggplot(aes(x=x1,y=y1))+geom_point(aes(color=V4))
# Just want to keep the first 
try <- do.call(rbind, new_coord)

#for(time in 1:max_time){
#  try12 <- try %>% subset(period==time)
#  try23 <- st_as_sf(try12, coords=c("x1","y1"))
#  boundary2 <- try23 %>% summarise(geometry=st_combine(geometry))%>% st_convex_hull()%>%st_boundary()
#  }


try %>% mutate(period2 = as.factor(try$period))%>% ggplot(aes(x=X,y=Y))+geom_point(aes(color=period2), size=0.1)



# Define functions for spread -----

# A. Find coordinates of point

# B. Retrieve landscape data
# lscp_coord <- c(floor(new_coord[[time]][i,1]),floor(new_coord[[time]][i,2]))

# C. Put them in the right functional form to define spread or something
# --> Maybe the right moment to look at the method, if estimation is required, maybe focus on simpler functional forms.
# - Need to look into the input data for FWI 
# - Need to look into functional forms for eliptical spreads or look into the method to estimate them?
# - 



