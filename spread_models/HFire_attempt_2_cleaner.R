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
cell_size = 10


# What needs to be done is to set the landscape over the whole time period, and to update certain elements
# as the code runs : state, fuel.

for(k in 1:100){
  assign(paste0("period",k),          list(state      = as.data.frame(matrix(nrow=side+1, ncol=side+1, 'NI')), # initiate states
                                          fuel       = as.data.frame(matrix(nrow=side+1, ncol=side+1,  10)), # Fuel index of 10 : BAD
                                          wind_speed = as.data.frame(matrix(nrow=side+1, ncol=side+1, 15)), #Wind speed in m.s^-1
                                          wind_dir   = as.data.frame(matrix(nrow=side+1, ncol=side+1, 0))))  #angle, 0=N, 180=S

  }

landscape_variable = list(period0 = list(state      = as.data.frame(matrix(nrow=side+1, ncol=side+1, 'NI')), # initiate states
                                         fuel       = as.data.frame(matrix(nrow=side+1, ncol=side+1,  10)), # Fuel index of 10 : BAD
                                         wind_speed = as.data.frame(matrix(nrow=side+1, ncol=side+1, 15)), #Wind speed in m.s^-1
                                         wind_dir   = as.data.frame(matrix(nrow=side+1, ncol=side+1, 0))))


landscape_fixed    = list( altitude = as.data.frame(matrix(nrow=side+1, ncol=side+1, 100)),
                           slope    = as.data.frame(matrix(nrow=side+1, ncol=side+1, 0)))


####  B. Initiate ignition points
period1$state[10,12] = "I"
period1$state[10,13] = "I"

#### C. Partition landscape into different states for easier study ####
# Set vectors and data for states and directions

# This dataset relates to the comp dataset later on. Comp gives the column for which terrain distance is lower than cumulated
# distance. This column relates to a positional quality wrt the ignited cell : top, bottom etc. As column numbers get out, 
# they are mapped to a row of directions. In this process, direction gives the number to add to existing coordinates to find the 
# cell considered with a positional quality. Ex : top -> comp gives 1 -> 1st row of direction -> (-1,0) needs to be added to existing
# coordinates
direction = data.frame(row=c(-1,-1,0,1,1,1,0,-1), col=c(0,1,1,1,0,-1,-1,-1)) 
states = c("ignited","unburnable","notignited","consumed")
states2= c('I', "U", "NI", "C")
# Set the list of ignited cells
for(i in 1:4){
  stuf = list(coord_time   = data.frame(x=if(length(which(period1$state==states2[i]))==0) 0 else which(landscape_variable$period0$state==states2[i])%%(side+1),
                                        y=if(length(which(period1$state==states2[i]))==0) 0 else which(landscape_variable$period0$state==states2[i])%/%(side+1)+1,
                                        t_ignition   = NA, 
                                        t_extinction = NA), # Coordinates of ignited cells and time of ignition and extinction)
              terrain_dist =  data.frame(top = 0, top_right = 0, right = 0, bottom_right = 0, bottom = 0,
                                         bottom_left = 0, left = 0, top_left = 0), #Terrain distance to adjacent cells
              cumul_dist   =  data.frame(top = 0, top_right = 0, right = 0, bottom_right = 0, bottom = 0,
                                         bottom_left = 0, left = 0, top_left = 0)) # Cumulative distance to adjacent cells
  assign(states[i], stuf)
}
rm(stuf,i)


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
ignited$coord_time
for(i in 1:nrow(ignited$coord_time)){
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
angles                 = (c(0,45,90,135,180,225,270,315)
                          -period1$wind_dir[ignited$coord_time[i,1],ignited$coord_time[i,2]])*pi/180

Rtheta                 = (1-eccentr(10))/(1-eccentr(10)*cos(angles))*Rmax  
# Compute t_n = cell_size/max R_max
t_n                    = cell_size/max(Rmax)
# Min amount of time that can occur in the simulation before the fire may have traveled to an other cell in a single
# time step.

# Compute the distance in all directions (R_theta x t_n)
d_n                    = Rtheta*t_n
ignited$cumul_dist[i,] = d_n
}

#### C. Transition of fire #####
##### i. From Not Ignited to Ignited ####
# Compare lines for terrain distance and cumulated distance
comp                  = as.data.frame(which(ignited$terrain_dist<=ignited$cumul_dist, arr.ind = T))

#  This gives us information :
#   - Row i in comp gives x_i and y_i, the coordinates of ignited cells
#   - Col j gives which cell should be ignited. So if col=1, it means that "top" cell with coordinate x-1 and y should ignite
#     if col=6 , "bottom left" cell to be ignited has coordinates x+1 and y-1

new_ignit            = data.frame(x            = c(ignited$coord_time[comp[,1],1]+direction[comp[,2],][1]),
                                  y            = c(ignited$coord_time[comp[,1],2]+direction[comp[,2],][2]),
                                  t_ignition   = c(t_n,t_n),
                                  t_extinction = c(NA, NA))
colnames(new_ignit)  = names(ignited$coord_time)
# Newly ignited cells are such that : 
# - For existing cells, comp has given the direction in which ignition goes
# - Using comp, directions computes the variation in coordinates needed
# - Coordinates of existing ignited cells are summed to variation

ignited$coord_time   = rbind(ignited$coord_time, new_ignit)

# Update the landscape

update                                            = period1$state
for(i in 1:nrow(ignited$coord_time)){
  update[as.numeric(ignited$coord_time[i,1]), as.numeric(ignited$coord_time[i,2])] = "I"
}
period1$state = update
# Need to find way to append the list of lists : I want to include a second list in the list

##### ii. Switch from ignited to consumed ####
# If cells are surrounded by 8 ignited cells, they no longer contribute to the fire front, and are deemed consumed.
# Can find a way to have a function applied to every cell in the landscape
# Need to evaluate the condition if(all adjacent cells are on fire)
# Take into account the length of the condition, then evaluate it to avoid corners
# And if its ok, then switch landscape value to I. 

# One function for rows and one for columns? 
# Or two loops?
current_state      =  period1$state
for(i in 2:(nrow(current_state)-1)){
  for(j in 2:(ncol(current_state)-1)){
    condition1 =  (period1$state[i-1,j] =="I" & period1$state[i-1,j-1] =="I" & period1$state[i-1,j+1] =="I"&
                     period1$state[i,j-1] =="I" & period1$state[i, j+1]  =="I" & period1$state[i+1,j-1] =="I"&
                     period1$state[i+1,j] =="I" & period1$state[i+1,j+1] =="I")
    condition2 =  (period1$state[i,j]   %in% c("NI","I"))
    if(length((condition1 & condition2 )>0)){
      period1$state[i,j] = "B"
    }
  }
}


##### iii. Include fuel dynamics #####
# Once a cell has been burnt, it can no longer burn
# However, as time goes on, a module of vegetation can be implemented
# to simulate vegetation growth and take into account different fuels

# Would need some fire intensity etc. For now, no vegetation model.