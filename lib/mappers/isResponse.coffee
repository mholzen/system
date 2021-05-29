module.exports = (data)->
  (typeof data?.send == 'function') and
  (typeof data?.status == 'function') and
  (typeof data?.type == 'function')

