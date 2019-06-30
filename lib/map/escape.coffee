module.exports = (options)->
  (data)->
    if typeof data == 'string'
      re = / /gi
      return data.replace re, '\\ '

    data
