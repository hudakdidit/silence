#########################################################
# Title:  Sitemap Scraper
# Author: jonathan@wintr.us @ WINTR
#########################################################

#--------------------------------------------------------
# Requirements
#--------------------------------------------------------

_         = require 'lodash'
fs        = require 'fs'
jf        = require 'jsonfile'
path      = require 'path'
touch     = require 'touch'
parse     = require 'xml-parser'
rimraf    = require 'rimraf'
request   = require 'request'
mkdirp    = require 'mkdirp'
inspect   = require('util').inspect


#--------------------------------------------------------
# Configuration
#--------------------------------------------------------

configuration = ->
  @domain  = process.argv[2]
  @sitemap = if process.argv[3]? then "#{@.domain}#{process.argv[3]}" else "#{@.domain}/sitemap.xml"
  @build   = if process.argv[4]? then process.argv[4] else 'build'
  @log     = './build/log.json'

CONFIG = new configuration()


#--------------------------------------------------------

Scraper =
  buildPath: path.join(__dirname, CONFIG.build)
  init: ->
    @clean()
    @fetchSitemap()

  clean: ->
    rimraf(@buildPath, (err) ->
      throw err if err)

  log: (msg, finished = false) ->
    jf.writeFile CONFIG.log, {status: msg}, =>
      if finished
        @log 'finished'
    @deleteLog() if msg is 'finished'

  deleteLog: ->
    setTimeout =>
      fs.unlink CONFIG.log, (err) ->
        throw err if err
    , 1000

  fetchSitemap: ->
    request CONFIG.sitemap, (error, response, body) =>
      throw error if error
      if response.statusCode is 200
        mkdirp "#{@buildPath}", (err) =>
          throw err if err
          touch CONFIG.log
          @log 'starting', false
          xml_object = parse body
          @createLinkList xml_object.root.children

  createLinkList: (children) ->
    list = []
    _.each children, (child, i) ->
      list.push child.children[0].content
    _.each list, (link, i) =>
      dir         = link.replace CONFIG.domain, ''
      destination = if _.isEmpty(dir) then path.join @buildPath, '/' else path.join @buildPath, dir
      final = if i is list.length - 1 then true else false
      @createPage link, destination, final
      return
    return

  createPage: (url, destination, final) ->
    request url, (error, response, body) =>
      throw error if error
      if response.statusCode is 200
        setTimeout =>
          mkdirp destination, (er) =>
            throw er if er
            page = destination.replace @buildPath, ''
            fs.writeFile "#{destination}index.html", body, (er) =>
              throw er if er
              @log "scraping: #{page}", final
        , 300


#--------------------------------------------------------
# Start
#--------------------------------------------------------

Scraper.init()