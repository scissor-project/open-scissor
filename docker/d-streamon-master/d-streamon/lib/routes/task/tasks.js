var models = require('../../models');
var mongoose = require('mongoose');

var task = require('./task');

var app = require('../../app');

var jobRunner = require('../../runner');

var editJobRunner = require('../../editRunner');

var async = require('async');

exports.unauthorized = function (app, template) {
	template([
		'tasks'
	], {
		prefix: 'task'
	});

	task.unauthorized(app, template);
};

exports.httpRouter = function (app) {
	task.httpRouter(app);
};

exports.router = function (app) {
	app.get('/playbook/:playbook_id/tasks', getTasks)
		.get('/playbook/:playbook_id/job/:job_id/tasks', get)
		.post('/editConfig/:task_id', edit)
		.post('/playbook/:playbook_id/job/:job_id/tasks', add)
		//.post('/playbook/:playbook_id/job/:job_id/run', runJob);
		//new rest api
		.post('/playbook/:playbook_id/job/:job_id/run', runAll)
		.post('/playbook/:playbook_id/job/:job_id/hostgroup/:hostgroup_id/run', runGroup)

		.post('/playbook/:playbook_id/job/:job_id/host/:host_id/run', runHost)
		.post('/network/:network_id/probe/:probe_id/host/:host_id/run', runHost);

	task.router(app);
};

function get (req, res) {
	models.Task.find({
		job: req.job._id
	}).populate('job').sort('-created').exec(function (err, tasks) {
		res.send(tasks);
	});
}

function getTasks (req, res) {
	models.Task.find({
		playbook: req.playbook._id
	}).populate('job').sort('-created').exec(function (err, tasks) {
		res.send(tasks);
	});
}

function add (req, res) {
	var task = new models.Task({
		job: req.job._id,
		installation: 'Queued'
	});

	task.save(function () {
		res.send(task);
	});
}

function edit(req, res) {
	req.task.newValues = req.body.newValues;
	editJobRunner.queue.push(req.task, function (err) {
		if (err) throw err;
		res.sendStatus(200);
	});
}

//function runJob (req, res) {
function runAll (req, res) {
	var hostfile = '';

	models.HostGroup.find({
		playbook: req.playbook._id
	}, function (err, hostgroups) {
		async.each(hostgroups, function (group, cb) {
			models.Host.find({
				group: group._id
			}, function (err, hosts) {
					//hostfile += "["+group.name+"]\n";
					async.each(hosts, function (hosts, cb){
						hostfile += "["+group.name+"]\n";
						hostfile += hosts.hostname;
						hostfile += "\n";

						//qui ci va il send
						var task = new models.Task({
							job: req.job._id,
							playbook: req.playbook._id,
							installation: 'Queued',
							hostlist: hostfile,
							hostname: hosts.hostname
						});

						//console.log("Inizio: "+task._id);

						task.save(function (err) {
							task.populate('job', function () {

								//console.log("nel task: "+task._id);

								app.io.emit('playbook.update', {
									task_id: task._id,
									playbook_id: req.playbook._id,
									task: task
								});

								jobRunner.queue.push(task);
							});
						});

						//res.send(201)
						hostfile = '';

						cb();
					});

				cb();
			});
		}, function () {
			console.log("tasks lanciati");
			res.send(201);

			//playbookOutputHandler.call(task, "\nSet up Ansible Hosts file with contents:\n"+hostfile+"\n");

			/*fs.writeFile(home + 'playbook_'+playbook._id+'/semaphore_hosts', hostfile, function (err) {
				done(err, task, playbook);
			});*/
		});
	});
}

function runGroup (req,res){
	console.log(req);
	console.log("runGroup");
	var hostfile = '';
	models.Host.find({group: req.hostgroup._id}).populate("group").exec(function (err, hosts) {
		async.each(hosts, function (host, cb){
			hostfile += "["+host.group.name+"]\n";
			hostfile += host.hostname;
			hostfile += "\n";
			var task = new models.Task({
				job: req.job._id,
				playbook: req.playbook._id,
				installation: 'Queued',
				hostlist: hostfile,
				hostname: host.hostname
			});
			task.save(function (err) {
				task.populate('job', function () {
					app.io.emit('playbook.update', {
						task_id: task._id,
						playbook_id: req.playbook._id,
						task: task
					});
					jobRunner.queue.push(task);
				});
			});
			hostfile = '';
			cb();
		}, function () {
			console.log("probe lanciate nel gruppo");
			res.send(201);
		});
	});
}

function runHost (req,res){
	//console.log(req);
	console.log("runHost");
	//console.log(JSON.stringify(req.group_host));

	var hostfile = '';

	hostfile += "["+req.group_host.name+"]\n";
	hostfile += req.group_host.hostname;
	hostfile += "\n";
	var task = new models.Task({
		job: req.job._id,
		playbook: req.playbook._id,
		installation: 'Queued',
		hostlist: hostfile,
		hostname: req.group_host.hostname
	});
	task.save(function (err) {
		task.populate('job', function () {
			app.io.emit('playbook.update', {
				task_id: task._id,
				playbook_id: req.playbook._id,
				task: task
			});
			jobRunner.queue.push(task);
			console.log("probe lanciata nell'host");
			res.sendStatus(200);
		});
	});
	//hostfile = '';
	//cb();


	//console.log(req.onehost._id);
	// var hostfile = '';
	//
	// models.Host.find({_id: req.singlehost._id}).populate("group").exec(function (err, host) {
	// 	hostfile += "["+host.group.name+"]\n";
	// 	hostfile += host.hostname;
	// 	hostfile += "\n";
	// 	var task = new models.Task({
	// 		job: req.job._id,
	// 		playbook: req.playbook._id,
	// 		installation: 'Queued',
	// 		hostlist: hostfile,
	// 		hostname: host.hostname
	// 	});
	// 	task.save(function (err) {
	// 		task.populate('job', function () {
	// 			app.io.emit('playbook.update', {
	// 				task_id: task._id,
	// 				playbook_id: req.playbook._id,
	// 				task: task
	// 			});
	// 			jobRunner.queue.push(task);
	// 		});
	// 	});
	// 	hostfile = '';
	// 	cb();
	// 	console.log("probe lanciata nell'host");
	// 	res.send(201);
	// });
}

exports.runHost = runHost;

//Metodo originale
/*function runJob (req, res) {
	var task = new models.Task({
		job: req.job._id,
		playbook: req.playbook._id,
		installation: 'Queued'
	});

	task.save(function (err) {
		task.populate('job', function () {
			app.io.emit('playbook.update', {
				task_id: task._id,
				playbook_id: req.playbook._id,
				task: task
			});

			jobRunner.queue.push(task);
		})
	});

	res.send(201)
}*/
