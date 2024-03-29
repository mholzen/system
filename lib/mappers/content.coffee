request = require './request'
log = require '../log'
{stream, isStream} = require '../stream'
inodes = require '../inodes'
parse = require '../parse'
filepath = require './filepath'

fs = require 'fs'
isPromise = require 'is-promise'
_ = require 'lodash'
{join} = require 'path'

# warning: async function
get = (data, path)->
  if not (path instanceof Array)
    path = path.split '.'

  path.reduce (memo, element)->
    if isStream memo
      memo = await memo.toPromise Promise

    if isPromise memo
      memo = await memo

    if typeof memo == 'string'
      if typeof element != 'number'
        throw new Error "cannot index a string with a #{element}"
      return memo[element]

    if not (element of memo)
      throw new Error "cannot find '#{element}' in '#{log.print memo}'"

    memo[element]
  , data


isAbsolute = (path)->
  return true if path[0] == '/'
  return true if path[0..1] == './'
  return true if path[0..2] == '../'

fileStream = (path, options)->
  if options?.dirname?
    if not isAbsolute path
      path = options?.dirname + '/' + path

  # log 'creating readstream', {path}
  fs.createReadStream path

fileContent2 = (path, options)->
  fileStream path, options

fileContent = (path, options)->
  # TODO: use promise-fs or async-file
  new Promise (resolve, reject)->
    # log 'readFile', {path, options}
    fs.readFile path, (err, content)->
      return if err
        return if err.code == 'EISDIR'
          fs.readdir path, (err, files) ->
            if options?.recurse > 0
              resolve files.map (name)->
                file = join path, name
                return
                  name: name
                  content: fileContent file, recurse: options.recurse-1
            else
              resolve files
        reject err

      # log 'readFile', {content}
      resolve content

fileContentSync = (path)->
  fs.readFileSync path

urlRegExp = /https?:\/\/(www\.)?[-a-zA-Z0-9@:%._\+~#=]{1,256}\.[a-zA-Z0-9()]{1,6}\b([-a-zA-Z0-9()@:%_\+.~#?&//=]*)/

toObject = (string, context)->
  if urlRegExp.test string
    return url: string
  if string.startsWith '/'
    return path: string
  if string.startsWith '{'
    return JSON.stringify string
  if (fp = filepath string)?
    return path: fp
  throw new Error "cannot make object from string #{string}"

content = (data, options)->
  # log {data, options}
  try
    fp = filepath data, options
    return fileContent fp, options
  catch err
    # try other things
    log.error 'content', {err}

  if typeof data == 'undefined'
    return null

  if typeof data == 'string'
    # TODO: should use `get`
    if options?.root? and data of options.root
      return options.root[data]

    data = toObject data

  if data instanceof Array
    # TODO: that's clearly not always true
    data = {path: data}

  if data?.path?
    if data.path instanceof Array
      return get options?.root, data.path # returns a promise

    if data?.type == 'directory'
      return inodes(data.path).entries()

    return fileContent(data.path, options).then (content)->
      if options?.parse == false
        return content
      if options?.parse == 'string'
        return content.toString()
      if content instanceof Buffer
        return parse content.toString()
      content

  if data?.url?
    return request(data).then (response)->response.body

  throw new Error "cannot get content from '#{log.print data}'"

content.fileContentSync = fileContentSync
content.get = get

module.exports = content
