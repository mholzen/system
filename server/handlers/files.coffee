{
  inodes
  mappers: {content, type}
  log
} = require '../../lib'
{dirname} = require 'path'

handler = (req, res, router) ->
  path = req.remainder ? []
  # log.debug 'files entry', {path, options: router.options}
  try
    inodePath = new inodes.Path path, router?.options?.config?.files?.root
    await inodePath
  catch err
    if err.toString().includes 'ENOENT'
      log.debug 'ENOENT', {path}
      # path should contain the remainder
    else
      throw err

  req.remainder = inodePath.remainder    # path contains un-matching remaining elements
  req.files =
    remainder: Array.from req.remainder
  req.data = content inodePath.path, parse: false
  req.filename = inodePath.path          # TODO: consider a scoped or different name?
  req.dirname = if inodePath.stat.isDirectory() then inodePath.path else dirname inodePath.path
  req.dirname += '/'

  req.reldirname = req.dirname.slice inodePath.root.length + 1
  # TODO: use previously set req.base.  perhaps use an array?
  req.base = '/files' + req.dirname.slice inodePath.root.length

  t = (type req) ? 'text/plain'
  res.type t

  # log.debug 'files return', {path: inodePath.stat, remainder: req.remainder, data: req.data}

module.exports = handler
