log = require '../log'
type = require './type'

# TODO: consider renaming 'reference'
# is a 'reference' different from 'a displayed reference' (html.a) ?

# TODO: consider genericizing this method with a map based on type

href = (data, options)->
  if typeof data?.name == 'string'
    res = data.name

    if typeof data?.stat == 'object'
      if data.stat.isDirectory()
        res += '/directory'

    return './' + res

# TODO: should support content instead of text
text = (data, options)->
  if typeof data?.name == 'string'

    if type(data, options)?.startsWith 'image'
      return '<img src="' + href(data, options) + '"/>'

    postfix = if data?.stat?.isDirectory() then '/' else ''
    return data.name + postfix

module.exports = (data, options)->
  a:
    href: href data, options
    text: text data, options
