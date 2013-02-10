require('coffee-script');
var Q       = require('q'),
    hygiene = require('./hygiene');

exports.validator = function(opts) {
  var validator = hygiene.validator(opts),
    ret = function(obj, cb) {
      var defer = Q.defer();
      validator.validate(obj, function(err, valid, validationErrors, sanitizedObject) {
        if (cb) {
          if (err) cb(err);
          else cb(null, valid, validationErrors, sanitizedObject);
        }
        if (err) return defer.reject(err);
        defer.resolve([valid, validationErrors, sanitizedObject]);
      });
      return defer.promise;
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
  ret.withBoolean = function(property, opts) {
    validator.withBoolean(property, opts);
    return ret;
  }
  ret.withStringArray = function(property, opts) {
    validator.withStringArray(property, opts);
    return ret;
  }
  ret.withNumberArray = function(property, opts) {
    validator.withNumberArray(property, opts);
    return ret;
  }
  ret.withObject = function(property, innerValidator, opts) {
    validator.withObject(property, innerValidator, opts);
    return ret;
  }
  ret.withObjectArray = function(property, innerValidator, opts) {
    validator.withObjectArray(property, innerValidator, opts);
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
