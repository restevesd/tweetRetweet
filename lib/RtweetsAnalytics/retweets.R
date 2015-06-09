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

writeGephiCsv <- function(tweets.df,
                          vertices.csv.fn=NULL,edges.csv.fn=NULL
                          ) {
  if (is.null(vertices.csv.fn)) {
    vertices.csv.fn <- 'output/csv/vertices.csv'
  }
  if (is.null(edges.csv.fn)) {
    edges.csv.fn <- 'output/csv/edges.csv'
  }
  edges.df <- retweetsEdgelist(tweets.df)
  write.csv(edges.df, file=edges.csv.fn, row.names=F)
  vertices.df <- data.frame(ID=union(edges.df$Source, edges.df$Target))
  write.csv(vertices.df, file=vertices.csv.fn, row.names=F)
}

tweetRetweetGraph <- function(tweets.df) {
  graph.edgelist(retweetsEdgelist.matrix(tweets.df))
}

tweetRetweetPlot <- function(rt.graph) {
  ver.labs <- get.vertex.attribute(rt.graph, "name", index=V(rt.graph))
  # choose some layout
  glay <- layout.fruchterman.reingold(rt.graph)

  # plot
  par(bg="black",mar=c(1,1,1,1))
  plot(rt.graph, layout=glay,
       vertex.color="darkgreen",
       vertex.size=10,
       vertex.label=ver.labs,
       vertex.label.family="sans",
       vertex.shape="none",
       vertex.label.color=hsv(h=0, s=0, v=.95, alpha=0.5),
       vertex.label.cex=0.85,
       edge.arrow.size=0.8,
       edge.arrow.width=0.5,
       edge.width=3,
       edge.color=hsv(h=.95, s=1, v=.7, alpha=0.5))
}
