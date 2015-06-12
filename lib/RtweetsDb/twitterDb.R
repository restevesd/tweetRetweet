
createTwitterModels <- function(db.path=DBPATH) {
  models <- list(c("tweets", "config/db/tweetsTable.txt"),
                 c("hashes", "config/db/hashesTable.txt") )
  connection <- getConnection(db.path)
  createModels(connection, models)
  dbDisconnect(connection)
}

addHash <- function(hash.txt, db.path=DBPATH) {
  connection <- getConnection(db.path)
  hash.df <- data.frame(hash=hash.txt)
  dbWriteNewRows(connection, 'hashes', hash.df, pk='hash')
  dbDisconnect(connection)
}

getAndSaveTweets <- function(hash.txt, n=NTWEETS, db.path=DBPATH) {
  tweets.tweets <- searchTwitter(hash.txt, n)
  if (length(tweets.tweets) != 0) {
    tweets.df <- twListToDF(tweets.tweets)
    hash.row <- data.frame(hash=hash.txt)
    connection <- getConnection(db.path)
    dbAddChildrenM2M(connection, 'hashes', hash.row,
                     'tweets', tweets.df, father.pk='hash')
    dbDisconnect(connection)
  }
}

getTweetsFromDB <- function(hash.txt, db.path=DBPATH, n.tweets=1000) {
  connection <- getConnection(db.path)
  tweets.df <- dbReadChildrenM2M(connection, 'hashes', hash.txt,
                                 'tweets', father.pk='hash',
                                 n.fetch=n.tweets)
  dbDisconnect(connection)
  tweets.df
}

updateAllHashes <- function(db.path=DBPATH) {
  connection <- getConnection(db.path)
  hashes <- dbReadTable(connection, 'hashes')
  apply(hashes, 1, function(row) {getAndSaveTweets(row[1])})
  dbDisconnect(connection)
}

getAllHashes <- function(db.path=DBPATH) {
  connection <- getConnection(db.path)
  hashes <- dbReadTable(connection, 'hashes')
  dbDisconnect(connection)
  hashes
}
