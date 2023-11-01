#' Find the shortest path in a traveling salesman problem (TSP) with the first and last destinations fixed.
#'
#' @param position_windows A vector-based matrix representing the characteristic matrix of each text window. Each row has 300 dimensions.
#'
#' @return A list containing the route and the distance of the shortest path.
#' @export
#'
#' @examples
#' global_TSP(position_windows)

global_TSP <- function(cities) {
  ### Work out the shorttest route globally
  ### cities is the position_windows here. Which is a vector_based matrix. With 300-dim each row
  nStops <- nrow(cities)

  ### First, all possible combination, n choose k
  idxs <- t(combn(1:nStops, 2))
  ### Set the initial solution, X0, which is from 1->2->3->4->5->...->nStops
  X0 <- c()
  dist <- c() # Distance vector
  ### Generate the initial route and distance vector
  for (i in 1:(nStops - 1)) {
    for (j in (i + 1):nStops) {
      if (i != j) {
        new_dist <- sqrt(sum((cities[j, ] - cities[i, ])^2))
        dist <- c(dist, new_dist)
        if (j == (i + 1)) {
          X0 <- c(X0, 1)
        } else {
          X0 <- c(X0, 0)
        }
      }
    }
  }

  lendist <- length(dist)

  ### Generate the limitation condition, Aeq, beq
  ### We have to make sure:
  # 1. First and last one only appear for once
  # 2. Other city appear for twice
  # 3. the path should only have (n-1) edge

  #### Third condition
  Aeq <- matrix(1, nrow = 1, ncol = lendist)
  beq <- nStops - 1
  #### First condition. Find out the "first stop" that start with ii
  ii <- 1
  whichIdxs <- as.integer(idxs[, 1] == ii)
  Aeq <- rbind(Aeq, whichIdxs)
  beq <- c(beq, 1)

  #### Second condition, find out the trip that include city ii
  for (ii in 2:(nStops - 1)) {
    whichIdxs <- as.integer(idxs[, 1] == ii)
    whichIdxs1 <- as.integer(idxs[, 2] == ii)
    whichIdxs <- whichIdxs + whichIdxs1
    Aeq <- rbind(Aeq, whichIdxs)
    beq <- c(beq, 2)
  }

  #### First condition. Find out the 'last stop' that end with ii
  ii <- nStops
  whichIdxs <- as.integer(idxs[, 2] == ii)
  Aeq <- rbind(Aeq, whichIdxs)
  beq <- c(beq, 1)
  #### Give one more row to set no direct path from first to last
  whichIdxs <- rep(0, lendist)
  whichIdxs[nStops - 1] <- 1
  Aeq <- rbind(Aeq, whichIdxs)
  beq <- c(beq, 0)

  #### Other conditions, set all.bin=TRUE
  f.dir <- rep("==", (nStops + 2))
  bounds <- list(lower = list(ind = c(1:lendist), val = rep(0, lendist)), upper = list(ind = c(1:lendist), val = rep(1, lendist)))
  types <- rep("I", lendist)
  # tsp_result=lp('min',dist,Aeq,f.dir,beq,all.bin = TRUE)
  tsp_result <- Rglpk_solve_LP(obj = dist, mat = Aeq, dir = f.dir, rhs = beq, types = types, bounds = bounds, max = FALSE)
  #### Get a initial solution
  x_tsp <- tsp_result$solution

  #### Get the number of subtours to make sure that we only got one tour line
  tours <- detectSubtours(x_tsp, idxs)
  numtours <- length(tours)

  ### Add the subtour constraints
  while (numtours > 1) {
    b <- rep(0, numtours)
    f.dir <- c(f.dir, rep("==", numtours))
    A <- matrix(0, nrow = numtours, ncol = lendist)
    for (ii in 1:numtours) {
      new_constraint <- rep(0, lendist)
      subTourIdx <- sort(tours[[ii]])
      # print(subTourIdx)
      variations <- t(combn(1:length(subTourIdx), 2))
      for (jj in 1:nrow(variations)) {
        whichVar <- which((idxs[, 1] == subTourIdx[variations[jj, 1]]) & (idxs[, 2] == subTourIdx[variations[jj, 2]]))
        # print(whichVar)
        new_constraint[whichVar] <- 1
      }
      A <- rbind(A, new_constraint)
      b <- c(b, length(subTourIdx) - 1)
      f.dir <- c(f.dir, "<=")
    }
    ## Try to optimize it again
    # print(Aeq)
    Aeq <- rbind(Aeq, A)
    beq <- c(beq, b)
    tsp_result <- Rglpk_solve_LP(obj = dist, mat = Aeq, dir = f.dir, rhs = beq, types = types, bounds = bounds, max = FALSE)
    x_tsp <- tsp_result$solution
    tours <- detectSubtours(x_tsp, idxs)
    numtours <- length(tours)
  }
  route <- c(1, tours[[1]])
  distance_total <- tsp_result$optimum

  return(list(route, distance_total))
}
