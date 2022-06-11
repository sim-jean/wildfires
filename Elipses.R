### ATTEMPT AT TRUNFIO ###

lat <- matrix(0,nrow=30, ncol=30)



# Set the center in 0



slope <- (y[2]-y[1])/(x[2]-x[1])


y1 <- -(b/a)*sqrt(a^2-envel^2)
y2 <- -y1
yf <- c(y1,y2)

envel2 <- c(envel,envel)

el2 <- data.frame(envel2, yf)
el <- data.frame(f1,f2)



el %>% ggplot(aes(x=x,y=y))+geom_point()





# Set the foci with c
c=3

x <- c(-c,c)
y <- c(0,0)

# Set the vertices with a
a <- c+3
# Set the minor semi axis
b <- sqrt(a^2-c^2)


envel <- c(seq(from=-a,to=a,by=0.5))

# Get the points

y1 <- -(b/a)*sqrt(a^2-envel^2)
y2 <- -y1
yf <- c(y1,y2)

envel2 <- c(envel,envel)

el2 <- data.frame(envel2, yf)

el2 %>% ggplot(aes(x=envel2,y=yf))+geom_point()

# Formula with eccentricity : 
# e=c/a
# Now :
e<-0.99

y1 <- sqrt((a^2-envel^2)*(1-e^2))
y2 <- -y1
yf <- c(y1,y2)

envel2 <- c(envel,envel)

el2 <- data.frame(envel2, yf,1)
colnames(el2) <- c("x","y","name")
el2 %>% ggplot(aes(x=envel2,y=yf))+geom_point()

e <- 0.1

y1 <- sqrt((a^2-envel^2)*(1-e^2))
y2 <- -y1
yfb <- c(y1,y2)


el4 <- data.frame(envel2, yfb,2)
colnames(el4) <- c("x","y","name")
e <- 0.5

y1 <- sqrt((a^2-envel^2)*(1-e^2))
y2 <- -y1
yfc <- c(y1,y2)

el3 <- data.frame(envel2, yfc,3)
colnames(el3) <- c("x","y","name")

el2%>%rbind(el4)%>%rbind(el3) %>% ggplot(aes(x=x,y=y, color=name))+geom_point()


### Attempt to elipses that are not centered in 0

foci_x1     <- 0
foci_x2     <- 6
center_x    <- (foci_x2-foci_x1)/2

# set a and vertices
a           <- center_x+2

# Center vertices
vertex_x1   <- -a
vertex_x2   <- +a

# Set eccentricity

eccentricity <- center_x/a

# Set point values

envel <- c(seq(from=vertex_x1, to=vertex_x2, by=0.5))

y1 <- sqrt((a^2-envel^2)*(1-eccentricity^2))
y2 <- -y1
yfb <- c(y1,y2)

envel2 <- c(rep(envel+center_x,2))

el4 <- data.frame(envel2, yfb,2)
colnames(el4) <- c("x","y","name")

el4 %>% ggplot(aes(x=x, y=y))+geom_point()+geom_vline(xintercept=3)

#### Next : move onto slope

# Input angle
theta = 78
# Change into radian
theta = theta*pi/180

cos(theta)
sin(theta)

test <- data.frame(c(0,cos(theta)), c(0,sin(theta)))
colnames(test) <- c("x","y")
test %>% ggplot(aes(x=x, y=y))+geom_line()


######### Other philosophy : 
# Get the initial point of the 
