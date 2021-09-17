{NotMapped} = require 'lib/errors'
path = require 'lib/path'
isLiteral = require 'lib/mappers/isLiteral'

module.exports =
  create: (root)->

    findArray = (data)->
      p = path data, root
      if p.reached()
        return p.to

      if p.remainder().length > 0
        if typeof p.to != 'function'
          throw new Error "overspecified path does not point (pos: #{p.position}) to a function #{log.print p.to}"

      args = p.remainder()
      f = p.to.call @, args...
      log {p, f, remainder: args}
      return f

    (memo, data)->
      if Array.isArray data
        f = findArray data

      if typeof data == 'string'
        f = root[data]

      if not f?
        # throw new NotMapped data, root
        throw new Error "cannot use '#{log.print data}' in '#{log.print root}'"

      if isLiteral f
        log 'return', {f}
        return f

      if typeof f == 'function'
        return f memo

      if typeof f.create == 'function'
        return f.create memo

      throw new Error "cannot find #{log.print data} in #{log.print root}.  Got #{log.print f}"