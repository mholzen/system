module.exports =
  create: (options)->
    n = options?.n ? 10
    (inputStream)->
      inputStream.take n
