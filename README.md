# Twitter Tailored Tool

## Propose

This a simple Shiny Application that visualizes a part Twitter's
network saved into database using the projects:
https://github.com/sbartek/RtweetsDb
https://github.com/sbartek/RtweetsAnalytics

This application is used to explore Oxfam Intermon campaigns
about inequalities.

## Features

* It connects with Tweeter REST API and reads tweets that contain provided keyword.
* Saves tweets and users in relational db.
* It connects to google localization service and gets coordinates of users and saves them to DB.
* Produced a map where tweets come form.
* It identifies pairs of users that tweet-retweet and creates a graph.
* It provides basic statistics:
   - number of tweets
   - number of retweets
   - number of participants
* It plots time evolution of number of tweets.

## Instructions

I hope it is easy to use.

1. On the left one can choose a hash tag to explore. At the moment
   there are two. One can also choose dates date range.
2. Then on the right one see various tabs where one can explore
   statistics. The last graph is the graph where vertices are people
   that tweets and edges represent connection tweet - retweet.

## Installing

...
