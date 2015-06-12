RETWEET.PATERN <- "^(RT|via)((?:\\b\\W*@\\w+:)+)"

require('stringr')
require('igraph')

retweetsMatches <- function(tweets.df) {
  grep(RETWEET.PATERN, tweets.df$text, ignore.case=TRUE)
}

extractPosters <- function(tweets.df) {
  rt.posters <- str_extract(tweets.df$text, RETWEET.PATERN)
  rt.posters <- gsub("(RT @|via @)", "", rt.posters, ignore.case=TRUE)
  gsub(":", "", rt.posters, ignore.case=TRUE)
}

retweetsEdgelist <- function(tweets.df) {
  retweets.ines <- retweetsMatches(tweets.df)
  who.retweets <- tweets.df[retweets.ines,]$screenName
  who.tweets <- extractPosters(tweets.df[retweets.ines,])
  data.frame(Source=who.tweets, Target=who.retweets,
             stringsAsFactors=FALSE)
}

retweetsEdgelist.matrix <- function(tweets.df) {
  rts.edgelist.df <- retweetsEdgelist(tweets.df)
  cbind(rts.edgelist.df$Source, rts.edgelist.df$Target)
}

