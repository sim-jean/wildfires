#### New functions ###########


l_to_w = function(Ueff,k=1){return(1+0.5592*k*Ueff)}

eccentr = function(Ueff,k=1){
  return(sqrt((1+0.5592*k*Ueff)^2-1)/(1+0.5592*k*Ueff))
}

terrain_dist = function(i, location, coord_x=1, coord_y=2, cell_size=10){
  if(location %in% c("top","Top","TOP")){
    dist = sqrt(cell_size^2 + (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                               - landscape_fixed$altitude[ignited$coord_time[i,coord_x]-1 , ignited$coord_time[i,coord_y]])^2)
  }else if(location %in% c("bottom","Bottom",'BOTTOM')){
    dist = sqrt(cell_size^2 + 
                    (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                     - landscape_fixed$altitude[ignited$coord_time[i,coord_x]+1 , ignited$coord_time[i,coord_y]])^2)
  }else if(location %in% c("Left","left",'LEFT')){
    dist = sqrt(cell_size^2 + 
                    (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                     - landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]-1])^2)
  }else if(location %in% c("Right","right","RIGHT")){
    dist = sqrt(cell_size^2 + 
                    (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                     - landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]+1])^2)
  }else if(location %in% c("Top-left","top-left")){
    dist = sqrt(cell_size^2 + cell_size^2 + 
                  (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                   - landscape_fixed$altitude[ignited$coord_time[i,coord_x]-1 , ignited$coord_time[i,coord_y]-1])^2)
  }else if(location %in% c("Top-right","top-right")){
    dist = sqrt(cell_size^2 + cell_size^2 + 
                  (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                   - landscape_fixed$altitude[ignited$coord_time[i,coord_x]-1 , ignited$coord_time[i,coord_y]+1])^2)
  }else if(location %in% c("Bottom-right","bottom-right")){
    dist = sqrt(cell_size^2 + cell_size^2 + 
                  (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                   - landscape_fixed$altitude[ignited$coord_time[i,coord_x]+1 , ignited$coord_time[i,coord_y]+1])^2)
  }else if(location %in% c("Bottom-left","bottom-left")){
    dist = sqrt(cell_size^2 + cell_size^2 + 
                  (landscape_fixed$altitude[ignited$coord_time[i,coord_x] , ignited$coord_time[i,coord_y]]
                   - landscape_fixed$altitude[ignited$coord_time[i,coord_x]+1 , ignited$coord_time[i,coord_y]-1])^2)
  }
  return(dist)
}









