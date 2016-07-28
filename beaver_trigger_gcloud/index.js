exports.helloWorld = function helloWorld (context, data) {
  console.log('My Cloud Function: ' + data.message);
  context.success();
};
