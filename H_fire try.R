# Attempt at H Fire #
source("functions_fire.R")
# I. Set the landscape

## A. Use an artificial landscape
side <- 40
landscape <- list(matrix(0,nrow=side, ncol=side))
landscape[[1]][35,20] <- 1
pheatmap::pheatmap(landscape[[1]], cluster_cols = F, cluster_rows = F)


cell_size = 10

# II. Fire Spread Model
## A. Efficient wind and maximum spread 
# Should be improved with Rothermel's model and crucial data here. 

U_eff = 5
R_max = 6

# Assign R_max to landscape assuming constant windspeed and direction

landscape[[2]] <- matrix(U_eff, nrow=40,ncol=40)
landscape[[3]] <- matrix(R_max, nrow=40,ncol=40)

## B. Elipse characteristics
# Get length to width ratio and set correction factor
k     = 1
lw    = 1+0.5592*k*U_eff
# Set eccentricity
eccentricity = sqrt(lw^2-1)/lw
# Set angle for synthetic landscape here
# Widn is said to be coming from 180°. It means it goes to 90°
# Set wind origin coordinates
origin    = 180
theta    = origin-90 # shift by 90 degrees to have the direction where it goes
# Apply R_theta
R_theta(R_max=R_max, eccentricity = eccentricity, theta=theta)

## C. Adaptive time step 

# à Améliorer : find out how to apply R_theta to all cells with differing theta?
delta_t = cell_size / max(apply(R_theta))

## D. Cell characteristics
# Need to code for cells and direction here

#########################################################################################################################################
# I. SET LANDSCAPE CHARACTERISTICS #####
# A. Import relevant data and store it ####
#   -> Carefully design storage for VARIABLE/INVARIANT information : fuel, wind, temperature / slope, altitude

#   Considering V variable info and T period, does this mean I have to have VxT rasters?
# B. Initiate automata states
#   -> Can depend on some features, if data is absent for example, can be that it is unburnable
#   -> 

# C. PROVISIONAL : Partition landscape into different states for easier study
# Set the list of ignited cells
    # ignited      <- list()
    # ignited[[1]] <- data.frame(x=0,y=0,t_ignition, t_extinction) # Coordinates of ignited cells and time of ignition and extinction
    # ignited[[2]] <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) #Terrain distance to adjacent cells
    # ignited[[3]] <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) # Cumulative distance to adjacent cells
# Repeat with CONSUMED and NOT-IGNITED

# REMARKS : 
#  -> 1. How do we keep track of time here, and how do we update overall landscape?
#  -> Response : keep time with coordinates

#  -> 2. How do we make sure that that the landscape is updated? 
#              It can make sense to partition the landscape for calculations, and have an updating
#              procedure for visual representation of coordinates by state of the automata and period?
#  -> 3. This raises the issue of how to keep track of time and map things by time. 

## II. Simulation  ####
# Initiate simulation period
  # -> REMARK : how do we keep track of the adaptive time step? 
  # -> Do I want to have a mute variable t that covers the simulation periods
  #    while updating actual time with adaptive time step?

# A. Get ignited cells and characteristics ####
    
    # Idea/example: select(landscape[[1]]==1)
    # With the idea that landscape[[1]] reflects the state of the automata
    # Update conditions frop variable characteristics from part I (landscape profile)


# B. For each cell that is ignited : get R_theta and distance ####
  
  # Compute the R_theta for adjacent cells
    # Take the vector of angles
    # Get the R_max for the cell and STORE IT : storage is the issue here. 
    # Get the vector of R_theta

  # Compute t_n = cell_size/max R_max

  # Compute the distance in all directions (R_theta x t_n) 
  # and update ignited[[3]] (accumulated distances)
    # --> REMARK  : This is where the storage is critical

# C. Transition of fire #####
  # Transition should start with a screening of states
  # and focus only on cells susceptible to change their states. 
  # This would mean focus on ignited cells and their neighborhood, conditional on them
  # not being consumed or unburnable

  # i. Set of cells to be considered : ignited with time of extinction == NA ####

  # For all directions, compare same lines across ignited[[2]] and ignited[[3]]:
    # if accumulated distance (ignited[[3]]) is larger than terrain distance (ignited[[2]])
    # and cells are not unburnable, or consumed
    # => then set cell to ignited

    # Question : should the landscape[[1]] track that, overall? 
    # Even if yes, do we need an other dataset to work with? 

      # Update partly the list ignited cells : 
          # Coordinates
          # Distance accumulated
          # Terrain distance
          # Time of ignition and extinction

  # ii. if all adjacent cells are ignited, set to consumed #####
      # Check if all adjacent cells are ignited
      # if yes
        # append a new cell to the burnt list with its coordinates
        # set extinction time to current period of time
        # update burnt list as the cells which have an extinction time different from NA

  # --> Question : is it necessary to store ignition time and extinction time?
  # --> Answer : Yes

  # iii. Deal with slop-over
    # if accumulated distance is larger than terrain distance
    # Update cumulative distance that the fire has traveled across all directions

# D. Update the landscape #####

  # The issue here is to collect the data on all the lists of states
  # to have a visualization of the landscape across time.
  # REMARK 1 : Need to be able to store raster data with time to plot it with time

  # So maybe I need to work with subsets of the landscape data along the loop rather than
  # having different lists?
  
  # If not : 
  # Take the coordinates of cells in each state list and assign the state
  # on the landscape.
  # REMARK 2 : the issue of time remains here, the expansion of newly ignited cells 
  # in each time step.
  # REMARK 3 : maybe there is a visualization technique for raster data with different attributes? 
  # Like there could be something of a time attribute for the transition
  # --> This issue of landscape visualization is tricky...
  # OR the trick could be to assign a value of cells ignited on the matrix landscape that takes 
  # time : unburnable is -2, consumed is -1, not ignited is 0, and ignited belongs to 1:T
  # There could be a conflict of visualization once cells are burnt
  # ATTEMPT 1 : try on the pheatmap function in the bernoulli model to set the values not to 0-1 but
  # change into something if(rbernoulli(1,0.05)==T){take value t}


                                                                       