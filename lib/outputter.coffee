{json} = require './mappers'

outputter = (stdout, stderr)->
  (stream)->
    stream.map json
    .errors (err)->
      stderr.write err.toString() + '\n' + err.stack + '\n'
    .each (line)->
      stdout.write line + '\n'

module.exports = outputter