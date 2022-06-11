## FIRE FUNCTIONS ##

slope_plane <- function(data=topog_alt){
  topog_slope <- matrix(nrow=nrow(data), ncol=ncol(data))
for(i in 1:ncol(data)){
  for(j in 1:nrow(data)){
    
    # Corners
    if(i==1&j==1){
      dzdx <- ((2*data[i+1,j]+data[i+1,j+1])*4/3)/8
      dzdy <- ((2*data[i, j+1]+data[i+1,j+1])*4/3)/8
    } else if(i==res_x & j==res_y){
      dzdx <- -((2*data[i-1,j]+data[i-1,j-1])*4/3)/8
      dzdy <- -((2*data[i,j-1]+data[i-1,j-1])*4/3)/8
    } else if(i==1 & j==res_y){
      dzdx <-  ((2*data[i+1,j-1]+data[i+1,j])*4/3)/8
      dzdy <- -((2*data[i,j-1]+data[i+1,j-1])*4/3)/8
    } else if(i==res_x & j==1){
      dzdx <- -((2*data[i-1,j]+data[i-1,j+1])*4/3)/8
      dzdy <- -((2*data[i,j+1]+data[i-1,j+1])*4/3)/8
    } else {
      dzdx <- ((data[i+1,j-1]+2*data[i+1,j]+data[i+1,j+1])-(data[i-1,j-1]+2*data[i-1,j]+data[i-1,j+1]))/8
      dzdy <- ((data[i-1,j+1]+2*data[i,j+1]+data[i+1,j+1])-(data[i-1,j-1]+2*data[i,j-1]+data[i+1,j-1]))/8
    }
    topog_slope[i,j] <- sqrt(dzdx^2+dzdy^2)*180/pi
  }
}
  return(topog_slope)
}
    
