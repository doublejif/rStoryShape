#' Detect subtours in a given traveling salesman problem (TSP) route.
#'
#' @param x_tsp The matrix representing the tour's tracks with two columns.
#' @param idxs The distance matrix of the cities.
#'
#' @return A list of all possible subtours found in the TSP route.
#' @export
#'
#' @examples
#' detectSubtours(x_tsp, idxs)


detectSubtours <- function(x_tsp, idxs) {
  subTours <- list()
  x <- round(x_tsp)
  substuff <- idxs[as.logical(x_tsp), ]
  unvisited <- rep(1, sum(x))
  curr <- 1
  startour <- which(unvisited != 0)[1]
  end_home <- max(substuff)
  while ((!is.na(startour))) {
    home <- substuff[startour, 1]
    nextpt <- substuff[startour, 2]
    visited <- nextpt
    unvisited[startour] <- 0
    while ((nextpt != home) & (nextpt != end_home)) {
      s <- as.data.frame(which(substuff == nextpt, arr.ind = TRUE))
      srow <- s$row
      scol <- s$col
      trow <- srow[which(srow != startour)]
      scol <- 3 - scol[which(trow == srow)]
      startour <- trow
      # print(startour)
      # print(scol)
      nextpt <- substuff[startour, scol]
      # print(home)
      # print(nextpt)
      visited <- c(visited, nextpt)
      unvisited[startour] <- 0
    }
    subTours[[curr]] <- visited
    curr <- curr + 1
    startour <- which(unvisited != 0)[1]
    # print(unvisited)
  }
  return(subTours)
}
