
module.exports = (data)->
  stat = data?.value ? data
  stat?.isFile()