#= require webshims/polyfiller

document.addEventListener "DOMContentLoaded", (event)-> 
  webshim.setOptions('basePath', '/webshims/1.15.10/shims/')
  webshim.polyfill("forms")
