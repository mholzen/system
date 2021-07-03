creator = require '../lib/creator'
requireDir = require 'require-dir'

generators = creator requireDir './generators'

generators.description = "Functions that accept a single argument and returns a stream"

module.exports = generators