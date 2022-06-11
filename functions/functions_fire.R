# Functions #

R_theta <- function(R_max, eccentricity, theta){
  thet   = theta*pi/180
  R_thet = R_max*(1-eccentricity)/(1-eccentricity*cos(thet))
  return(R_thet)
}
