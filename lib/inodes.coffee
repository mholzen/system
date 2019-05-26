log = require '@vonholzen/log'
walk = require 'walk'
{resolve, dirname} = require 'path'
expandTilde = require 'expand-tilde'
_ = require 'lodash'
strings = require './strings'
{join, sep} = require 'path'
{sortAs} = require './util'
p = require 'path'
stream = require 'highland'

{promisify} = require 'util'
fs = require 'fs'
statAsync = promisify fs.stat

# TODO: create a generator that watches a subdirectory
# use it to update symlinks targets

class Stat
  constructor: (path, options)->
    @path = path ? process.cwd()
    @path = expandTilde @path
    @name = 'inodes'
    @options = options ? {}
    @options.recurse = @options.recurse ? false
    log 'inodes.Stat', {path:@path}
    @stat = statAsync(@path)
    @items = stream @walker()

  # toJSON: ->
  #   name: 'inodes'

  isDirectory: ->
    stat = await @stat
    stat.isDirectory()

  recurse: -> @options.recurse

  get: (path)->
    if not path?
      return this

    if typeof path == 'string'
      if path.startsWith sep    # absolute
        if not path.startsWith @path
          throw new Error 'get with absolute path does not match @path'
        path = path[ @path.length .. ]

      # relative path
      path = expandTilde path
      path = path.split sep

    if path instanceof Array
      log 'inodes.get', {path}
      if path.length == 0
        log 'inodes.get return this'
        return this

      try
        if await @isDirectory()
          next = path.shift()
          return new Stat(join @path, next).get path

        # this file is the resource
        log 'inodes.get found file', {remainder: path}
        return this

      catch error
        log 'inodes.get', {error}
        throw error


  walker: ->
    root = @path
    directories = {}
    (push, streamNext)=>
      directories = {}
      walker = walk.walk root, {followLinks: true}   # can cause recursive loop
      .on 'error', (err)->
        push err
      .on 'end', ()->
        log 'file.end'
        push null, stream.nil

      .on 'file', (base, stat, next) ->
        stat.path = resolve base, stat.name
        log 'file.onFile', stat.path
        push null, stat
        # streamNext()
        next()
      .on 'directory', (base, stat, next) ->
        stat.path = resolve base, stat.name
        log 'file.onDirectory', stat.path
        push null, stat
        # streamNext()
        next()
      .on 'directories', (base, dirStatsArray, next) =>
        if not @recurse()
          log 'file.directories not recursing'
          dirStatsArray.length = 0
          next()
          return

        parent = resolve base, '..'
        if parent != '/'
          log 'file.onDirectories', {parent}
          parentStat = fs.statSync parent
          dirStatsArray.push {name: '..', ino: parentStat.ino}

        log 'file.onDirectories', dirStatsArray.map (d)->d.name
        dirStatsArray.forEach (stat, index)->
          path = resolve base, stat.name

          if directories[stat.ino]?
            log 'file.onDirectories ignoring already seen', path
            delete dirStatsArray[index]

          directories[stat.ino] = 1

        # re-order directories
        log 'file.order re-ordering'
        try
          order = await strings join(base, '.order')
          log 'file.order according', {order}

        catch err
          if err?.errno == -2  # ENOENT: no such file or directory
            order = []
          else
            throw err

        # does this table have to be sorted in reverse order?
        dirStatsArray = dirStatsArray.sort (a,b)->
          sortAs(order) b.name, a.name

        log 'file.order sorted', dirStatsArray.map (d)->d.name
        next()

stat = (args...)->
  new Stat args...

stat.Stat = Stat
stat.statAsync = statAsync

module.exports = stat
