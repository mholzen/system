{
  inodes
  mappers: {content, type}
  log
} = require '../../lib'
{dirname} = require 'path'
os = require 'os'

create = (root)->

  (req, res) ->
    path = req.remainder ? []
    # log.debug 'files entry', {path, root}
    try
      inodePath = new inodes.Path path, root
      await inodePath
    catch err
      if not err.toString().includes 'ENOENT'
        throw err
      # log.debug 'ENOENT', {path}

    req.remainder = inodePath.remainder     # path contains un-matching remaining elements
    req.files =
      remainder: Array.from req.remainder
    options = Object.assign {}, parse: false, req.args.options
    req.data = content inodePath.path, options

    req.filename = inodePath.path           # TODO: replace with req.params.filename
    req.params.filename = req.filename

    req.dirname = if inodePath.stat.isDirectory() then inodePath.path else dirname inodePath.path
    req.dirname += '/'
    req.params.dirname = req.dirname        # TODO: remove duplicate

    req.reldirname = req.dirname.slice inodePath.root.length + 1

    # TODO: use previously set req.base.  perhaps use an array?
    req.base = '/files' + req.dirname.slice inodePath.root.length
    req.params.base = req.base

    res.type (type req) ? 'text/plain'

    # log.debug 'files return', {path: inodePath.stat, remainder: req.remainder, data: req.data}

#module.exports = handler
module.exports =
  root: create '/'
  home: create os.homedir()
  cwd: create()
