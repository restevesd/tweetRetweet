## require('ggmap')

usersMapPlot <- function(coordinates.df) {
  worldMap <- map_data("world")
  coordinates.plot <- ggplot() +
    geom_polygon( data=worldMap, aes(x=long, y=lat, group = group),
                 colour="grey", fill="grey10", size=.1 ) +
    theme_minimal() +
    theme(plot.background= element_rect(fill = "gray10"),
          panel.grid.major = element_line(colour="grey", size=0.1),
          panel.grid.minor = element_line(colour="grey", linetype="dashed", size=0.1)
          ) +
    xlab("") + ylab("") 
  coordinates.plot + geom_point(data = coordinates.df,  
                                aes(x = lon, y = lat),
                                colour = "yellow", alpha = .3, size = 1)
}


distrurb <- function(vec, delta=0.1) {
  n <- length(vec)
  noise <- rnorm(n, 0, delta)
  vec + noise
}
