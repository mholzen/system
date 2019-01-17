log = require '@vonholzen/log'
walk = require 'walk'
{resolve, dirname} = require 'path'
expandTilde = require 'expand-tilde'
_ = require 'lodash'
{createQuery} = require './query'
{strings} = require '../lib'
{join} = require 'path'
{sortAs} = require './util'
p = require 'path'

{promisify} = require 'util'
fs = require 'fs'
statAsync = promisify fs.stat

types = ['file', 'directory', 'inode']

class Stat
  constructor: (path)->
    @path = path
    @stat = statAsync path
  isDirectory: ->
    await @stat.isDirectory()

class Directory
  constructor: (path)->
    @path = path
    @stat = statAsync path

  get: (resource, options)->
    if options?.allowPartial
      path = @path
      for part of resource.split()
        stat = new Stat join part
        continue if stat.isDirectory()
        if stat.isFile()
          return new File path, parts[..remainder]

    resource = p.join @path, resource
    # WHY NOT await here?
    statAsync(resource).then (stat)->
      if not stat
        throw new Error 'NOT FOUND'
      if stat.isDirectory()
        return new Directory resource
      if stat.isFile()
        return new File resource

      throw new Error 'CANNOT CONVERT TO A DIRECTORY'

class File
  constructor: (path)->
    @path = path
    @stat = statAsync path

  get: (path)->
    resource = p.join @path, path
    # WHY NOT await here?
    statAsync(resource).then (stat)->
      if not stat
        throw new Error 'NOT FOUND'
      if not stat.isDirectory()
        throw new Error 'CANNOT CONVERT TO A DIRECTORY'
      new Directory resource


file =
  types: types

  toString: ()->
    types.map (type)-> 'type:'+type
    .join '\n'

  defaultPathQuery: createQuery [
    '-/.'
    '-/node_modules'
    '-/.git'
    '-/.npm'
    '-/archive'
    '-/backup'
    '-/iTunes'
    '-/Library'
    '-.photoslibrary'
    '-.imovielibrary'
    '-.fcpbundle'
    ]

  head: (query) ->
    if query.type?
      return types.includes query?.type

  search: (query, out)->
    query = createQuery query
    return if query.options.type? and not types.includes query.options.type
    if not query.options.recurse?
      query.options.recurse = true

    # provide option to remove defaultPathQuery
    query.path =
      if query.path?
        file.defaultPathQuery.and query.path
      else
        file.defaultPathQuery

    root = expandTilde query.in ? process.cwd()

    if query.depth == 0
      out.write this
      out.end
      return

    log 'file.walk', query
    directories = {}
    walk.walk root, {followLinks: true}   # can cause recursive loop
    .on 'file', (base, stat, next) ->
      stat.path = resolve base, stat.name
      log 'file.onFile', stat.path

      # TODO: type test should be moved out of '.on file'
      if (not query.type? or ['file', 'inode'].includes query.type) and query.test stat
        try
          out.write stat
        catch err
          log 'file.error', err

      next()

    .on 'directory', (base, stat, next) ->
      stat.path = resolve base, stat.name
      log 'file.onDirectory', stat.path

      if (not query.type? or ['directory', 'inode'].includes query.type) and query.test stat
        # console.log 'writing', query.context, result base, stat
        try
          out.write stat
        catch err
          log 'file.error', err

      next()

    .on 'directories', (base, dirStatsArray, next)->

      parent = resolve base, '..'
      if parent != '/'
        log 'file.onDirectories', parent
        parentStat = fs.statSync parent
        dirStatsArray.push {name: '..', ino: parentStat.ino}

      log 'file.onDirectories', dirStatsArray.map (d)->d.name
      dirStatsArray.forEach (stat, index)->
        path = resolve base, stat.name

        if directories[stat.ino]?
          log 'file.onDirectories ignoring already seen', path

        if (not query.options.recurse) or (not query.path.match(path)) or (directories[stat.ino])?
          delete dirStatsArray[index]

        directories[stat.ino] = 1

      # re-order directories
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

    .on 'error', (err)->
      # should be overwritable by the caller
      throw err

    .on 'end', ()->
      # console.log 'end'
      out.end()

  File: File
  file: (path) -> new File path

  Stat: Stat
  stat: (path) -> new Stat path

  Directory: Directory
  directory: (path)-> new Directory path


module.exports = file
