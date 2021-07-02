{NotMapped} = require '../errors'
{appendFile} = require 'fs/promises'
isRequest = require './isRequest'
string = require './string'

destination = (data)->
  if isRequest data
    # TODO: should use the file handlers somehow?
    return 'data/requests.jsonl'
  throw new NotMapped data, 'destination'

module.exports = (data, options)->
  appendFile (destination data), (string data) + "\n"