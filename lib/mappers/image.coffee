log = require '../log'
name = require './name'

image = (data)->
  if data instanceof Array
    # need to know the context?
    return

  if typeof data == 'string'
    return
      image:
        src: './' + data
    # return '<img src="./' + escape data + "}'/>"   # TODO: htmlescape

  if (n = name data)?
    return
      image: "/files/data/images/#{log.print n}"
      shape: 'circularImage'

module.exports = image
