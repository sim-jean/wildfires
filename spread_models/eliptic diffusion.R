### Eliptic diffusion 
new_coord2 <- data.frame()

for(i in 1:nrow(coord_mat)){
  a          <- 5 # major axis length
  b          <- 2 # minor axis length
  phi        <- pi/3 
  
  x1       <- coord_mat[i,2] + a*cos(t)*cos(phi) - b*sin(t)*sin(phi)
  y1       <- coord_mat[i,3] + a*cos(t)*cos(phi) + b*sin(t)*cos(phi)
  
  df         <- data.frame(index=c(i),x1,y1, period=0)
  new_coord2 <- rbind(new_coord2, df)
}
try2     <- rbind(coord_mat, new_coord2)
try2 %>% mutate(index2 = as.factor(ifelse(try2$index>0, 1,0))) %>% ggplot(aes(x=x1,y=y1))+geom_point(aes(color=index2))
try3     <- st_as_sf(new_coord2[,2:3], coords=c("x1","y1"))

boundary <- try3 %>% summarise(geometry=st_combine(geometry))%>% st_convex_hull()%>%st_boundary()
try4     <- unlist(st_intersects(boundary,try3))

new_coord[[time+1]] <- mutate(new_coord2[try4,], period=(time+1))
}
