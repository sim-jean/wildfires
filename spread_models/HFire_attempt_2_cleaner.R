# HFIRE ATTEMPT WORKING DOCUMENT ######
rm(list=ls())
### 0. Package set-up #####
required_packages  = c("dplyr", "magrittr", "pheatmap", "purrr","ggplot2")
new_packages       = required_packages[!(required_packages %in% installed.packages()[,"Package"]) ]
install.packages(new_packages)
invisible(lapply(required_packages, library, character.only = TRUE))


source(paste0(getwd(),'/functions/spread_functions.R'))
### I. Landscape characteristics #####
#### A. Initial characteristics
# Needs a lot of data wrangling : for now, theoretical landscape
# Can have here a whole schedule of wind speed and directions for an array of periods
# -> I wonder how we use it given that there is an adaptive time step

side = 20

landscape_variable = list( period0= list(state      = as.data.frame(matrix(nrow=side+1, ncol=side+1, 'NI')), # initiate states
                                         fuel       = as.data.frame(matrix(nrow=side+1, ncol=side+1,  10)), # Fuel index of 10 : BAD
                                         wind_speed = as.data.frame(matrix(nrow=side+1, ncol=side+1, 15)), #Wind speed in m.s^-1
                                         wind_dir   = as.data.frame(matrix(nrow=side+1, ncol=side+1, 0))) #angle, 0=N, 180=S
                           )

landscape_fixed    = list( altitude = as.data.frame(matrix(nrow=side+1, ncol=side+1, 100)),
                           slope    = as.data.frame(matrix(nrow=side+1, ncol=side+1, 0)))


####  B. Initiate ignition points
landscape_variable$period0$state[10,12] = "I"
landscape_variable$period0$state[10,13] = "I"

#### C. Partition landscape into different states for easier study ####
# Set the list of ignited cells
states = c("ignited","unburnable","notignited","consumed")
states2= c('I', "U", "NI", "C")
for(i in 1:4){
  stuf = list(coord_time   = data.frame(x=if(length(which(landscape_variable$period0$state==states2[i]))==0) 0 else which(landscape_variable$period0$state==states2[i])%%(side+1),
                                        y=if(length(which(landscape_variable$period0$state==states2[i]))==0) 0 else which(landscape_variable$period0$state==states2[i])%/%(side+1)+1,
                                        t_ignition   = NA, 
                                        t_extinction = NA), # Coordinates of ignited cells and time of ignition and extinction)
              terrain_dist =  data.frame(top = 0, top_right = 0, right = 0, bottom_right = 0, bottom = 0,
                                         bottom_left = 0, left = 0, top_left = 0), #Terrain distance to adjacent cells
              cumul_dist   =  data.frame(top = 0, top_right = 0, right = 0, bottom_right = 0, bottom = 0,
                                         bottom_left = 0, left = 0, top_left = 0)) # Cumulative distance to adjacent cells
  assign(states[i], stuf)
}
rm(i)


### II. Simulation 
# This works for INVARIANT LANDSCAPE ie : no dynamics of fuel, no variation in wind

#### A. Set a mute variable for steps ####

steps = 100 # Specify number of steps
# for(s in 1:steps){}

#### B. Scan ignited cells and compute ex-ante characteristics

for(i in 1:nrow(ignited$coord_time)){
  ignited$terrain_dist[i,] = c(terrain_dist(i,"top"), terrain_dist(i,"top-right"),terrain_dist(i,'right'),terrain_dist(i,"bottom-right"),
                               terrain_dist(i, "bottom"),terrain_dist(i, 'bottom-left'), terrain_dist(i,"left"),terrain_dist(i,"top-left"))
}

#### C. Compute Rmax ####
# Should be computed for all ignited cells
# And stored for next steps, it can be discarded after that.
Rmax = 10

#### D. Compute Rtheta #####
still_ignited = ignited$coord_time %>% subset(is.na(t_ignition))
for(i in 1:nrow(still_ignited)){
  #HERE NEED TO MAKE SURE NOT EXTINCT : may need to subset(is.na(t_extinction))
  # and make sure we have the right 
  # NEED TO CLARIFY THE UPDATING OF IGNITED LIST : if you're in IGNITED, it means the 
  # extinction time is NA, if extinction time is not NA, you get removed, and pushed to the burned list
  # May need to switch to ignited$coord_time back actually
  
# Take the vector of angles from the direction of initial Rmax 
# Need a standardization procedure :
# - Need wind direction used to compute cell Rmax
# - Substract angle of current wind to wind used for Rmax and operate
# HYP : May need to standardize wind data in bins
angles = (c(0,45,90,135,180,225,270,315)-landscape_variable$period0$wind_dir[still_ignited[i,1],still_ignited[i,2]])*pi/180

Rtheta = (1-eccentr(10))/(1-eccentr(10)*cos(angles))*Rmax  
# Compute t_n = cell_size/max R_max
t_n = cell_size/max(Rmax)
# Min amount of time that can occur in the simulation before the fire may have traveled to an other cell in a single
# time step.

# Compute the distance in all directions (R_theta x t_n)
d_n = Rtheta*t_n
}
