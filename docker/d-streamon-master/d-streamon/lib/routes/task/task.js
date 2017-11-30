var models = require('../../models');
var mongoose = require('mongoose');
var express = require('express');

var jobRunner = require('../../runner');
var hashtable = require('../../ht');

var app = require('../../app');

var spawn = require('child_process').spawn;

var fs = require('fs');

var home = process.env.HOME + '/';
var user = process.env.USER;

exports.unauthorized = function (app, template) {
	template([
		'view'
	], {
		prefix: 'task'
	});
};

exports.httpRouter = function (app) {
};

exports.router = function (app) {
	var task = express.Router();

	task.get('/', view)
		.delete('/', remove);

	app.get('/getConfig/:task_id', getConfig);

	app.param('task_id', get);
	app.use('/playbook/:playbook_id/job/:job_id/task/:task_id', task);
};

function getConfig (req, res) {
	fs.readFile(__dirname+"/../../../running/status/playbook_"+req.task.playbook+"/task_"+req.task._id+"/values.txt",'utf8',function (err, data) {
		if (err) throw err;
  	var resp = {};
		resp.data = data;
		res.send(resp);
	});
}

function get (req, res, next, id) {
	models.Task.findOne({
		_id: id
	}).exec(function (err, task) {
		if (err || !task) {
			return res.send(404);
		}

		req.task = task;
		next();
	});
}

function view (req, res) {
	res.send(req.task);
}

function remove (req, res) {

	if (req.task.installation == 'Running' || req.task.installation == 'Uninstalling...') {
		return res.send(400, 'Probe is Running or Uninstalling.');
	}
	else if (req.task.installation == 'Failed' || req.task.status == 'Unreachable' || req.task.installation == 'Queued'){
		req.task.populate('job',function (err,task) {
			if (err) throw err;
			if(task.job.tmp){
				fs.unlink(__dirname+'/../../../streamon/config/tmp/tmp_'+req.job._id+'.xml', function(err) {
	  			if (err) throw err;
	  			console.log('file successfully deleted');
				});
			}
		});
		req.task.remove(function (err) {
			res.sendStatus(201);
		});
	}
	else {
		jobRunner.queue.pause();

		//mettere il task in uninstalling
		//update Mongo
		models.Task.update({
			_id: req.task._id
		}, {
			$set: {
				status: 'Uninstalling...'
			}
		}, function (err) {
				if (err){
					return console.log(err);
				}
				else{
					//Update client
					app.io.emit('playbook.update', {
						task_id: req.task._id,
						playbook_id: req.task.playbook,
						task_status: 'Uninstalling...'
					});
				}
			}
		);

		var semaphore_hosts = '../running/status/playbook_' + req.task.playbook + '/task_' + req.task._id + '/semaphore_hosts';

		//rimuovere la sonda nel host
		var playbook_uninstall = spawn("ansible-playbook", ['-u root','-v', '-i', semaphore_hosts, '--private-key='+ home + '.ssh/id_rsa', '../sys/uninstall.yml'], {
			cwd: __dirname + '/../../',
				env: {
					HOME: home,
					OLDPWD: home,
					PWD: '/../../',
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

		playbook_uninstall.stdout.on('data', playbookOutputHandler.bind(req.task));
		playbook_uninstall.stderr.on('data', playbookOutputHandler.bind(req.task));

		playbook_uninstall.on('close', function(code) {

			//rimuovere il monitor nell'hash table
			if (hashtable.remove(req.task._id.toString())) {
				console.log('job removed from hashtable');
			}
			else {
				console.log('job NOT removed from hashtable');
			}

			//console.log(JSON.stringify(jobRunner));
			//console.log(jobRunner.queue._tasks.length);

			//cancello il file tmp se serve
			req.task.populate('job',function (err,task) {
				if (err) throw err;
				if(task.job.tmp){
					fs.unlink(__dirname+'/../../../streamon/config/tmp/tmp_'+req.job._id+'.xml', function(err) {
		  			if (err) throw err;
		  			console.log('file successfully deleted');
					});
				}
			});

			//rimuovere il task da mongo e dal lato client
			for (var i = 0; i < jobRunner.queue._tasks.length; i++) {
				if (jobRunner.queue._tasks[i].data._id.toString() == req.task._id.toString()) {
					// This is our task
					jobRunner.queue._tasks.splice(i, 1);
					break;
				}
			}

			//rimuovere la directory task
			var opt = spawn('rm', ['-rf', 'playbook_'+req.task.playbook+'/task_'+req.task._id], {
				cwd: __dirname + '/../../../running/status'
			});

			opt.on ('close', function (err) {
				if (err !== 0){
					//Failed
					console.log("Error to remove task directory.");
				}
				else {
					//se la directory playbook è vuota la rimuovo
					fs.readdir( __dirname + '/../../../running/status/playbook_' + req.task.playbook, function(err, files){

						if (files !== undefined){
							console.log("undefined NO: " + files.length);
							if (files.length === 0){
								var opt2 = spawn('rm', ['-rf', 'playbook_'+req.task.playbook], {
									cwd: __dirname + '/../../../running/status'
								});
							}
						}
					});
				}
			});

			jobRunner.queue.resume();


			req.task.remove(function (err) {
				res.sendStatus(201);
			});
		});
	}
}

function playbookOutputHandler (chunk) {

	chunk = chunk.toString('utf8');

	/*if (!this.output) {
		this.output = "";
	}

	this.output += chunk;
	app.io.emit('playbook.output', {
		task_id: this._id,
		playbook_id: this.playbook,
		output: chunk
	});*/

	console.log(chunk);
}
