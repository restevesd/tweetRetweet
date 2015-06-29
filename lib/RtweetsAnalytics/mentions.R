MENTION.PATERN <- "@\\w+"

extractMentionsFromTxt <- function(tx) {
  m <- gregexpr(MENTION.PATERN, tx)
  mnss <- regmatches(tx, m)
  lapply(mnss, function(mns) {
    if (length(mns)!=0) {
      ns <- sapply(mns, function(mn) {
        gsub("@", "", mn)
      })
      names(ns) <- c()
      ns
    }
  })
}

extractMentions <- function(tweets.df) {
  txs <- extractTweets(tweets.df)
  extractMentionsFromTxt(txs)
}

