fs = require 'fs'
st = require 'stream'
request = require 'request-promise'

{promisify} = require 'util'
appendFile = promisify fs.appendFile
pipeline = promisify st.pipeline

url = require './map/url'
{stream, isStream} = require './stream'

log = require './log'
tempy = require 'tempy'
uuidv1 = require 'uuid/v1'
path = require 'path'

mkdir = promisify fs.mkdir

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
      # to filesystem
      if resource.endsWith '/'
        await mkdir resource

      if content == null
        return resource

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
      if isStream content
        read = stream(content).toNodeStream()
        write = fs.createWriteStream resource

        pipeline read, write
        .then -> resource


module.exports = post
