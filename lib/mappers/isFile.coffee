
module.exports = (data)->
  stat = data?.stat ? data
  stat?.isFile()