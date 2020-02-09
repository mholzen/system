request = require '../request'
log = require '../log'
{stream, isStream} = require '../stream'

fs = require 'fs'
isPromise = require 'is-promise'
_ = require 'lodash'

# warning: async function
get = (data, path)->
  log.debug {data}
  if not (path instanceof Array)
    path = path.split '.'

  path.reduce (memo, element)->
    if isPromise memo
      log.debug 'get.resolving'
      memo = await memo
      log.debug 'get.resolved', {memo}

    if typeof memo == 'string'
      if typeof element != 'number'
        throw new Error "cannot index a string with a #{element}"
      return memo[element]

    if not (element of memo)
      throw new Error "cannot find '#{element}' in '#{log.print memo}'"

    memo[element]
  , data

fileContent = (path)->
  # TODO: use promise-fs or async-file
  new Promise (resolve, reject)->
    log 'readFile', path
    fs.readFile path, (err, content)->
      return if err
        return if err.code == 'EISDIR'
          fs.readdir path, (err, files)->resolve files
        reject err

      log 'readFile', {content: content.toString()}
      resolve content

fileContentSync = (path)->
  fs.readFileSync path

content = (data, options)->
  log.debug 'content', {data}
  if typeof data == 'undefined'
    return null

  if stream.isStream data?.items
    log 'content items stream'

  if typeof data == 'string'
    if data.startsWith 'http'
      log 'content url'
      data = url: data
    else
      log 'content file'
      data = path: data

  if data instanceof Array
    data = {path: data}

  if data?.path?
    if data.path instanceof Array
      return get options?.root, data.path

    return fileContent(data.path).then (content)->
      return if content instanceof Buffer
        content.toString()
      content

  if data?.url?
    return request(data).then (response)->response.body

  log 'cannot get content', {data}
  throw new Error "cannot get content from #{log.print data}"

content.fileContentSync = fileContentSync
content.get = get

module.exports = content
