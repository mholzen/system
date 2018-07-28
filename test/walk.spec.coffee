walk = require 'walk'

describe 'walk', ()->
  it 'should return results with itself', (done)->
    walker = walk.walk '/'
    walker.on "file", (root, fileStats, next)->
      done()
