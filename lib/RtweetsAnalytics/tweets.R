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

basicStat <- function(tweets.df) {
  bs <- list()
  bs$totalNumber <- dim(tweets.df)[1]
  bs$retwittedNumber <- dim(retwitted(tweets.df))[1]
  bs$noRetwittedNumber <- dim(noRetwitted(tweets.df))[1]
  bs
}

basicStatDf <- function(tweets.df) {
  bs <- basicStat(tweets.df)
  bs.df <- data.frame(Number=c(bs$totalNumber, bs$noRetwittedNumber, bs$retwittedNumber))
  rownames(bs.df) <- c('Total','No retwitted', 'Retwitted')
  bs.df
}

basicStat2Df <- function(tweets.df, users.df) {
  t.df <- tweets.df[c('screenName')]
  u.df <- users.df[c('screenName', 'followersCount')]
  merged <- merge(t.df, u.df, all.x=TRUE)
  reach <- sum(merged$followersCount, na.rm = TRUE)
  bs2 <- data.frame(Reach=reach)
  bs2
}

basicStatPlot <- function(tweets.df) {
  bs <- basicStat(tweets.df)  
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
