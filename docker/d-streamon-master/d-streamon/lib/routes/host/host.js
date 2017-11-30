var models = require('../../models');
var mongoose = require('mongoose');
var express = require('express');
var spawn = require('child_process').spawn;

var home = process.env.HOME + '/';

var async = require('async');

exports.unauthorized = function (app, template) {
	template([
		'view'
	], {
		prefix: 'job'
	});
};

exports.httpRouter = function (app) {
};

exports.router = function (app) {
	app.param('hostgroup_id', getHostGroup);
	app.param('host_id', getHost);

	var job = express.Router();

	job.get('/', viewHostGroup)
	.delete('/', removeHostGroup)

	.get('/hosts', getHosts)
	.post('/hosts', addHost)
	.post('/createHost', createHost);

	app.use('/playbook/:playbook_id/hostgroup/:hostgroup_id', job);
	app.use('/network/:network_id/hostgroup/:hostgroup_id', job);
	app.use('/network/:network_id/', job);

	var host = express.Router();
	host.get('/', viewHost)
	.delete('/', removeHost);

	app.use('/playbook/:playbook_id/hostgroup/:hostgroup_id/host/:host_id', host);

};

/*
* hostgroup -> hosts
*/

function getHosts (req, res) {
	models.Host.find({
		group: req.hostgroup._id
	}).sort('-created').exec(function (err, hosts) {
		res.send(hosts);
	});
}

function addHost (req, res) {
	var host = new models.Host({
		group: req.hostgroup._id,
		playbook: req.playbook._id,
		name: req.body.name,
		hostname: req.body.hostname,
		//vars: req.body.vars,
		vars: null,
		status: "Sending..."
	});

	host.save(function (err,newHost) {
		if (req.body.vars == undefined){
			req.body.vars = "";
		}
		//console.log(home+'.ssh/id_rsa.pub');
		var sshcopyid = spawn('sshpass', [ '-p',req.body.vars.toString(),'ssh-copy-id','-i',home+'.ssh/id_rsa.pub','root@'+req.body.hostname], {
			cwd: __dirname
		});

		sshcopyid.on('close', function(code) {

			//console.log(code);

			if (code !== 0) {
				// failed
				console.log("NO copy id!");
				newHost.status = "Failed!";
				newHost.save(function(err,lastHost){
					res.send(lastHost);
				});
			}
			else {
				newHost.status = "Ok!";
				console.log('ssh-copy-id ok on host: ' + req.body.hostname);
				newHost.save(function(err,lastHost){
					res.send(lastHost);
				});
			}
		});
	});
}

function createHost (req, res) {
	console.log(req);

	if (req.hostgroup){

		if (req.body.name == undefined || req.body.hostname == undefined || req.body.vars == undefined){
			res.sendStatus(400);
		}
		else {
			var host = new models.Host({
				group: req.hostgroup._id,
				playbook: req.playbook._id,
				name: req.body.name,
				hostname: req.body.hostname,
				vars: null,
				status: "Sending..."
			});
			host.save(function (err,newHost) {
				if (req.body.vars == undefined){
					req.body.vars = "";
				}
				var sshcopyid = spawn('sshpass', [ '-p',req.body.vars.toString(),'ssh-copy-id','-i',home+'.ssh/id_rsa.pub','root@'+req.body.hostname], {
					cwd: __dirname
				});
				sshcopyid.on('close', function(code) {
					if (code !== 0) {
						console.log("NO copy id!");
						newHost.status = "Failed!";
						newHost.save(function(err,lastHost){
							res.json(lastHost);
						});
					}
					else {
						newHost.status = "Ok!";
						console.log('ssh-copy-id ok on host: ' + req.body.hostname);
						newHost.save(function(err,lastHost){
							res.json(lastHost);
						});
					}
				});
			});
		}
	}
	else {
		if (req.body.name == undefined || req.body.hostname == undefined || req.body.vars == undefined){
			res.sendStatus(400);
		}
		else {
			models.HostGroup.find({playbook: req.playbook._id,name: "default"}, function (err, group) {
				console.log(JSON.stringify(group));
				if (req.body.name == undefined || req.body.hostname == undefined || req.body.vars == undefined){
					res.sendStatus(400);
				}
				else {
					var host = new models.Host({
						group: group[0]._id,
						playbook: req.playbook._id,
						name: req.body.name,
						hostname: req.body.hostname,
						vars: null,
						status: "Sending..."
					});
					host.save(function (err,newHost) {
						if (req.body.vars == undefined){
							req.body.vars = "";
						}
						var sshcopyid = spawn('sshpass', [ '-p',req.body.vars.toString(),'ssh-copy-id','-i',home+'.ssh/id_rsa.pub','root@'+req.body.hostname], {
							cwd: __dirname
						});
						sshcopyid.on('close', function(code) {
							if (code !== 0) {
								console.log("NO copy id!");
								newHost.status = "Failed!";
								newHost.save(function(err,lastHost){
									res.json(lastHost);
								});
							}
							else {
								newHost.status = "Ok!";
								console.log('ssh-copy-id ok on host: ' + req.body.hostname);
								newHost.save(function(err,lastHost){
									res.json(lastHost);
								});
							}
						});
					});
				}
			});
		}
	}

	// var host = new models.Host({
	// 	group: req.hostgroup._id,
	// 	playbook: req.playbook._id,
	// 	name: req.body.name,
	// 	hostname: req.body.hostname,
	// 	vars: null,
	// 	status: "Sending..."
	// });
	// host.save(function (err,newHost) {
	// 	if (req.body.vars == undefined){
	// 		req.body.vars = "";
	// 	}
	// 	var sshcopyid = spawn('sshpass', [ '-p',req.body.vars.toString(),'ssh-copy-id','-i',home+'.ssh/id_rsa.pub','root@'+req.body.hostname], {
	// 		cwd: __dirname
	// 	});
	// 	sshcopyid.on('close', function(code) {
	// 		if (code !== 0) {
	// 			console.log("NO copy id!");
	// 			newHost.status = "Failed!";
	// 			newHost.save(function(err,lastHost){
	// 				res.send(lastHost);
	// 			});
	// 		}
	// 		else {
	// 			newHost.status = "Ok!";
	// 			console.log('ssh-copy-id ok on host: ' + req.body.hostname);
	// 			newHost.save(function(err,lastHost){
	// 				res.send(lastHost);
	// 			});
	// 		}
	// 	});
	// });
}

/*
* hostgroup (singular)
*/

function getHostGroup (req, res, next, id) {
	models.HostGroup.findOne({
		_id: id
	}).exec(function (err, hostgroup) {
		if (err || !hostgroup) {
			return res.send(404);
		}

		req.hostgroup = hostgroup;
		next();
	});
}

function viewHostGroup (req, res) {
	res.send(req.hostgroup);
}

function removeHostGroup (req, res) {
	//console.log(JSON.stringify(req.hostgroup));

	models.Host.find({
		group: req.hostgroup._id
	}).exec(function (err, hosts) {
		async.each(hosts, function (host, cb){
			host.remove();
			cb();
		}, function () {
			console.log("host nel gruppo cancellati");
			req.hostgroup.remove(function (err) {
				res.send(201);
			});
		});
	});
}

/*
* hostgroup -> host (singular)
*/

function getHost (req, res, next, id) {
	models.Host.findOne({
		_id: id
	}).exec(function (err, host) {
		//console.log(host);
		if (err || !host) {
			return res.send(404);
		}

		req.group_host = host;
		next();
	});
}

function viewHost (req, res) {
	res.send(req.group_host);
}

function removeHost (req, res) {
	//console.log(req.group_host);
	req.group_host.remove(function (err) {
		res.send(201);
	});
}
