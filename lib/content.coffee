request = require './request'
fs = require 'fs'
log = require '@vonholzen/log'
stream = require './stream'

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

content = (from)->
  if typeof from == 'undefined'
    return null

  log 'content pre', from
  if stream.isStream from?.items
    log 'content stream'
    return from.items

  if typeof from == 'string'
    if from.startsWith 'http'
      from = url: from
    else
      from = path: from

  if from?.path?
    return fileContent(from.path).then (content)->
      return if content instanceof Buffer
        content.toString()
      content

  if from?.url?
    return request(from).then (response)->response.body

  throw new Error "cannot get content from #{from}"

module.exports = content
