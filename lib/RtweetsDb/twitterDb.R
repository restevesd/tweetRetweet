DBPATH <- 'db/tweets.db'
NTWEETS <- 100

require('twitteR')
# In file 'twitterAuth.R' one can assign appropriate values to variables: 
# api_key, api_secret, access_token, access_token_secret

twitterOAuth <- function() {
  if (file.exists('twitterAuth.R')) {
    source('twitterAuth.R')
  }
  options(httr_oauth_cache=TRUE)
  setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)
}

source('createModels.R')
source('acctionsDb.R')
source('createDb.R')

createTwitterModels <- function(db.path=DBPATH) {
  models <- list(c("tweets", "conf/db/tweetsTable.txt"),
                 c("hashes", "conf/db/hashesTable.txt") )
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

getTweetsFromDB <- function(hash.txt, db.path=DBPATH) {
  connection <- getConnection(db.path)
  tweets.df <- dbReadChildrenM2M(connection, 'hashes', hash.txt,
                                 'tweets', father.pk='hash')
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
