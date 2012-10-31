require('coffee-script');

var hygiene = require('./hygiene')
exports.validator = function(opts) {
  var validator = hygiene.validator(opts),
    ret = function(obj, cb) {
      return validator.validate(obj, cb);
    };
  ret.withString = function(property, opts) {
    validator.withString(property, opts);
    return ret;
  }
  ret.withNumber = function(property, opts) {
    validator.withNumber(property, opts);
    return ret;
  }
  ret.withStringList = function(property, opts) {
    validator.withStringList(property, opts);
    return ret;
  }
  ret.with = function(property, opts) {
    validator.with(property, opts);
    return ret;
  };
  ret.validate = function(obj, cb) {
    return validator.validate(obj, cb); //Preserve BC
  }
  return ret;
};
