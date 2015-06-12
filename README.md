# Visualization of hash tag network

This a simple Shiny Application that visualizes a part Twitter's
network saved into database using the projects:
https://github.com/sbartek/RtweetsDb
https://github.com/sbartek/RtweetsAnalytics


The application has the following features:

1. It connects with Tweeter REST API and reads tweets that contain provided keyword.
2. Saves tweets in relational db.
3. It identifies pairs of users that tweet-retweet and creates a igraph.
4. It provides basic statistics:
   * number of tweets
   * number of retweets
   * number of participants
5. It plots time evolution of number of tweets.
6. It plots the network graph.

Planed:
7. Export to gephi
8. Add basic statistics:
  * reach
9. Add users statistics:
  * active users
  * influencing users
  * ???
10. Add network statistics:
  * deepness
  * ???
