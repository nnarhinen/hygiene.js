_ = require 'underscore'
async = require 'async'
builtInValidators = require './validators'

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

  validate: (obj, callback) =>
    errors = {}
    validators = {}
    validKeys = _.keys @_rules
    for key, value of obj
      ruleIndex = validKeys.indexOf(key)
      if ruleIndex == -1
        errors[key] = @_messages.unknown(key)
      else
        rule = @_rules[key]
        validator = rule.validator || @_getValidator(rule.type)
        validators[key] = (cb) =>
          validator(key, value, @_messages, cb)
    objKeys = _.keys obj
    for key, rule of @_rules
      if rule.required && objKeys.indexOf(key) == -1
        errors[key] = @_messages.required(key)
    async.parallel validators, (err, results) ->
      return callback(err) if err
      for pr, msg of results
        errors[pr] = msg if msg
      callback(undefined, _.keys(errors).length == 0, errors)

  _getValidator: (type) ->
    if type == 'string'
      return builtInValidators.string
    if type == 'number'
      return builtInValidators.number

exports.validator = (options) ->
  return new Validator(options)
