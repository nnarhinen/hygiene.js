Hygiene.js - sanitize your input
================================

[![Build Status](https://secure.travis-ci.org/nnarhinen/hygiene.js.png)](http://travis-ci.org/nnarhinen/hygiene.js)

Asynchronous validator
----------------------
Hygiene.js is written for NodeJS, so it's only natural for it to be asyncronous. The point of Hygiene.js validator is to validate user input objects. It's convenient when using web frameworks like express etc.

###Usage


````javascript

var hygiene = require('hygiene');

var userValidator = hygiene.validator()
	.withString('name')
	.withNumber('age');
	
userValidator({name: 'John Doe', age: 'Not a number'}, function(err, result, resultDetails) {
	assert.equal(false, result);
	assert.equal("Property 'age' is of wrong type", resultDetails.age);
});

````

Asychronous Sanitizer
---------------------
NodeJS makes it easy to use document databases that support storing JSON objects. However it doesn't remove the need to sanitize what goes to the database and in which format. Hygiene.js helps you with keeping your data - the most valuable part of your application - clean and easy to use.

###Usage

````javascript

var hygiene = require('hygiene');

var userValidator = hygiene.validator()
	.withString('name')
	.withNumber('age');
	
userValidator({name: 'John Doe', age: '33'}, function(err, result, resultDetails, sanitizedObject) {
	assert.equal(true, result);
	assert.strictEqual(33, sanitizedObject.age);
});

````

Custom validators
-----------------

So, what about custom validators? Well, just pass it to hygiene. This is why it is so handy to be asynchronous 

````javascript

var h = require('hygiene'),
    http = require('http');
var val = h.validator().with('twitter', {validator: function(property, value, messages, callback) {
  http.get('http://api.twitter.com/1/users/show.xml?screen_name=' + value, function(res) {
    if (res.statusCode == 404) {
      return callback(undefined, 'Twitter handle ' + value + ' not found');
    }
    if (res.statusCode >= 400) {
      return callback(new Error('Request failed'), null);
    }
    return callback(undefined, null);
  }).on('error', function(e) {
    return callback(e, null);
  });
}});

val({twitter: 'nnarhinen'}, function(err, result, resultDetails) {
  if (err) throw err;
  assert.equal(true, result);
});

val({twitter: 'nnarhinenshouldnotbefound'}, function(err, result, resultDetails) {
  if (err) throw err;
  assert.equal(false, result);
  assert.deepEqual({twitter: 'Twitter handle nnarhinenshouldnotbefound not found'}, result.resultDetails);
});

````


