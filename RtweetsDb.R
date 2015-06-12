require('twitteR')

source('RmodelsDb.R')
source('lib/RtweetsDb/twitterDb.R')

config.path <- 'config/twitterDb.R'

if (file.exists(config.path)) {
  source(config.path)
}

if (!exists('DBPATH')) {
  DBPATH <- 'db/tweets.db'
}

if (!exists('NTWEETS')) {
  NTWEETS <- 100
}

# In file 'config/twitterAuth.R' one can assign appropriate values to variables: 
# api_key, api_secret, access_token, access_token_secret
# This file is ignored by git

if (file.exists('config/twitterAuth.R')) {
  source('config/twitterAuth.R')
}

twitterOAuth <- function() {
  options(httr_oauth_cache=TRUE)
  setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)
}
