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
    it 'should return false for required property null', (done) ->
      validator = hygiene.validator().withString('name')
      validator {name: null}, (err, result, resultDetails) ->
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
    it 'should return true on empty strings with required=false', (done) ->
      validator = hygiene.validator().withString('name').withString('title', {required: false})
      validator {name: 'John Doe', title: ''}, (err, result, resultDetails) ->
        throw err if err
        assert.equal(true, result)
        done()
    it 'should return true on null values with required=false', (done) ->
      validator = hygiene.validator().withString('name').withString('title', {required: false})
      validator {name: 'John Doe', title: null}, (err, result, resultDetails) ->
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

    it 'should set default values for missing properties', (done) ->
      validator = hygiene.validator().withBoolean('is_active', {required: false, defaultValue: true})
      validator {}, (err, result, validationErrors, sanitizedObject) ->
        throw err if err
        assert.equal(true, result)
        assert.equal(true, sanitizedObject.is_active)
        done()


describe "StringListValidator", () ->
  it "should validate comma separated list as string array", (done) ->
    validator = hygiene.validator().withStringList("tags")
    obj = {tags: "foo,bar,baz"}
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal true, result
      assert.deepEqual {tags: ["foo", "bar", "baz"]}, sanitizedObject
      done()

describe "StringArrayValidator", () ->
  it "should validate arrays", (done) ->
    validator = hygiene.validator().withStringArray("tags")
    obj = {tags: ["foo", "bar", "baz"]}
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal true, result
      assert.deepEqual {tags: ["foo", "bar", "baz"]}, sanitizedObject
      done()
  it "should check for type", (done) ->
    validator = hygiene.validator().withStringArray("tags")
    obj = {tags: "foo"}
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal false, result
      assert.equal "Property 'tags' is of wrong type", resultDetails.tags
      done()
  it "should check for array items type", (done) ->
    validator = hygiene.validator().withStringArray("tags")
    obj = {tags: ["foo", 1, true]}
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal false, result
      assert.equal "Property 'tags' is of wrong type", resultDetails.tags
      done()

describe "ObjectValidator", () ->
  it "should validate objects with an embedded validator", (done) ->
    innerValidator = hygiene.validator().withString("name")
    validator = hygiene.validator().withObject("inner", innerValidator)
    obj =
      inner:
        name: "Foo"
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal true, result
      assert.deepEqual {inner: {name: "Foo"}}, sanitizedObject
      done();

  it "should fail when embedded validator fails", (done) ->
    innerValidator = hygiene.validator().withString("name")
    validator = hygiene.validator().withObject("inner", innerValidator)
    obj =
      inner:
        name_foo: "Foo"
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal false, result
      assert.equal "Property 'name' is missing", resultDetails.inner.name
      done();

describe "ObjectArrayValidator", () ->
  it "should validate an array of objects with an embedded validator", (done) ->
    innerValidator = hygiene.validator().withString("name")
    validator = hygiene.validator().withObjectArray("inners", innerValidator)
    obj =
      inners: [{name: "Foo"}]
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal true, result
      assert.deepEqual {inners: [{name: "Foo"}]}, sanitizedObject
      done();

  it "should fail when embedded validator fails", (done) ->
      innerValidator = hygiene.validator().withString("name")
      validator = hygiene.validator().withObjectArray("inners", innerValidator)
      obj =
        inners: [{name: 'Bar'}, {name_foo: "Foo"}]
      validator obj, (err, result, resultDetails, sanitizedObject) ->
        throw err if err
        assert.equal false, result
        assert.equal "Property 'name' is missing", resultDetails.inners[1].name
        done();


describe "BooleanValidator", () ->
  it "should validate booleans", (done) ->
    validator = hygiene.validator().withBoolean("is_public")
    obj = {is_public: true}
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal true, result
      done()
  it "should check for type", (done) ->
    validator = hygiene.validator().withBoolean("is_public")
    obj = {is_public: "asdf"}
    validator obj, (err, result, resultDetails) ->
      throw err if err
      assert.equal false, result
      assert.equal "Property 'is_public' is of wrong type", resultDetails.is_public
      done()
  it "should automatically convert integer 1 or 0 as boolean", (done) ->
    validator = hygiene.validator().withBoolean("is_public").withBoolean("is_active")
    obj= {is_public: 1, is_active: 0}
    validator obj, (err, result, resultDetails, sanitizedObject) ->
      throw err if err
      assert.equal true, result
      assert.strictEqual(true, sanitizedObject.is_public)
      assert.strictEqual(false, sanitizedObject.is_active)
      done()
