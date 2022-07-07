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
landscape_variable = list(period1 = list(
                                        fuel       = as.data.frame(matrix(nrow=side+1, ncol=side+1,10)),
                                        wind_speed = as.data.frame(matrix(nrow=side+1, ncol=side+1,15))))
landscape_fixed    = list(altitude = matrix(nrow=side+1, ncol=side+1, 100),
                          slope    = matrix(nrow=side+1, ncol=side+1, 0))
#   Considering V variable info and T period, does this mean I have to have VxT rasters?
# B. Initiate automata states
#   -> Can depend on some features, if data is absent for example, can be that it is unburnable
#   
landscape_variable$period1$state = as.data.frame(matrix(nrow=side+1, ncol=side+1, 'NI'))
landscape_variable$period0$state[10,12] = "I"
landscape_variable$period0$state[10,13] = "I"
landscape_variable$period1$state[10,14] = "I"
landscape_variable$period1$state[11,12] = "I"
landscape_variable$period1$state[11,13] = "I"
landscape_variable$period1$state[11,14] = "I"
landscape_variable$period1$state[12,12] = "I"
landscape_variable$period1$state[12,13] = "I"
landscape_variable$period1$state[12,14] = "I"









# C. PROVISIONAL : Partition landscape into different states for easier study
# Set the list of ignited cells
    ignited      <- list()
    ignited$coord_time   <- data.frame(x=if(length(which(landscape_variable$period1$state=="I"))==0) 0 else which(landscape_variable$period1$state=="I")%%(side+1),
                                       y=if(length(which(landscape_variable$period1$state=="I"))==0) 0 else which(landscape_variable$period1$state=="I")%/%(side+1)+1,
                                       t_ignition=0, 
                                       t_extinction=0) # Coordinates of ignited cells and time of ignition and extinction
    ignited$terrain_dist <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) #Terrain distance to adjacent cells
    ignited$cumul_dist   <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) # Cumulative distance to adjacent cells
# Repeat with CONSUMED and NOT-IGNITED
    consumed      <- list()
    consumed$coord_time   <- data.frame(x= if(length(which(landscape_variable$period1$state=="C"))==0) 0 else which(landscape_variable$period1$state=="C")%%(side+1),
                                        y= if(length(which(landscape_variable$period1$state=="C"))==0) 0 else which(landscape_variable$period1$state=="C")%/%(side+1)+1,
                                        t_ignition=0, 
                                        t_extinction=0) # Coordinates of ignited cells and time of ignition and extinction
    consumed$terrain_dist <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) #Terrain distance to adjacent cells
    consumed$cumul_dist   <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) # Cumulative distance to adjacent cells

    notignited      <- list()
    notignited$coord_time   <- data.frame(x=if(length(which(landscape_variable$period1$state=="NI"))==0) 0 else which(landscape_variable$period1$state=="NI")%%(side+1),
                                          y=if(length(which(landscape_variable$period1$state=="NI"))==0) 0 else which(landscape_variable$period1$state=="NI")%/%(side+1)+1,
                                          t_ignition=0, 
                                          t_extinction=0) # Coordinates of ignited cells and time of ignition and extinction
    notignited$terrain_dist <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) #Terrain distance to adjacent cells
    notignited$cumul_dist   <- data.frame(top=0, top_right=0, right=0, bottom_right=0, bottom=0, bottom_left=0, left=0, top_left=0) # Cumulative distance to adjacent cells
    
    
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
  # YES
# A. Get ignited cells and characteristics ####

    # Idea/example: select(landscape[[1]]==1)
    # With the idea that landscape[[1]] reflects the state of the automata
    # Update conditions from variable characteristics from part I (landscape profile)

      # Compute terrain distance for all adjacent cells
    for(i in 1:nrow(ignited$coord_time)){
      # TOP
      ignited$terrain_dist[i,1] = sqrt(cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1]-1 , ignited$coord_time[i,2]])^2)
      # TOP-RIGHT
      ignited$terrain_dist[i,2] = sqrt(cell_size^2 + cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1]-1 , ignited$coord_time[i,2]+1])^2)
      # RIGHT
      ignited$terrain_dist[i,3] = sqrt(cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]+1])^2)
      # BOTTOM RIGHT
      ignited$terrain_dist[i,4] = sqrt(cell_size^2 + cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1]+1 , ignited$coord_time[i,2]+1])^2)
      # BOTTOM
      ignited$terrain_dist[i,5] = sqrt(cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1]+1 , ignited$coord_time[i,2]])^2)
      # BOTTOM LEFT
      ignited$terrain_dist[i,6] = sqrt(cell_size^2 + cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1]+1 , ignited$coord_time[i,2]-1])^2)
      # LEFT
      ignited$terrain_dist[i,7] = sqrt(cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]-1])^2)
      # TOP LEFT
      ignited$terrain_dist[i,8] = sqrt(cell_size^2 + cell_size^2 + 
                                         (landscape_fixed$altitude[ignited$coord_time[i,1] , ignited$coord_time[i,2]]
                                          - landscape_fixed$altitude[ignited$coord_time[i,1]-1 , ignited$coord_time[i,2]-1])^2)
      
    }
    
    # Something like
    # dist = sqrt(dist^2 + dist^2 + 
    # + (landscape_fixed$altitude[ignited$coord_time[1,i],ignited$coord_time[2,i]]
    #    - landscape_fixed$altitude[ignited$coord_time][1,i]-/+1, ignited$coord_time[2,i]-/+1))
    # Actually, fix +/-1 with each direction in the data;
      

# B. For each cell that is ignited : get R_theta and distance ####
  for(i in 1:nrow(ignited$coord_time)){
    # Compute the R_theta for adjacent cells
    # Take the vector of angles from the direction of initial Rmax 
    # HYP : So far assume wind is blowing NORTH : this is complicated
    
    angles= c(360,45,90,135,180,225,270,315)*pi/180
    # Get the R_max for the cell and STORE IT : storage is the issue here.
    # Compute the Rmax with Rothermel formula, depending on one cell data
    # Measured in m/s
    # ATTENTION : I don't get how to compute it for now though
    Rmax = 10
    # Get the vector of R_theta
    Rtheta = (1-eccentr(10))/(1-eccentr(10)*cos(angles))*Rmax  
    # Compute t_n = cell_size/max R_max
    t_n = cell_size/max(Rmax)
    # Min amount of time that can occur in the simulation before the fire may have traveled to an other cell in a single
    # time step.
    
    # Compute the distance in all directions (R_theta x t_n)
    d_n = Rtheta*t_n
    # and update ignited[[3]] (accumulated distances)
    # --> REMARK  : This is where the storage is critical
    
    # Two different issues here : 
    # - The accumulated distance of fire is not really important for the ignited cell. It matters for the
    # POTENTIAL cells to be ignited : it makes no real sense to store it in ignited cells data.
    # - Need to store the accumulated distance traveled TO a cell
    # -> This raises the issue of double ignition : assume we have two initial ignition points, both traveling
    # to a cell. Should both values be stored? Can we just keep the largest spread in each period? 
    # IN THE CASE OF a HOMOGENEOUS landscape, yes : the differential is set up at the origin. However, with HETEROGENEOUS
    # landscapes (or wind changes for ex), the delay can be made up with especially fire prone conditions in period 2.
    
    # Abstract from this issue here : just use a single ignition point, and store the data in the relevant data
    # sets for non-ignited cells.
    
    # Question here : how to assign the distances?
    # -> Assume that wind blows NORTH : angle for top=0/360
    ignited$cumul_dist[i,] = d_n
  }

    
# C. Transition of fire #####
  # Transition should start with a screening of states
  # and focus only on cells susceptible to change their states. 
  # This would mean focus on ignited cells and their neighborhood, conditional on them
  # not being consumed or unburnable

  # i. Set of cells to be considered : ignited with time of extinction == NA ####

  # For all directions, compare same lines across ignited[[2]] and ignited[[3]]:
    # if accumulated distance (ignited[[3]]) is larger than terrain distance (ignited[[2]])
    # and cells are not unburnable, or consumed, or already ignited
    # => then set cell to ignited

    comp = as.data.frame(which(ignited$terrain_dist<=ignited$cumul_dist, arr.ind = T))
    
    # This gives us information :
    #   - for row i in comp gives x_i and y_i, the coordinates of ignited cells
    #   - col gives which cell should be ignited. So if col=1, it means that cell with coordinate x-1 and y should ignite
    #     if col=6, cell to be ignited is x+1 and y-1
    
    for(i in 1:nrow(comp)){
      if(landscape_variable$period1$state[comp[i,1],comp[i,2]]=="NI"){
        ignited$coord_time = rbind(ignited$coord_time, c(comp[i,1],comp[i,2],0,NA))
      }
    }
    
    
    
    
    
    
    
    # Question : should the landscape[[1]] track that, overall? 
    # Even if yes, do we need an other dataset to work with? 

      # Update partly the list ignited cells : 
          # Coordinates
          # Distance accumulated
          # Terrain distance
          # Time of ignition and extinction
    # HYP : may need to update partially landscape here. Set next step landscape and make it evolve
    # to account for ignitions. It is easier to understand whether all 8 adjacent cells are ignited here 
    # rather than accounting for it with the coordinates in the ignited list. 
    
  # ii. if all adjacent cells are ignited, set to consumed #####
for(i in nrow(ignited$coord_time)){
coord = ignited$coord_time %>% select(x,y)

  (coord[i,1]-1 %in% coord$x & coord[i,2]-1 %in% coord$y) & (coord[i,1]-1 %in% coord$x & coord)
  }
    
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
  # Need to set new period and environmental data
  # For example, update fuel after burn and set its own law of motion  
    
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


                                                                       
