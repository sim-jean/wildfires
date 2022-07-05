#### New functions ###########


l_to_w = function(Ueff,k=1){return(1+0.5592*k*Ueff)}

eccentr = function(Ueff,k=1){
  return(sqrt((1+0.5592*k*Ueff)^2-1)/(1+0.5592*k*Ueff))
}

