# Twitter Tailored Tool

## Propose

This a simple Shiny Application that visualizes a part Twitter's
network saved into database using the projects:
https://github.com/sbartek/RtweetsDb
https://github.com/sbartek/RtweetsAnalytics

It is done as a project for two proposes.

1. As assignment for Developing Data Products Course in Data
   Specialization.
2. As application that can be used to explore Oxfam Intermon campaigns
about inequalities.

## Features

1. It connects with Tweeter REST API and reads tweets that contain provided keyword.
2. Saves tweets in relational db.
3. It identifies pairs of users that tweet-retweet and creates a igraph.
4. It provides basic statistics:
   * number of tweets
   * number of retweets
   * number of participants
5. It plots time evolution of number of tweets.
6. It plots the network graph.

## Instructions

I hope it is easy to use.

1. On the left one can choose a hash tag to explore. At the moment
   there are two. One can also choose dates date range.
2. Then on the right one see various tabs where one can explore
   statistics. The last graph is the graph where vertices are people
   that tweets and edges represent connection tweet - retweet.
