# Visualization of hash tag network

This a simple Shiny Application that visualize tweets that contain
provided word. The relation between tweets is the following:
tweet1 -> tweet2 if tweet2 is a retweet of tweet1.

The application has the following features:

1. It connects with Tweeter REST API and reads tweets that contain
   provided keyword.
2. It identifies pairs tweet-retweet and creates a igraph.
3. Plots the graph.

Planed:
4. Export to gephi
5. Cashes searches

6. Add basic statistics:
  * number of tweets
  * number of retweets
  * number of participants
  * reach
7. Add users statistics:
  * active users
  * influencing users
  * ???
8. Add network statistics:
  * deepness
  * ???
