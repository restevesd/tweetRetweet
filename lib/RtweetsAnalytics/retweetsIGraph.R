## depends on retweets.R
##

require('rgexf')

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
  # We should reurn it in the orginal order since it is needed for
  # ploting the graph of connections
  merged <- merged[order(merged$orginalOrder),-3]
  rownames(merged) <- c()
  merged
}

tweetRetweetNodesFull <- function(rt.graph) {
  nodes <- tweetRetweetNodes(rt.graph)
  print("aaa")
  print(dim(nodes))
  users <- getAllUsers()
  merged <- merge(nodes, users, all.x=TRUE, by.x="Nodes", by.y="screenName")
  print("bbb")
  print(dim(merged))
  print("ccc")
  merged
}

tweetRetweetPlot <- function(rt.graph, Nlabels=10, sizeMulti=0.01,
                             PercentageOfConnections=1) {
  Ntotal <- length(E(rt.graph))
  Nconn <- round(Ntotal*PercentageOfConnections)
  new.graph <- subgraph.edges(rt.graph, E(rt.graph)[sample(1:Ntotal, Nconn)])
  
  nodes.df <- tweetRetweetNodes(new.graph)

  labeledNodes <- nodes.df[order(-nodes.df$Nretwitted),]$Nodes[1:Nlabels]
  nodes.df$label <- sapply(nodes.df$Nodes, function(n) {if (n %in% labeledNodes) {n} else {""}})
  nodes.df$color <- "gray45"
  l <- layout.auto(new.graph)
  #l <- layout.fruchterman.reingold(new.graph)#, niter=10000, area=vcount(new.graph)^4,
                                        #repulserad=vcount(new.graph)^2.2)
    plot(new.graph,
       vertex.size=nodes.df$Nretwitted*sizeMulti,
       vertex.label= nodes.df$label,
       vertex.label.family="sans",
       vertex.label.cex=1,
       vertex.label.color = "darkred",
       vertex.frame.color = rgb(124/255, 194/255, 66/255, alpha=0.7),
       vertex.color= rgb(124/255, 194/255, 66/255, alpha=0.2), #hsv(h=.95, s=1, v=.7, alpha=0.5),   #nodes.df$Nretweets, #
       edge.color= rgb(124/255, 194/255, 66/255, alpha=0.3),  #fb.net.el$color,
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
  cg1 <- tweetRetweetGraph(tweets.df)
  nodes <- data.frame(cbind(V(cg1), as.character(V(cg1))))
  edges <- t(Vectorize(get.edge, vectorize.args='id')(cg1, 1:ecount(cg1)))
  write.gexf(nodes, edges,  output = "output/gephi/tweetRetweet.gexf")
}
