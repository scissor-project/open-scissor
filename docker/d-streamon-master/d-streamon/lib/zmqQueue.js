var models = require('./models');
var async = require('async'),
fs = require('fs'),
spawn = require('child_process').spawn;

var app = require('./app');

var home = process.env.HOME + '/';
var user = process.env.USER;

exports.queue = async.queue(worker, 1);

function worker (msg, callback) {
  //Queue for zmq alert

  async.waterfall([
    function (done) {
      models.Task.find({_id: msg[0]}, function (err, resp) {
        if (err){
          console.log("[zmqQueue] Error on find task: " + err);
        }
        else {
          var chunk = "["+msg[1]+"]"+msg[2]+"\n";
          if (resp[0] !== undefined){
            chunk = chunk.toString('utf8');

            if (resp[0].outputZmq === undefined) {
              resp[0].outputZmq = "";
            }

            resp[0].outputZmq += chunk;

            resp[0].save(function (err, task) {
              if (err){
                console.log("errore 44",err);
              }
              else{

                app.io.emit('zmqClient.output', {
                  task_id: task._id,
                  playbook_id: task.playbook,
                  outputZmq: chunk
                });

                done(null);
              }
            });
          }
        }
      });
    }
  ], function (err) {
    if (err) {
      console.error("Error on zmqQueue",err);
    } else {
      callback(err);
    }
  });
}
