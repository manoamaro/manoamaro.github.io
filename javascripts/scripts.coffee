---
---

metas = document.getElementsByTagName('meta')
i = undefined

gestureStart = ->
  i = 0
  while i < metas.length
    if metas[i].name == 'viewport'
      metas[i].content = 'width=device-width, minimum-scale=0.25, maximum-scale=1.6'
    i++
  return

if navigator.userAgent.match(/iPhone/i)
  i = 0
  while i < metas.length
    if metas[i].name == 'viewport'
      metas[i].content = 'width=device-width, minimum-scale=1.0, maximum-scale=1.0'
    i++
  document.addEventListener 'gesturestart', gestureStart, false
$ ->
  $('img').unveil()
  return
