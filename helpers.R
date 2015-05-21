require(httr)
require(twitteR)
source('twitterOAuth.R')

options(httr_oauth_cache=TRUE)
setup_twitter_oauth(api_key, api_secret, access_token, access_token_secret)
