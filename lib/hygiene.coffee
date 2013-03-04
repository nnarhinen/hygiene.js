_ = require 'underscore'
async = require 'async'
builtInValidators = require './validators'
builtInSanitizers = require './sanitizers'

createValidator = (options, value, messages, validator) ->
  return (cb) ->
    validator(options, value, messages, cb)
createSanitizer = (value, options, sanitizer) ->
  return (cb) ->
    sanitizer(value, options, cb)

class Validator
  _defaultOptions:
    messages:
      required: (property) ->
        "Property '#{property}' is missing"
      type:     (property) ->
        "Property '#{property}' is of wrong type"
      unknown:   (property) ->
        "Property '#{property}' is unknown"

  constructor: (options) ->
    @_rules = {}
    @_messages = options?.messages || @_defaultOptions.messages

  with: (property, options) =>
    @_rules[property] = _.extend({required: true}, options)
    return this

  withString: (property, options) =>
    @with property, _.extend({type: 'string'}, options)

  withNumber: (property, options) =>
    @with property, _.extend({type: 'number'}, options)

  withStringList: (property, options) =>
    @with property, _.extend({type: 'stringList'}, options)

  withStringArray: (property, options) =>
    @with property, _.extend({type: 'stringArray'}, options)

  withNumberArray: (property, options) =>
    @with property, _.extend({type: 'numberArray'}, options)

  withBoolean: (property, options) =>
    @with property, _.extend({type: 'boolean'}, options)

  withObject: (property, innerValidator, options) =>
    @with property, _.extend({type: 'object', innerValidator: innerValidator}, options)

  withObjectArray: (property, innerValidator, options) =>
    @with property, _.extend({type: 'objectArray', innerValidator: innerValidator}, options)

  withDateTime: (property, options) =>
    @with property, _.extend({type: 'datetime'}, options)

  validate: (obj, callback) =>
    errors = {}
    validators = {}
    sanitizers = {}
    validKeys = _.keys @_rules
    objKeys = _.keys obj
    for key, rule of @_rules
      if rule.required && (objKeys.indexOf(key) == -1 || obj[key] == null)
        errors[key] = @_messages.required(key)
      else if objKeys.indexOf(key) == -1 && rule.hasOwnProperty('defaultValue')
        obj[key] = rule.defaultValue
    for key, value of obj
      continue if errors[key] # already marked as failed
      ruleIndex = validKeys.indexOf(key)
      if ruleIndex == -1
        errors[key] = @_messages.unknown(key)
      else
        rule = @_rules[key]
        validator = rule.validator || @_getValidator(rule.type)
        validators[key] = createValidator(_.extend({property: key}, rule), value, @_messages, validator)
        unless rule.ignore
          if rule.sanitizer
            sanitizer = rule.sanitizer
          else if rule.type == "object"
            sanitizer = @_buildValidatorProxyForObject(rule.innerValidator)
          else if rule.type == "objectArray"
            sanitizer = @_buildValidatorProxyForObjectArray(rule.innerValidator)
          else
            sanitizer = @_getSanitizer rule.type
          sanitizers[key] = createSanitizer(value, rule, sanitizer)
    async.parallel validators, (err, results) ->
      return callback(err) if err
      for pr, msg of results
        errors[pr] = msg if msg
      if !_.isEmpty errors
        return callback(null, false, errors)
      async.parallel sanitizers, (err, sanitizedObject) ->
        return callback(err) if err
        callback(undefined, _.keys(errors).length == 0, errors, sanitizedObject)

  _getValidator: (type) ->
    if type == 'string'
      return builtInValidators.string
    if type == 'number'
      return builtInValidators.number
    if type == 'stringList'
      return builtInValidators.stringList
    if type == 'boolean'
      return builtInValidators.boolean
    if type == 'stringArray'
      return builtInValidators.stringArray
    if type == 'numberArray'
      return builtInValidators.numberArray
    if type == 'object'
      return builtInValidators.object
    if type == 'objectArray'
      return builtInValidators.objectArray
    if type == 'datetime'
      return builtInValidators.dateTime

  _getSanitizer: (type) ->
    if type == 'number'
      return builtInSanitizers.numberSanitizer
    if type == 'boolean'
      return builtInSanitizers.booleanSanitizer
    if type == 'stringList'
      return builtInSanitizers.stringListSanitizer
    if type == 'stringArray'
      return builtInSanitizers.stringArraySanitizer
    if type == 'numberArray'
      return builtInSanitizers.numberArraySanitizer
    if type == 'datetime'
      return builtInSanitizers.dateTimeSanitizer
    return builtInSanitizers.toStringSanitizer

  _buildValidatorProxyForObject: (validator) ->
    (value, options, cb) ->
      validator value, (err, result, omit, sanitizedObject) ->
        return cb(err) if err
        if result
          return cb(null, sanitizedObject)
        cb()

  _buildValidatorProxyForObjectArray: (validator) ->
    (value, options, cb) ->
      async.map(value, (val, callback) ->
        validator val, (err, result, omit, sanitizedObject) ->
          return callback(err) if err
          if result
            return callback null, sanitizedObject
          callback()
      , cb)



exports.validator = (options) ->
  return new Validator(options)
