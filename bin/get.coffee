#!/usr/bin/env coffee

searchers = require '../lib/searchers'
{isStream} = require '../lib/stream'
resolve = require '../lib/resolve'
{content, json, args} = require '../lib/mappers'

get = (reference)->
    root = searchers()
    if not reference?
        return root
    return content reference, root: root

a = args process.argv[2..]
reference = args.positional a
data = get reference
data = resolve data     # TODO: should be resolve.deep
data.then (d)->
    process.stdout.write json d
    process.stdout.write '\n'