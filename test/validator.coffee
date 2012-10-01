assert = require 'assert'
hygiene = require('../lib/index')

describe 'validator', () ->
  describe '#validate()', () ->
    it 'should return true for empty sanitizer and empty object', (done) ->
      validator = hygiene.validator()
      validator.validate {}, (err, result, resultDetails) ->
        assert.equal(true, result)
        done()
    it 'should return false for empty sanitizer and non-empty object', (done) ->
      validator = hygiene.validator()
      validator.validate {foo: 'bar'}, (err, result, resultDetails) ->
        throw err if err
        assert.equal(false, result)
        done()
    it 'should return false for required property missing', (done) ->
      validator = hygiene.validator().withString('name')
      validator.validate {}, (err, result, resultDetails) ->
        assert.equal(false, result)
        done()
    it 'should return false on defined property with wrong type', (done) ->
      validator = hygiene.validator().withNumber('age')
      validator.validate {age: 'Not a number'}, (err, result, resultdetails) ->
        assert.equal(false, result)
        done()
    it 'should return true on defined property with right type', (done) ->
      validator = hygiene.validator().withNumber('age')
      validator.validate {age: 26}, (err, result, resultDetails) ->
        assert.equal(true, result)
        done()
    it 'should return true on missing required=false property', (done) ->
      validator = hygiene.validator().withString('name').withString('title', {required: false})
      validator.validate {name: 'John Doe'}, (err, result, resultDetails) ->
        throw err if err
        assert.equal(true, result)
        done()
    it 'should show error messages', (done) ->
      validator = hygiene.validator().withString('name').withNumber('age')
      validator.validate {age: 'Not a number'}, (err, result, resultDetails) ->
        throw err if err
        assert.equal(false, result)
        assert.equal("Property 'age' is of wrong type", resultDetails.age)
        assert.equal("Property 'name' is missing", resultDetails.name)
        done()
    it 'should automatically convert strings as numbers', (done) ->
      validator = hygiene.validator().withNumber('age')
      obj = {age: "26"}
      validator.validate obj, (err, result, resultDetails, sanitizedObject) ->
        throw err if err
        assert.equal(true, result)
        assert.strictEqual(26, sanitizedObject.age)
        done()
    it 'should return false on empty required strings', (done) ->
      validator = hygiene.validator().withString('name')
      obj = {name: ''}
      validator.validate obj, (err, result, resultDetails, sanitizedObject) ->
        throw err if err
        assert.equal(false, result)
        assert.equal("Property 'name' is missing", resultDetails.name)
        done()

