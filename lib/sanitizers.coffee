exports.toStringSanitizer = (value, cb) ->
  cb(undefined, cb.toString())

exports.numberSanitizer = (value, cb) ->
  cb(undefined, Number(value))
