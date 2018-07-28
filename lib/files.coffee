#!/usr/   bin/env coffee
out = process.stdout

# paths = [ '/Applications' ]  # TODO: add $HOME
# applications =
#   search: (match)->
#     paths.map (path)->

filewalker = require 'filewalker'
path = require 'path'

files =
  search: (match)->
    if typeof match == 'string'
      match =
        name: match
    root = if match?.in? then match.in else '/'
    filewalker root
    .on 'file', (p) ->
      if match?.name?
        return if not p.includes match.name
      out.write path.resolve(root,p) + '\n'
    .walk()

search = (match)->
  files.search match

  # applications.search match
  # .then (application)->
  #   out.write application

search process.argv[2]
