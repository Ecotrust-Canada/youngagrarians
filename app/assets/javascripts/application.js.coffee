#= require jquery
#= require jquery_ujs
#= require jquery.gomap
#= require jquery.nicescroll
#= require foundation
#= require underscore
#= require backbone
#= require backbone.marionette
#= require backbone-relational
#= require backbone-modelref
#= require backbone/youngagrarians
#= require markerclusterer
#= require admin_class

make = (tagName, attributes, content ) ->
  $el = Backbone.$ "<" + tagName + "/>"
  if attributes
    $el.attr attributes
  if content != null
    $el.html content
  $el[0]

Backbone.View.make = make
Backbone.Marionette.View.make = make

Backbone.Marionette.Renderer.render = (template, data) ->
  if !JST[template]
    throw "Template '" + template + "' not found!"
  JST[template](data)

Youngagrarians.trackOutboundLinks = ->
  $('a[href^="http://"]:not([href*="youngagrarians.org"])').click (ev) ->
    $target = $(ev.target)
    link = $target[0]

    try
      ga('send', 'event', 'Outbound Links', $target.attr('href'))
    catch err
      console.log('Error tracking click', err)

    if $target.attr('target') != '_blank'
      $(ev).preventDefault()
      setTimeout (-> document.location.href = link.href), 100

$(document).ready =>
  $(document).foundation()

  Youngagrarians.trackOutboundLinks()
