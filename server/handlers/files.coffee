{
  inodes
  mappers: {content}
  log
} = require '../../lib'

handler = (req, res, router) ->
  path = req.remainder ? []
  log.debug 'files entry', {path, router}
  try
    inodePath = new inodes.Path path, router?.options?.config?.files?.root
    await inodePath
  catch err
    if err.toString().includes 'ENOENT'
      log.debug 'ENOENT', {path}
      # path should equal the remainder
    else
      throw err

  req.remainder = inodePath.remainder    # path contains un-matching remaining elements
  req.data = content inodePath.path, parse: false
  req.filename = inodePath.path          # TODO: consider a scoped or different name?

  log.debug 'files return', {path: inodePath.stat, remainder: req.remainder, data: req.data}

module.exports = handler