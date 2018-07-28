mapStream = require 'map-stream'
log = require '@vonholzen/log'

hasRun = false
openUrl = mapStream (result, cb)->
  url = result.url ? result.href
  if (not hasRun) and (typeof url == 'string') and (url.startsWith('http://') or url.startsWith('https://'))
    cmd = 'open "' + url + '"'
    hasRun = true
    exec cmd
  cb null, result

separateLine = mapStream (result, cb)->
  # use https://github.com/75lb/table-layout
  url = result.url ? result.href
  name = result.name
  cb null, url + '\t' + name + "\n"

localeCompareDirectory = (a,b)->
  return if a == '..'
    1
  else if b == '..'
    -1
  else
    a.localeCompare b

sortAs = (order)->
  (a,b)->
    order = order ? []
    aI = order.indexOf(a)
    bI = order.indexOf(b)
    return if aI == bI
      localeCompareDirectory a,b
    else if aI == -1
      1
    else if bI == -1
      -1
    else
      order.indexOf(a) - order.indexOf(b)

module.exports = {
  sortAs
  localeCompareDirectory
}
