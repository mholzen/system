fs = require 'fs'
request = require 'request-promise'

{promisify} = require 'util'
appendFile = promisify fs.appendFile
url = require './map/url'
{Stream} = require 'stream'
highland = require 'highland'
log = require '@vonholzen/log'
tempy = require 'tempy'
uuidv1 = require 'uuid/v1'
path = require 'path'

post = (content, resource)->
  if not resource?
    resource = tempy.file()
  if typeof resource == 'string'
    try
      return request
        url: url resource
        method: 'POST'
        body: content
    catch

      # to file

      # from string
      if typeof content == 'string'
        log 'post.appendFile', resource
        return appendFile(resource, content).then -> resource
        .catch (e)->
          if e.code != 'EISDIR'
            throw e

          resource = path.join resource, uuidv1()
          log 'post.appendFile', resource
          return appendFile(resource, content).then -> resource

      # from Stream
      if content instanceof Stream
        return highland(content).each (chunk)->
          await appendFile(resource, chunk)
        .toPromise(Promise).then ->
          resource


module.exports = post
