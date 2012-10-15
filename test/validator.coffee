assert = require 'assert'
hygiene = require('../lib/index')

describe 'validator', () ->
  describe '#validate()', () ->
    it 'should return true for empty sanitizer and empty object', (done) ->
      validator = hygiene.validator()
      validator {}, (err, result, resultDetails) ->
        assert.equal(true, result)
        done()
    it 'should return false for empty sanitizer and non-empty object', (done) ->
      validator = hygiene.validator()
      validator {foo: 'bar'}, (err, result, resultDetails) ->
        throw err if err
        assert.equal(false, result)
        done()
    it 'should return false for required property missing', (done) ->
      validator = hygiene.validator().withString('name')
      validator {}, (err, result, resultDetails) ->
        assert.equal(false, result)
        done()
    it 'should return false on defined property with wrong type', (done) ->
      validator = hygiene.validator().withNumber('age')
      validator {age: 'Not a number'}, (err, result, resultdetails) ->
        assert.equal(false, result)
        done()
    it 'should return true on defined property with right type', (done) ->
      validator = hygiene.validator().withNumber('age')
      validator {age: 26}, (err, result, resultDetails) ->
        assert.equal(true, result)
        done()
    it 'should return true on missing required=false property', (done) ->
      validator = hygiene.validator().withString('name').withString('title', {required: false})
      validator {name: 'John Doe'}, (err, result, resultDetails) ->
        throw err if err
        assert.equal(true, result)
        done()
    it 'should show error messages', (done) ->
      validator = hygiene.validator().withString('name').withNumber('age').withString('title')
      validator {age: 'Not a number', title: 'Mr.'}, (err, result, resultDetails) ->
        throw err if err
        assert.equal(false, result)
        assert.equal("Property 'age' is of wrong type", resultDetails.age)
        assert.equal("Property 'name' is missing", resultDetails.name)
        assert.strictEqual(undefined, resultDetails.title)
        done()
    it 'should automatically convert strings as numbers', (done) ->
      validator = hygiene.validator().withNumber('age')
      obj = {age: "26"}
      validator obj, (err, result, resultDetails, sanitizedObject) ->
        throw err if err
        assert.equal(true, result)
        assert.strictEqual(26, sanitizedObject.age)
        done()
    it 'should return false on empty required strings', (done) ->
      validator = hygiene.validator().withString('name')
      obj = {name: ''}
      validator obj, (err, result, resultDetails, sanitizedObject) ->
        throw err if err
        assert.equal(false, result)
        assert.equal("Property 'name' is missing", resultDetails.name)
        done()

    it 'should support custom validators', (done) ->
      validator = hygiene.validator().with('property', {validator: (property, value, messages, callback) ->
        return process.nextTick () ->
          return callback(undefined, null)
      })
      validator {'property': 'foo'}, (err, result) ->
        throw err if err
        assert.equal(true, result)
        done()

