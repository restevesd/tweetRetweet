#depends on retweets.R
#


tweetRetweetGraph <- function(tweets.df) {
  graph.edgelist(retweetsEdgelist.matrix(tweets.df))
}

tweetRetweetNodes <- function(rt.graph) {
  retwitted <- degree(rt.graph, mode='out')
  retwitted.df <- data.frame(Nodes=names(retwitted),
                             Nretwitted = retwitted,
                             orginalOrder = 1:length(retwitted),
                             stringsAsFactors=FALSE)
  retweets <- degree(rt.graph, mode='in')
  retweets.df <- data.frame(Nodes=names(retweets),
                            Nretweets = retweets,
                            stringsAsFactors=FALSE)
  merged <- merge(retwitted.df, retweets.df)
  merged[order(merged$orginalOrder),]
}

tweetRetweetPlot <- function(rt.graph, Nlabels=10, sizeMulti=0.01) {
  nodes.df <- tweetRetweetNodes(rt.graph)
  labeledNodes <- nodes.df[order(-nodes.df$Nretwitted),]$Nodes[1:Nlabels]
  nodes.df$label <- sapply(nodes.df$Nodes, function(n) {if (n %in% labeledNodes) {n} else {""}})
  nodes.df$color <- "gray45"
  l <- layout.auto(rt.graph)
  plot(rt.graph,
       vertex.size=nodes.df$Nretwitted*sizeMulti,
       vertex.label= nodes.df$label,
       vertex.label.family="sans",
       vertex.label.cex=0.5,
       vertex.label.color = "darkred",
       vertex.color= rgb(.5, 0, 0, alpha=1), #hsv(h=.95, s=1, v=.7, alpha=0.5),   #nodes.df$Nretweets, #
       edge.color=  rgb(0, 0, 1, alpha=0.1) , #fb.net.el$color,
       edge.width=1,
       edge.arrow.size=0.2,
       edge.curved=0.3,
       layout=l)
}

writeGephiCsv <- function(tweets.df, nodes.csv.fn=NULL, edges.csv.fn=NULL) {
  if (is.null(nodes.csv.fn)) {
    nodes.csv.fn <- 'output/csv/nodes.csv'
  }
  if (is.null(edges.csv.fn)) {
    edges.csv.fn <- 'output/csv/edges.csv'
  }
  edges.df <- retweetsEdgelist(tweets.df)
  rt.graph <- tweetRetweetGraph(tweets.df)
  nodes.df <- tweetRetweetNodes(rt.graph)
  colnames(nodes.df)[1] <- 'ID'
  write.csv(edges.df, file=edges.csv.fn, row.names=F)
  write.csv(nodes.df, file=nodes.csv.fn, row.names=F)
}
