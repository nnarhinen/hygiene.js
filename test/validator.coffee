assert = require 'assert'
hygiene = require('../lib/index')

describe 'validator', () ->
  describe '#validate()', () ->
    it 'should return true for empty sanitizer and empty object', () ->
      validator = hygiene.validator()
      assert.equal(true, validator.validate({}))
    it 'should return false for empty sanitizer and non-empty object', () ->
      validator = hygiene.validator()
      assert.equal(false, validator.validate({foo: 'bar'}))
    it 'should return false for required property missing', () ->
      validator = hygiene.validator().withString('name')
      assert.equal(false, validator.validate({}))
    it 'should return false on defined property with wrong type', () ->
      validator = hygiene.validator().withNumber('age')
      assert.equal(false, validator.validate({age: 'Not a number'}))
    it 'should return true on defined property with right type', () ->
      validator = hygiene.validator().withNumber('age')
      assert.equal(true, validator.validate({age: 26}))
