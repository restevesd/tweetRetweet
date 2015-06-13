require(ggplot2)

noRetwitted <- function(tweets.df) {
  subset(tweets.df, isRetweet==0)
}

retwitted <- function(tweets.df) {
  subset(tweets.df, isRetweet==1)
}

toTwitterDateFormat <- function(dt) {
  unclass(dt)
}

toDateTime <- function(n) {
  as.POSIXct(n, origin = "1970-01-01")
}

limitByDate <- function(tweets.df, init.date=NULL, end.date=NULL) {
  new.df <- tweets.df
  if (! is.null(init.date)) {
    i.d <- toTwitterDateFormat(as.POSIXct(init.date))
    new.df <- subset(new.df, created >= i.d )
  }
  if (! is.null(end.date)) {
    e.d <- toTwitterDateFormat(as.POSIXct(end.date))
    new.df <- subset(new.df, created <= e.d)
  }
  new.df
}

freqPlotAll <- function(tweets.df) {
  ggplot(data=tweets.df) + geom_freqpoly(aes(toDateTime(created)), binwidth=10000)+
    theme_bw() + xlab('DateTime')  
}

freqPlotByTRT <- function(tweets.df, init.date=NULL, end.date=NULL) {
  new.df <- limitByDate(tweets.df, init.date, end.date)
  ggplot(data=new.df) +
    geom_freqpoly(aes(toDateTime(created), colour=as.factor(isRetweet)),
                  binwidth=10000) +
    theme_bw() + xlab('DateTime') +
        labs(colour="Retwitted?") +
    scale_colour_discrete(labels=c("No", "Yes"))

}
