request = require './request'
fs = require 'fs'
log = require '@vonholzen/log'
{stream, isStream} = require './stream'

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

content = (from, context)->
  log 'content', {from}
  if typeof from == 'undefined'
    return null

  if stream.isStream from?.items
    log 'content items stream'

    if isStream context
      log 'content pipe'
      return context.pipe from.items
    else
      log 'content items'
      return from.items

  if typeof from == 'string'
    if from.startsWith 'http'
      log 'content url'
      from = url: from
    else
      log 'content file'
      from = path: from

  if from?.path?
    return fileContent(from.path).then (content)->
      return if content instanceof Buffer
        content.toString()
      content

  if from?.url?
    return request(from).then (response)->response.body

  log 'cannot get content', {from}
  throw new Error "cannot get content from #{from}"

content.fileContentSync = fileContentSync

module.exports = content
