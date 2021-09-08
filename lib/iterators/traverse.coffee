node = require '../mappers/node'

follow = (data, edge)->   # TODO: should be a reducer with edge being a path of edge
  data[edge]

asyncTraverse = (data, options)->
  nodeFn = options?.node ? node
  followFn = options?.follow ? follow

  {value, edges} = await nodeFn data               # TODO: await for async `traverse`

  if value?
    yield {value, path: []}

  for edge from edges
    d = followFn data, edge                        # TODO: use mappers/get, potential async
    for await i from asyncTraverse d, options      # TODO: await for async `traverse`
      i.path.unshift edge
      yield i

  return

create = (options1)->
  # log 'traverse', {options1}

  traverse = (data, options)->
    noPath = options?.noPath ? options1?.noPath ? false
    nodeFn = options?.node ? node
    followFn = options?.follow ? follow

    # log 'start', {data}
    {value, edges} = nodeFn data            # TODO: await for async `traverse`

    # log 'traverse node received', {value, edges}

    if value?
      if not noPath
        value = {value, path: []}
      # log 'yield post', {value, npPath}
      yield value

    if not edges?
      # log 'returning; no edges'
      return

    for edge from edges
      # log 'edge', {edge}
      d = followFn data, edge
      for i from traverse d, options      # TODO: await for async `traverse`
        if not noPath
          i.path.unshift edge
        # log 'yield', {value: i}
        yield i

    # WARNING: apparently, this line in needed
    # log 'returning'
    return

  return traverse

module.exports = Object.assign create(), {
  create
  asyncTraverse
}
