_         = require 'lodash'
fs        = require 'fs'
parse     = require 'xml-parser'
request   = require 'request'
inspect   = require('util').inspect

plog = (thing) ->
  console.log thing, { colors: true, depth: Infinity}

SiteBuild =
  init: ->
    @fetchSitemap()

  fetchSitemap: ->
    request 'http://craft.dev/sitemap.xml', (error, response, body) =>
      throw error if error
      if response.statusCode is 200
        xml_object = parse body
        @createLinkList xml_object.root.children

  createLinkList: (children) ->
    list = []
    _.each children, (child, i) ->
      list.push child.children[0].content
    _.each list, (link) ->
      
    @getHTML list

  getHTML: request link, (error, response, body) ->
    throw error if error
    if response.statusCode is 200
      console.log body



SiteBuild.init()