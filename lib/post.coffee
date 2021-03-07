fs = require 'fs'
st = require 'stream'
request = require 'request-promise'
{json} = require './mappers'

{promisify} = require 'util'
appendFile = promisify fs.appendFile
pipeline = promisify st.pipeline

url = require './mappers/url'
{stream, isStream} = require './stream'

log = require './log'
tempy = require 'tempy'
{uuid} = require 'uuidv4'
path = require 'path'

mkdir = promisify fs.mkdir

getResource = (data)->
  if not data?
    return tempy.file()
  if typeof data == 'object'
    if data?.type == 'directory'
      return tempy.directory()
    if data?.type == 'file'
      return tempy.file()
  if typeof data == 'string'
    return data
  throw new Error "cannot find resource for #{resource}"

post = (content, resource)->
  resource = getResource resource

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

      # from Stream
      if isStream content
        read = stream(content).toNodeStream()
        write = fs.createWriteStream resource

        return pipeline read, write
        .then -> resource

      if typeof content == 'object'
        content = json content

      # from string
      if typeof content == 'string'
        # log.debug 'post.appendFile', resource
        return appendFile(resource, content).then -> resource
        .catch (e)->
          if e.code != 'EISDIR'
            throw e

          resource = path.join resource, uuid()
          # log.debug 'post.appendFile', resource
          return appendFile(resource, content).then -> resource



module.exports = post
