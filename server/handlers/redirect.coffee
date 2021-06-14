{NotFound} = require '../../lib/errors'

url = (req)->
  if req.remainder.length > 0
    return '/' + req.remainder.join '/'

  req.data

module.exports = (req, res, router)->
  log.debug 'redirecting', {url: url req}
  res.redirect url req