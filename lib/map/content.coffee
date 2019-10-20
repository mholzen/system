request = require '../request'
log = require '../log'
{stream, isStream} = require '../stream'

fs = require 'fs'
isPromise = require 'is-promise'
_ = require 'lodash'

# warning: async function
get = (data, path)->
  if not (path instanceof Array)
    path = path.split '.'

  path.reduce (memo, element)->
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

content = (from, options)->
  log 'content', {from}
  if typeof from == 'undefined'
    return null

  if stream.isStream from?.items
    log 'content items stream'

  if typeof from == 'string'
    if from.startsWith 'http'
      log 'content url'
      from = url: from
    else
      log 'content file'
      from = path: from

  if from?.path?
    if from.path instanceof Array
      return get options?.root, from.path

    return fileContent(from.path).then (content)->
      return if content instanceof Buffer
        content.toString()
      content

  if from?.url?
    return request(from).then (response)->response.body

  log 'cannot get content', {from}
  throw new Error "cannot get content from #{log.print from}"

content.fileContentSync = fileContentSync
content.get = get

module.exports = content
