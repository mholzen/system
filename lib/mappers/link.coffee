log = require '../log'

a = (href, content, isDirectory)->
  postfix = if isDirectory then '/' else ''
  a:
    href: './' + href
    text: content + postfix    # TODO: should support content instead of text

module.exports = (data, options)->
  
  if typeof data?.name == 'string'
    remainder = options?.req.files.remainder.join '/'
    href = data.name + '/' + remainder
    content = data.name

  isDirectory = data?.stat?.isDirectory()
  
  return a href, content, isDirectory