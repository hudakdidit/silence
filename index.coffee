_         = require 'lodash'
fs        = require 'fs'
path      = require 'path'
parse     = require 'xml-parser'
rimraf    = require 'rimraf'
request   = require 'request'
mkdirp    = require 'mkdirp'
inspect   = require('util').inspect

c = ->
  @domain  = 'http://craft.dev/'
  @sitemap = "#{@.domain}sitemap.xml"
  @build   = 'build'

CONFIG = new c()


SiteBuild =
  buildPath: path.join(__dirname, CONFIG.build)
  init: ->
    @clean()
    @fetchSitemap()

  clean: ->
    rimraf(@buildPath, (err) ->
      throw err if err)

  fetchSitemap: ->
    request CONFIG.sitemap, (error, response, body) =>
      throw error if error
      if response.statusCode is 200
        xml_object = parse body
        @createLinkList xml_object.root.children

  createLinkList: (children) ->
    list = []
    _.each children, (child, i) ->
      list.push child.children[0].content
    
    _.each list, (link) =>
      dir         = link.replace CONFIG.domain, ''
      destination = if _.isEmpty(dir) then path.join @buildPath, '/' else path.join @buildPath, dir
      @createPage link, destination

  createPage: (url, destination) ->
    request url, (error, response, body) ->
      throw error if error
      if response.statusCode is 200
        mkdirp destination, (er) ->
          throw er if er
          fs.writeFile "#{destination}index.html", body, (er) ->
            throw er if er
            console.log "#{destination}index.html saved!"

SiteBuild.init()