_ = require 'underscore'

class Validator
  constructor: (options) ->
    @_rules = {}
  
  withString: (property) =>
    @_rules[property] =
      type: 'string'
    return this

  withNumber: (property) =>
    @_rules[property] =
      type: 'number'
    return this

  validate: (obj) =>
    validKeys = _.keys @_rules
    for key, value of obj
      ruleIndex = validKeys.indexOf(key)
      if ruleIndex == -1 || !@_validateRule(validKeys[ruleIndex], value)
        return false

    objKeys = _.keys obj
    for key, rule of @_rules
      if objKeys.indexOf(key) == -1
        return false
    return true
  _validateRule: (property, value) ->
    rule = @_rules[property]
    ret = typeof value == rule.type
    return ret

exports.validator = (options) ->
  return new Validator(options)
