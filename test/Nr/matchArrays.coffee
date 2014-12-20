matchArrays = require '../../Nr/matchArrays'

describe 'Nr/matchArrays', ->
  it 'should return true for a match', ->
    matched = matchArrays {one: 1, two: 2}, {one: 1, two: 2}
    Should.exist matched
    matched.should.equal true

  it 'should return false for a mismatch', ->
    matchArrays({one: 1, two: 3}, {one: 1, two: 2}).should.equal false
 
  it 'should return false if there is a new value', ->
    matchArrays({one: 1, two: 2, three: 3}, {one: 1, two: 2}).should.equal false

  it 'should return true for new values on the second parameter', ->
    matchArrays({one: 1, two: 2}, {one: 1, two: 2, three: 3}).should.equal true
