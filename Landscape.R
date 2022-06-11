# LANDSCAPE 
rm(list=ls())
# Set landscape characteristics and pixel resolution ----
res_x <- 20
res_y <- 20
topog<-  list(topog_alt=data.frame(c(rep(1,31)),
                                   c(1, rep(3,29),1),
                                   c(1,3, rep(8,27),3,1),
                                   c(1,3,8, rep(13,25), 8,3,1),
                                   c(1,3,8,13, rep(17,23), 13,8,3,1),
                                   c(1,3,8,13,17, rep(22,21), 17, 13, 8, 3, 1),
                                   c(1,3,8,13,17,22, rep(27,19), 22,17,13,8,3,1), 
                                   c(1,3,8,13,17,22,27, rep(34,17), 27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34, rep(39,15), 34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39, rep(41,13), 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39, 41, rep(38,11),41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39, 41, 38, rep(32,9),38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39, 41, 38,32, rep(31,7),32,38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39, 41, 38,32,31, rep(35,5),31,32,38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39, 41, 38,32,31,35, rep(34,3),35,31,32,38,41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39, 41, 38,32,31,35,34,37,34,35,31,32,38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39,41,38,32,31,35,rep(34,3),35, 31,32,38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39,41,38,32,31,rep(35,5),31,32,38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39,41,38,32,rep(31,7),32,38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39,41,38,rep(32,9),38, 41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39,41,rep(38,11),41, 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,39,rep(41,13), 39,34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,34,rep(39,15), 34,27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,27,rep(34,17), 27,22,17,13,8,3,1),
                                   c(1,3,8,13,17,22,rep(27,19), 22,17,13,8,3,1), 
                                   c(1,3,8,13,17,rep(22,21), 17, 13, 8, 3, 1),
                                   c(1,3,8,13,rep(17,23), 13,8,3,1),
                                   c(1,3,8,rep(13,25), 8,3,1),
                                   c(1,3,rep(8,27),3,1),
                                   c(1,rep(3,29),1),
                                   c(rep(1,31))))
                                   
                                   
                                   
                                   
                                   
                                  
              
colnames(topog[[1]]) <- c(rep("x",31))
pheatmap::pheatmap(as.matrix(topog[[1]]),cluster_rows=F, cluster_cols=F)

# Compute slope 
top            <- topog[[1]][1,]
bottom         <- topog[[1]][nrow(topog[[1]]),]
left           <- c(topog[[1]][1,1], topog[[1]][,1], topog[[1]][nrow(topog[[1]]),1])
right          <- c(topog[[1]][1,ncol(topog[[1]])], topog[[1]][,ncol(topog[[1]]),], topog[[1]][nrow(topog[[1]]), ncol(topog[[1]])])

extended_topog <- rbind(top, topog[[1]],bottom)
extended_topog  <- cbind(left, extended_topog, right)
pheatmap::pheatmap(as.matrix(extended_topog),cluster_rows=F, cluster_cols=F)

topog_slope    <- matrix(NA, ncol=ncol(topog[[1]]), nrow=nrow(topog[[1]]))
cell_size      <- 100
for(i in 1:nrow(topog[[1]])){
  for(j in 1:ncol(topog[[1]])){
    dzdx <- ((extended_topog[i,j+2]+2*extended_topog[i+1,j+2]+extended_topog[i+2,j+2])-
               (extended_topog[i, j]+2*extended_topog[i+1,j]+extended_topog[i+2,j]))/8*cell_size
    dzdy <- ((extended_topog[i+2,j]+2*extended_topog[i+2,j+1]+extended_topog[i+2,j+2])-
               (extended_topog[i,j]+2*extended_topog[i,j+1]+extended_topog[i,j+2]))/8*cell_size
    
    topog_slope[i,j] <- sqrt(dzdx^2+dzdy^2)*pi/180
  }
}
topog[[2]] <- as.data.frame(topog_slope)

pheatmap::pheatmap(as.matrix(topog_slope),cluster_rows=F, cluster_cols=F)

# Build list of landscape characteristics ----
# This would result in a list of lists ie
# - For each week
#     - Get moisture, fuel conditions, WUI maybe, or "external risks"
topog_fuel <- matrix(NA, nrow=nrow(topog[[1]]), ncol=ncol(topog[[1]]))
for(i in 1:nrow(topog[[1]])){
  for(j in 1:ncol(topog[[1]])){
if(j %in% c(10,11,12,13,14) & i %in% c(10,11,12,13,14)) {
      topog_fuel[i,j] <- 8
    }else if(j %in% c(3,4,5,6,7,8,2) & i %in% c(4,6,7,8,2,3,5,23,24,25,26)){
      topog_fuel[i,j] <- 8
    } else if(j<=i){
      topog_fuel[i,j] <- 4
    } else {
      topog_fuel[i,j] <- 2
    }
  }
}
pheatmap::pheatmap(topog_fuel, cluster_cols = F,cluster_rows = F)
topog[[3]] <- as.data.frame(topog_fuel)


topog[[4]] <- c(30, 45)

names(topog) <- c("altitude","slope","fuel","wind")


