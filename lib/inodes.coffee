log = require '@vonholzen/log'
walk = require 'walk'
{resolve, dirname} = require 'path'
expandTilde = require 'expand-tilde'
_ = require 'lodash'
strings = require './strings'
{join, sep} = require 'path'
{sortAs} = require './util'
{dirname} = require 'path'
stream = require 'highland'

{promisify} = require 'util'
fs = require 'fs'
statAsync = promisify fs.stat
stat = statAsync

# TODO: create a generator that watches a subdirectory
# use it to update symlinks targets

class Stat
  constructor: (path, options)->
    @path = path ? process.cwd()
    @path = expandTilde @path
    @options = options ? {}
    @options.recurse = @options.recurse ? false
    @stat = statAsync @path
    .catch (err)=>
      console.log err
      @err = err
      throw err
    # .then (stat)=>
    #   @stat = stat
    #   @

  # then: (success, failure)->
  #   @stat.then success, failure
    # console.log 'here'
    # if typeof @stat.then != 'function'
    #   return success @
    # @stat

  entries: -> stream @walker()

  # for a file: parent directory
  # for a directory: children and parent directoruy
  #   if root directory, empty
  adjascent: ->
    result = stream()
    parent = dirname @path
    if @path != parent
      result.push parent

    await @stat
    readdir @path

  isDirectory: ->
    # log.debug 'isDirectory entry', {path: @path, stat: @stat}
    if @err?
      throw err
    try
      stat = await @stat
      # log.debug 'isDirectory post await', {stat}
    catch err
      # log.debug 'isDirectory caught', {err: err.toString()}
      throw err
    # log.debug 'isDirectory exit', {stat}
    stat.isDirectory()

  recurse: -> @options.recurse

  get: (path)->
    log.debug 'inodes.get', {'@path': @path, path}
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
      if path.length == 0
        log.debug 'inodes.get empty path. returning this'
        # it doesn't await right here if @stat does not exist
        return this
      p = join @path, ...path
      console.log 'new stat', p
      return new Stat p

    new Error "cannot get with '#{path}'"

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

class Path
  constructor: (path, root)->
    @setPath path
    @setRoot root
    @stat = null
    @remainder = null

  setPath: (path)->
    @path = path
    if typeof path == 'string'
      @segments = path.split '/'   # TODO: must ignore multiple consecutive /

      if path.startsWith '/'
        @root = '/'
        @segments.shift() # remove first ''
      return

    if path instanceof Array
      @segments = path
      return

    throw new Error "cannot setPath with #{path}"

  setRoot: (root)->
    if typeof root == 'string'
      if @path.startsWith '/'
        throw new Error 'root overspecified'
      @root = root
    # if root instanceof Stat
    #   @root = root
    #   return
    if typeof root == 'undefined'
      if not @root?
        @root = process.cwd()
      return
    throw new Error "can't set root from #{root}"

  then: (success)->
    @remainder = Array.from @segments
    @path = @root   # assumes root is accessible
    while @remainder.length > 0
      try
        next = @remainder[0]
        path = join @path, next
        @stat = await statAsync path
        @path = path
        @remainder.shift()
      catch e
        log.debug 'error', {e}
        break
    success()

inodes = (path, options)->
  new Stat path, options

inode = inodes

module.exports = Object.assign inodes, {Stat, statAsync, stat, inode, Path}
