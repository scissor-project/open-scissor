var models = require('./models');
var app = require('./app');
var zmqQueue = require('./zmqQueue');
var zmq = require('zmq'),
    xpub = zmq.socket('xpub'),
    xsub = zmq.socket('xsub'),
    xpendpoint = 'tcp://*:5570',
    xsendpoint = 'tcp://*:5560',
    socket = zmq.socket( 'sub' ),
    endpoint = 'tcp://localhost:5570';

// sub sends to pub
//xsub.on('message', xpub.send.bind( xpub ));
//xsub.on('message', function() { xpub.send(Array.prototype.slice.call(arguments)); });
//xsub.on('message', function() { xpub.send.call( xpub, arguments ); });
/*xsub.on('message', function(){
  console.log('xsub:', arguments)
  //xpub.send(arguments[0]+arguments[1]);
  xpub.send.call( xpub, arguments )
})*/

xsub.on('message', function() {
  //console.log(Array.prototype.slice.call(arguments).toString());
  //console.log(arguments[0].toString());
  var msg = arguments;

  for (var i = 0; i < arguments.length; i++){
    msg[i] = arguments[i].toString();
   //console.log("message = "+msg[i]);
  }
  zmqQueue.queue.push(msg, function (err) {
      //console.log("salvato nel mio");
      var yourMsg = "["+msg[1]+"]"+msg[2];
      xpub.send(yourMsg);
  });
});

// pub sends to sub
xpub.on('message', xsub.send.bind( xsub ));
// sit on some endpoints
xsub.bindSync( xsendpoint );
xpub.bindSync( xpendpoint );

socket.on('message', function( msg ){
    //msg = msg.toString().split(',');
    //console.log(msg.length);
    //msg2 = "("+msg[0]+") "+"["+msg[1]+"]"+msg[2];
    //console.log(msg.toString());
});

socket.connect( endpoint );

// subscribe to all of the messages
socket.setsockopt( zmq.ZMQ_SUBSCRIBE, new Buffer('') );

console.log("Zmq Proxy ready");

// function zmqClientOutputHandler (task,chunk) {
//
// 	chunk = chunk.toString('utf8');
//
//   console.log("chunk: ", chunk);
//
// 	if (task.outputZmq === undefined) {
// 		task.outputZmq = "";
// 	}
//
//   //console.log("prima!!!!!!!!!!!", task.outputZmq);
//
// 	task.outputZmq += chunk;
//
//   task.save(function (err,task) {
//       console.log("dio!!!!", task.outputZmq);
//   });
//
// 	// app.io.emit('zmqClient.output', {
// 	// 	task_id: task._id,
// 	// 	playbook_id: task.playbook,
// 	// 	outputZmq: chunk
// 	// });
//
// 	//console.log(chunk);
// }
