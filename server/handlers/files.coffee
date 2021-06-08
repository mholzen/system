# TODO: move /files handler to /generators/files in order to be consistent
{
  inodes
  mappers: {content, type}
  log
} = require '../../lib'
{dirname} = require 'path'
os = require 'os'

# TODO: express files as a function of /dir
create = (root)->

  (req, res) ->
    path = req.remainder ? []

    localroot = root
    if typeof req.data == 'string'
      localroot = req.data

    # log.debug 'files entry', {path, root}
    try
      inodePath = new inodes.Path path, localroot
      await inodePath
    catch err
      if not err.toString().includes 'ENOENT'
        throw err
      # log.debug 'ENOENT', {path}

    req.remainder = inodePath.remainder         # path contains un-matching remaining elements
    req.files =
      remainder: Array.from req.remainder
    options = Object.assign {}, parse: false    #, req.args.options  # TODO: document need
    req.data = content inodePath.path, options

    req.filename = inodePath.path               # TODO: replace with req.params.filename
    req.params.filename = req.filename

    req.dirname = if inodePath.stat.isDirectory() then inodePath.path else dirname inodePath.path
    req.dirname += '/'
    req.params.dirname = req.dirname            # TODO: remove duplicate

    req.reldirname = req.dirname.slice inodePath.root.length + 1

    # TODO: use previously set req.base.  perhaps use an array?
    req.base ?= []
    req.base.push 'files'
    req.base.push req.dirname.slice inodePath.root.length + 1
    req.params.base = req.base

    if typeof res?.type == 'function'
      # TODO: consider using a req.params instead
      res.type (type req) ? 'text/plain'

    log.debug 'files return', {path: inodePath.stat, remainder: req.remainder, data: req.data}

module.exports = create()
Object.assign module.exports, {create}