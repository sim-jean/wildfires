######### 1st FIRE ###########
library(pheatmap)
library(purrr)
# Initiate landscape with fire ignition
# Columns and lines
side <- 50


#landscape             <- list(matrix(as.numeric(rbernoulli(side*side, 0.005)), nrow=side, ncol=side)) 
fire              <- list(matrix(0,nrow=side, ncol=side))

# Generic allocation of an ignition using a uniform random variable
fire[[1]][floor(runif(1,min=0,max=side+1)),floor(runif(1,min=0,max=side+1))] <- 1



sum(fire[[1]])
pheatmap::pheatmap(fire[[1]], cluster_rows=F, cluster_cols=F)
for(t in 2:400){
  # In step t+1, get that landscape
  try2           <- fire[[t-1]]
  #init_fire      <- which(landscape[[t-1]]==1,arr.ind=T)
  
  init_fire      <- which(try2==1,arr.ind=T)
  
  pheatmap::pheatmap(try2, cluster_rows=F,cluster_cols = F)
  
  for(i in 1:nrow(init_fire)){
    # Propagation of interior items : 
    if(init_fire[i,1] %in% c(2:side-1) & init_fire[i,2] %in% c(2:side-1)){ 
      try2[(init_fire[i,1]),  (init_fire[i,2]-1)]   <- max(try2[(init_fire[i,1]),  (init_fire[i,2]-1)], rbernoulli(1,0.05))
      try2[(init_fire[i,1]-1),(init_fire[i,2])]     <- max(try2[(init_fire[i,1]-1),(init_fire[i,2])], rbernoulli(1,0.05))
      try2[(init_fire[i,1]+1),(init_fire[i,2])]     <- max(try2[(init_fire[i,1]+1),(init_fire[i,2])], rbernoulli(1,0.05))
      
      try2[(init_fire[i,1]),(init_fire[i,2]+1)]     <- max(try2[(init_fire[i,1]),(init_fire[i,2]+1)], rbernoulli(1,0.05))
    }
    # Propagation of items on rank= 1 and columns within
    else if(init_fire[i,1]==1 & init_fire[i,2] %in% c(2:side-1)){ # Top row
      try2[(init_fire[i,1]),  (init_fire[i,2]-1)] <- max(try2[(init_fire[i,1]),  (init_fire[i,2]-1)], rbernoulli(1,0.05))
      try2[(init_fire[i,1]+1),(init_fire[i,2])]   <- max(try2[(init_fire[i,1]+1),(init_fire[i,2])], rbernoulli(1,0.05))
      try2[(init_fire[i,1]+1),(init_fire[i,2]+1)] <- max(try2[(init_fire[i,1]+1),(init_fire[i,2]+1)], rbernoulli(1,0.05))
    }
    # Propagation of items on top left corner
    else if(init_fire[i,1]==1 & init_fire[i,2]==1){
      try2[(init_fire[i,1]+1),(init_fire[i,2])]   <- max(try2[(init_fire[i,1]+1),(init_fire[i,2])], rbernoulli(1,0.05))
      try2[(init_fire[i,1]),(init_fire[i,2]+1)]   <- max(try2[(init_fire[i,1]),(init_fire[i,2]+1)], rbernoulli(1,0.05))
    }
    #Propagation of top right corner
    else if(init_fire[i,1]==1 & init_fire[i,2]==side){
      try2[(init_fire[i,1]),  (init_fire[i,2]-1)] <- max(try2[(init_fire[i,1]),  (init_fire[i,2]-1)], rbernoulli(1,0.05))
      try2[(init_fire[i,1]+1),(init_fire[i,2])]   <- max(try2[(init_fire[i,1]+1),(init_fire[i,2])], rbernoulli(1,0.05))
    }
    # Propagation of items on rank=10 and columns within
    else if(init_fire[i,1]==side &init_fire[i,2] %in% c(2:side-1)){
      try2[(init_fire[i,1]),  (init_fire[i,2]-1)] <- max(try2[(init_fire[i,1]),  (init_fire[i,2]-1)], rbernoulli(1,0.05))
      try2[(init_fire[i,1]-1),(init_fire[i,2])]   <- max(try2[(init_fire[i,1]-1),(init_fire[i,2])], rbernoulli(1,0.05))
      try2[(init_fire[i,1]),(init_fire[i,2]+1)]   <- max(try2[(init_fire[i,1]),(init_fire[i,2]+1)], rbernoulli(1,0.05))
    }
    # Propagation of items on bottom left corner
    else if(init_fire[i,1]==side & init_fire[i,2] == 1){
      try2[(init_fire[i,1]-1),(init_fire[i,2])]   <- max(try2[(init_fire[i,1]-1),(init_fire[i,2])], rbernoulli(1,0.05))
      try2[(init_fire[i,1]-1),(init_fire[i,2]+1)] <- max(try2[(init_fire[i,1]-1),(init_fire[i,2]+1)], rbernoulli(1,0.05))
      try2[(init_fire[i,1]),(init_fire[i,2]+1)]   <- max(try2[(init_fire[i,1]),(init_fire[i,2]+1)], rbernoulli(1,0.05))
    }
    # Propagation of items on bottom right corner
    else if(init_fire[i,1]==side & init_fire[i,2] == side){
      try2[(init_fire[i,1]),  (init_fire[i,2]-1)] <- max(try2[(init_fire[i,1]),  (init_fire[i,2]-1)], rbernoulli(1,0.05))
      try2[(init_fire[i,1]-1),(init_fire[i,2])]   <- max(try2[(init_fire[i,1]-1),(init_fire[i,2])],   rbernoulli(1,0.05))
    }
    # Propagation of items on first column and rows within
    else if(init_fire[i,1] %in% c(2:side-1) & init_fire[i,1]== 1){
      try2[(init_fire[i,1]-1),(init_fire[i,2])]     <- max(try2[(init_fire[i,1]-1),(init_fire[i,2])], rbernoulli(1,0.05))
      try2[(init_fire[i,1]+1),(init_fire[i,2])]     <- max(try2[(init_fire[i,1]+1),(init_fire[i,2])], rbernoulli(1,0.05))
      
      # Column after
      try2[(init_fire[i,1]),(init_fire[i,2]+1)]     <- max(try2[(init_fire[i,1]),(init_fire[i,2]+1)],   rbernoulli(1,0.05))
    }
    # Propagation of items on last column and rows within
    else if(init_fire[i,1] %in% c(2:side-1) & init_fire[i,1]== side){
      try2[(init_fire[i,1]),  (init_fire[i,2]-1)]   <- max(try2[(init_fire[i,1]),  (init_fire[i,2]-1)], rbernoulli(1,0.05))
      # Same column
      try2[(init_fire[i,1]-1),(init_fire[i,2])]     <- max(try2[(init_fire[i,1]-1),(init_fire[i,2])], rbernoulli(1,0.05))
      try2[(init_fire[i,1]+1),(init_fire[i,2])]     <- max(try2[(init_fire[i,1]+1),(init_fire[i,2])], rbernoulli(1,0.05))
    }
  }
  
  
  fire[[t]] <- try2
}



