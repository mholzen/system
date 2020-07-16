isPromise = require 'is-promise'
{isStream} = require '../stream'

YAML = require 'json2yaml'

module.exports = (data)->
  YAML.stringify data
