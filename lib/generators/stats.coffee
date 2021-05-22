{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat
stream = require '../stream'

# queue.push data
# while queue.pop
#   if data identifies a directory or a symlink to a directory
#     queue.push content data
#     yield data

module.exports = (data, options)->
  if typeof data == 'string'
    return stream stat data