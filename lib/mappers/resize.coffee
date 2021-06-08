gm = require 'gm'

module.exports = (data, options)->
  type = options?.res?.get 'Content-Type'
  if type?.startsWith 'image/'

    gm data
    .resize('400', '400')
    # .size {bufferStream: true}, (err, size)->
    #   if err?
    #     throw err
    #   @resize size.width / 10, size.height / 10
    .stream()
