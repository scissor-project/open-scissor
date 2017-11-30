var async = require('async'),
fs = require('fs'),
spawn = require('child_process').spawn;

var app = require('./app');

var home = process.env.HOME + '/';
var user = process.env.USER;

exports.queue = async.queue(worker, 1);

function worker (task, callback) {
  // Task is to be model Task

  // Write values.txt file
  // Execute ansible-playbook -i hosts --private-key=~/.ssh/ansible_key edit.yml

  async.waterfall([
    function (done) {
      playbookOutputHandler.call(task, "\nStarting edit Probe.\n");

      fs.writeFile( __dirname+'/../running/status/playbook_'+task.playbook+'/task_'+task._id+'/values.txt', task.newValues.toString(), function (err) {
        if (err) throw err;
        console.log('It\'s saved!');
        var args = ['-u root', '-vvvv', '-i', 'semaphore_hosts'];

        // private key to login to server[s]
        args.push('--private-key=' + home + '.ssh/id_rsa');

        // the playbook file
        args.push('edit.yml');

        var playbookgo = spawn("ansible-playbook", args, {
          cwd: __dirname + '/../running/status/playbook_'+task.playbook+'/task_'+task._id+'/',
          env: {
            HOME: home,
            OLDPWD: home,
            PWD: __dirname + '/../running/status/playbook_'+task.playbook+'/task_'+task._id+'/',
            LOGNAME: user,
            USER: user,
            TERM: 'xterm',
            SHELL: '/bin/bash',
            PATH: process.env.PATH+':/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
            LANG: 'en_GB.UTF-8',
            PYTHONPATH: process.env.PYTHONPATH,
            PYTHONUNBUFFERED: 1
          }
        });

        playbookgo.stdout.on('data', playbookOutputHandler.bind(task));
        playbookgo.stderr.on('data', playbookOutputHandler.bind(task));

        playbookgo.on('close', function(code) {
          if (code !== 0) {
            // Failed
            console.log("NOPE");
          }
          else{
            done(null);
          }
        });
      });
    }
  ], function (err) {
    if (err) {
      console.error(err);
    } else {
      callback(err);
    }
  });
}

function playbookOutputHandler (chunk) {

  chunk = chunk.toString('utf8');

  if (!this.output) {
    this.output = "";
  }

  this.output += chunk;
  app.io.emit('playbook.output', {
    task_id: this._id,
    playbook_id: this.playbook,
    output: chunk
  });

  console.log(chunk);
}
