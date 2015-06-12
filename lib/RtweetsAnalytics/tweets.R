require(ggplot2)

noRetwitted <- function(tweets.df) {
  subset(tweets.df, isRetweet==0)
}

retwitted <- function(tweets.df) {
  subset(tweets.df, isRetweet==1)
}

toDateTime <- function(n) {
  as.POSIXct(n, origin = "1970-01-01")
}


freqPlotAll <- function(tweets.df) {
  ggplot(data=tweets.df) + geom_freqpoly(aes(toDateTime(created)), binwidth=10000)+
    theme_bw() + xlab('DateTime')  
}

freqPlotByTRT <- function(tweets.df) {
  ggplot(data=tweets.df) +
    geom_freqpoly(aes(toDateTime(created), colour=as.factor(isRetweet)), binwidth=10000) +
    theme_bw() + xlab('DateTime')  
}



