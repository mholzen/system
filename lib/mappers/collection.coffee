{format} = require 'url'

fullUrl = (req, path)->
  format 
    protocol: req.protocol,
    host: req.get 'host'
    pathname: path

module.exports = (data, options)->
  # identify collection
  path = options.req.base
  if path instanceof Array
    path = '/' + path.join '/'

  if path.endsWith '/'
    path += 'Book'    # TODO: too specific
  
  options.res.redirect fullUrl options.req, path
