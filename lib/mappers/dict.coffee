module.exports = (data, options)->
  # NOTE: idempotent side effect
  if typeof options?.res?.type == 'function'
    options.res.type 'text/plain'

  if data instanceof Buffer   # TODO: how do we genericize this
    data = data.toString()

  if data?.startsWith? '{'
    try
      return JSON.parse data
    catch e
      e.data = data
      throw e

  name = options?.name ? 'value'

  return
    [name]: data