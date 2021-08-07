module.exports = (data)->
  data?.__HighlandStream__? or
  data?._readableState? or
  data?._writableState?
