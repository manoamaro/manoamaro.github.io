---
layout: post
title: 'Rails and Angujar JS'
tags:
  - ruby
  - rails
  - angular js
  - javascript
  - frontend
---

When I saw Angular JS for the first time, I ran to integrate into my Rails projects. But then I started to face some challenges. The main challenge was how I could integrate the Angular JS's one page feature with all the Rails views and forms. After a lot of research, I came up with these following solutions.

### First part, the index view

Angular JS has two great features, Multiple Views and Routing. These features enable the development of one page application. For example, the `index.html` view is loaded once in the first request, and the communication with the backend is only for data transfer to populate the views inside the HTML.
