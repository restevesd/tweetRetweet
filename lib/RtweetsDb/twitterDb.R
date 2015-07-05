createTwitterModels <- function(db.path=DBPATH) {
  models <- list(c("tweets", "config/db/tweetsTable.txt"),
                 c("hashes", "config/db/hashesTable.txt"),
                 c("users", "config/db/usersTable.txt")) 
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

addUsers <- function(users.df, db.path=DBPATH) {
  connection <- getConnection(db.path)
  newUsers <- dbWriteNewRows(connection, 'users', users.df, pk='id')
  dbDisconnect(connection)
  newUsers
}

lookupAndAddUsers <- function(users, db.path=DBPATH) {
  users.tl <- lookupUsers(users)
  users.df <- twListToDF(users.tl)
  addUsers(users.df)
}

getAndSaveTweets <- function(hash.txt, n=NTWEETS, db.path=DBPATH) {
  print(paste('Lookup tweets for hash ', hash.txt))
  tweets.tweets <- searchTwitter(hash.txt, n)
  newChildren <- NULL
  if (length(tweets.tweets) != 0) {
    print('saving ...')
    tweets.df <- twListToDF(tweets.tweets)
    hash.row <- data.frame(hash=hash.txt)
    connection <- getConnection(db.path)
    newChildren <- dbAddChildrenM2M(connection, 'hashes', hash.row,
                                    'tweets', tweets.df, father.pk='hash')
    dbDisconnect(connection)
    print('ok')
  }
  return(newChildren)
}

getAll <- function(model, db.path=DBPATH) {
  connection <- getConnection(db.path)
  elements <- dbReadTable(connection, model)
  dbDisconnect(connection)
  elements
}

getAllHashes <- function(db.path=DBPATH) {
  getAll('hashes', db.path)
}

getAllUsers <- function(db.path=DBPATH) {
  getAll('users', db.path)
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
  hs <- apply(hashes, 1, function(row) {getAndSaveTweets(row[1])})
  dbDisconnect(connection)
  hs
}

updateAllHashesWithUsers <- function(db.path=DBPATH) {
  newTweetss.list <- updateAllHashes(db.path)
  users <- usersFromTweets(newTweetss.list)
  lookupAndAddUsers(users, db.path)
}


usersFromTweets <- function(newTweetss.list) {
  ## input: list of data.frames of tweets (output of updateAllHashes)
  ## or data.frame of tweets
  if (is.data.frame(newTweetss.list)) {
    newTweets <- newTweetss.list
  } else {
    newTweets <- Reduce(rbind, newTweetss.list)
  }
  newTweets$screenName
}

## Clening:
## DELETE FROM tweets WHERE rowid NOT IN (SELECT maxrid FROM (SELECT MAX(rowid) AS maxrid, COUNT(id) AS nrs FROM tweets GROUP BY id) WHERE nrs > 1);
## Better:
## DELETE FROM users WHERE rowid NOT IN  (SELECT MAX(rowid) FROM users GROUP BY id);
## DELETE FROM hashesTweets WHERE rowid NOT IN (SELECT MAX(rowid) FROM hashesTweets GROUP BY hashes_fk, tweets_fk);

