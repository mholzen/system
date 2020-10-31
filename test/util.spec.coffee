{sortAs, localeCompareDirectory} = require  'lib/util'

describe 'util', ()->
  describe 'localeCompare', ->
    it 'work', ->
      expect('a'.localeCompare 'b').equal -1
      expect('b'.localeCompare 'a').equal 1
      expect('..'.localeCompare 'a').equal -1
      expect('a'.localeCompare '..').equal 1

  describe 'localeCompareDirectory', ->
    it 'work', ->
      expect(localeCompareDirectory 'a', '..').equal -1
      expect(localeCompareDirectory '..', 'a').equal 1

  describe 'sortAs', ->

    it 'work', ->
      expect([1,2,3].sort sortAs([1,2,3])).eql([1,2,3])
      expect([3,2,1].sort sortAs([1,2,3])).eql([1,2,3])
      expect([1,2,3].sort sortAs([1,2])).eql([1,2,3])
      expect([2,1,3].sort sortAs([1,2])).eql([1,2,3])
      expect([3,2,1].sort sortAs([2,3])).eql([2,3,1])

      expect(['..','A'].sort sortAs()).eql(['A', '..'])
      expect(['a', '..'].sort sortAs()).eql(['a', '..'])
      expect(['..','A'].sort sortAs(['A', 'B'])).eql(['A', '..'])
      expect(['A', '..'].sort sortAs(['A', 'B'])).eql(['A', '..'])

      expect(['a','b','c'].sort sortAs()).eql(['a', 'b', 'c'])
      expect(['c','b','a'].sort sortAs()).eql(['a', 'b', 'c'])
