Mocha = require 'mocha'
glob = require 'glob-promise'

chai = require 'chai'
chai.use require 'chai-string'
chai.use require 'chai-arrays'
global.expect = chai.expect
global.log = require '@vonholzen/log'
global._ = require 'lodash'

log = require '../log'
stream = require '../stream'

run = (data, options)->
  files = await glob("test/**.spec.coffee")
  mocha = new Mocha()
  files.forEach (f)->mocha.addFile f

  runner = mocha.run()
  results = stream (push, next)->
    if options.remainder?[0] == 'all'   # doesn't work
      runner.on 'pass', (test) ->
        push null,
          test: test.fullTitle()
          title: test.title
          duration: test.duration
        # next()

    runner.on 'fail', (test, err) ->
      push null,
        test: test.fullTitle()
        err: err.message
        stack: err.stack.split '\n'
        file: test.file
        body: test.body.split '\n'
      # next()
    .on 'end', (d)->
      log.debug 'tests end'
      push null, stream.nil
 

  # results = []
  # new Promise (resolve, reject)->
  #     mocha.run()
  #     .on 'pass', (test) ->
  #       results.push
  #         test: test.fullTitle()
  #         title: test.title
  #         duration: test.duration

  #     .on 'fail', (test, err) ->
  #       console.log {test, err}
  #       results.push
  #         test: test.fullTitle()
  #         err: err.message
  #         stack: err.stack.split '\n'
  #         file: test.file
  #         body: test.body.split '\n'
  #     .on 'end', (d)->
  #       # log.debug 'suite end', {d}
  #       resolve {files, results}

module.exports = run
