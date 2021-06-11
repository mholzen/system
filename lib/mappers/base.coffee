
module.exports = (data, options)->
  base = undefined

  if options?.req?
    base = '/' + options.req.base.join '/'
    base += options.req.filename

  if options?.res?
    options.res.type 'text/plain'

  return base

