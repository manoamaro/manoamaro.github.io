---
title: Rails and Angujar JS
date: 2016-08-02 02:50:28.053000000 Z
tags:
- ruby
- rails
- angular js
- javascript
- frontend
layout: post
---

When I saw Angular JS for the first time, I ran to integrate into my Rails projects. But then I started to face some challenges. The main challenge was how I could integrate the Angular JS's one page feature with all the Rails views and forms. After a lot of research, I came up with these following solutions.

### First part, the index view

Angular JS has a great module: Routing. This module enables the development of one page application. For example, the `index.html` view is loaded once in the first request, and the communication with the backend is only for data transfer to populate the views inside the HTML. But the Routing module requires that each route makes a request to the partials for every defined route, as shown below:

{% highlight javascript %}
  app.config(['$routeProvider',
    function($routeProvider) {
      $routeProvider.
        when('/models', {
          templateUrl: 'models/index.html',
          controller: 'ModelIndexCtrl'
        }).
        when('/models/:id', {
          templateUrl: 'models/show.html',
          controller: 'ModelShowCtrl'
        }).
        otherwise({
          redirectTo: '/models'
        });
    }]);
{% endhighlight %}

But this approach, at least for me, is good, but not ideal. Even if only a small page is loaded for every route after the main page is loaded, and after this, another request is made for the data, now we have two 
