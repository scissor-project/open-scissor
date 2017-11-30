var models = require('../../models');
var mongoose = require('mongoose');
var job = require('./job');
var fs = require('fs');
var tasks = require('../task/tasks');

exports.unauthorized = function (app, template) {
	template([
		'jobs'
	], {
		prefix: 'job'
	});
	job.unauthorized(app, template);
};

exports.httpRouter = function (app) {
	job.httpRouter(app);
};

exports.router = function (app) {
	app.get('/playbook/:playbook_id/jobs', get)
	.post('/playbook/:playbook_id/jobs', add)
	.post('/getXml', getXml)
	.post('/saveXml', saveXml)
	.post('/saveTmpXml', saveTmpXml);

	//------REST------
	app.get('/network/:network_id/probes', getProbes)
	.post('/network/:network_id/createProbe', createProbe)
	.post('/network/:network_id/deployProbe', deployProbe)
	.post('/network/:network_id/createDeployProbe', createDeployProbe);
	//------REST------

	job.router(app);
};

function get (req, res) {
	models.Host.find({
		playbook: req.playbook._id
	}).sort('-name').exec(function (err, hosts) {
		models.HostGroup.find({
			playbook: req.playbook._id
		}).sort('-name').exec(function (err, HostGroups) {
			models.Job.find({
				playbook: req.playbook._id
			}).sort('-created').exec(function (err, jobs) {

				var tmp = {};

				tmp.hosts = hosts;
				tmp.HostGroups = HostGroups;
				tmp.jobs = jobs;

				res.send(tmp);
			});
		});
	});
}

function add (req, res) {
	var job = new models.Job({
		playbook: req.playbook._id,
		name: req.body.name,
		play_file: req.body.play_file,
		extra_vars: req.body.extra_vars,
		use_vault: req.body.use_vault
	});

	job.save(function () {
		res.send(job);
	});
}

function getXml (req,res){
	fs.readFile(__dirname+'/../../../streamon/config/'+req.body.play_file, 'utf8', function (err, data) {
  	if (err) throw err;
		res.send(data);
	});
}

function saveXml (req,res){
	fs.writeFile(__dirname+'/../../../streamon/config/'+req.body.name+'.xml', req.body.body, 'utf8', function(err) {
		if (err) throw err;
		console.log('The file has been saved!');

		models.Job.find({play_file: req.body.name+'.xml', playbook: req.body.playbook}, function (err, jobs) {
			if (err) throw err;

			if (jobs.length == 0){
				job = new models.Job({
					playbook: req.body.playbook,
					name: req.body.name,
					play_file: req.body.name+'.xml',
					// extra_vars: req.body.extra_vars,
					// use_vault: req.body.use_vault
				});
			}
			else{
				job = jobs[0];
				job.playbook = req.body.playbook
				job.name = req.body.name;
			}
			job.save(function () {
				res.send(job);
			});
		})
	});
}

function saveTmpXml (req,res){

	job = new models.Job({
		name: req.body.name,
		playbook: req.body.playbook,
		tmp: true
		//name: req.body.name,
		//play_file: req.body.name+'.xml',
		// extra_vars: req.body.extra_vars,
		// use_vault: req.body.use_vault
	});

	job.save(function (err,newJob) {
		if (err) throw err;
		//newJob.name      = req.body.name+"_"+newJob._id;
		newJob.play_file = req.body.name+"_"+newJob._id+".xml";
		newJob.save(function (err,lastJob) {
			if (err) throw err;

			fs.writeFile(__dirname+'/../../../streamon/config/tmp/'+lastJob.play_file, req.body.body, 'utf8', function(err) {
				if (err) throw err;
				console.log('The tmp file has been saved!');
				res.send(lastJob);
			});

		})
	})
}

//------REST------
function getProbes (req, res) {
	models.Job.find({
		playbook: req.playbook._id
	}).sort('-created').exec(function (err, jobs) {
		res.json(jobs);
	});
}

function createProbe (req, res) {
	if (req.body.name === undefined || req.body.play_file === undefined || req.body.xml_data === undefined){
		res.sendStatus(400);
	}
	else {
		if (req.body.force_override === undefined){
			req.body.force_override = false;
		}
		req.body.play_file.replace(".xml", "");
		fs.stat(__dirname+'/../../../streamon/config/'+req.body.play_file+'.xml', function(err, stats){
			if(stats != undefined){
				if(req.body.force_override){
					fs.writeFile(__dirname+'/../../../streamon/config/'+req.body.play_file+'.xml', req.body.xml_data, 'base64', function(err) {
						if (err) throw err;
						console.log('The file has been saved!');
						job = new models.Job({
							playbook: req.playbook._id,
							name: req.body.name,
							play_file: req.body.play_file+'.xml',
							//extra_vars: req.body.extra_vars,
							//use_vault: req.body.use_vault
						});
						job.save(function () {
							res.sendStatus(201).json(job);
						});
					});
				}
				else{
					console.log('The already exist!');
					res.sendStatus(412);
				}
			}
			else{
				fs.writeFile(__dirname+'/../../../streamon/config/'+req.body.play_file+'.xml', req.body.xml_data, 'base64', function(err) {
					if (err) throw err;
					console.log('The file has been saved!');
					job = new models.Job({
						playbook: req.playbook._id,
						name: req.body.name,
						play_file: req.body.play_file+'.xml',
						//extra_vars: req.body.extra_vars,
						//use_vault: req.body.use_vault
					});
					job.save(function () {
						res.sendStatus(201).json(job);
					});
				});
			}
		});
	}
}

function deployProbe (req, res){
	if (req.body.id_probe === undefined || req.body.id_host === undefined){
		res.sendStatus(400);
	}
	else{
		models.Job.find({_id: req.body.id_probe}, function (err,job) {
			if (err) {
				throw err;
			}
			else if (job.length == 0) {
				res.sendStatus(404);
			}
			else{
				models.Host.find({_id: req.body.id_host}, function (err, host) {
					if (err) {
						throw err;
					}
					else if (host.length == 0) {
						res.sendStatus(404);
					}
					else {
						req.group_host = {};
						req.job = {};
						req.group_host.name = host[0].name;
						req.group_host.hostname = host[0].hostname;
						req.job._id = job[0]._id;
						req.job.tmp = job[0].tmp;

						tasks.runHost(req,res);
					}
				})
			}
		});
	}
}

function createDeployProbe (req, res) {
	if (req.body.name === undefined || req.body.play_file === undefined || req.body.xml_data === undefined || req.body.host_id === undefined){
		res.sendStatus(400);
	}
	else {
		if (req.body.force_override === undefined){
			req.body.force_override = false;
		}
		req.body.play_file.replace(".xml", "");
		fs.stat(__dirname+'/../../../streamon/config/'+req.body.play_file+'.xml', function(err, stats){
			if(stats != undefined){
				if(req.body.force_override){
					fs.writeFile(__dirname+'/../../../streamon/config/'+req.body.play_file+'.xml', req.body.xml_data, 'base64', function(err) {
				  	if (err) throw err;
				  	console.log('The file has been saved!');
						job = new models.Job({
							playbook: req.playbook._id,
							name: req.body.name,
							play_file: req.body.play_file+'.xml',
							//extra_vars: req.body.extra_vars,
							//use_vault: req.body.use_vault
						});
						job.save(function () {
							console.log("Run now!");
							models.Host.find({_id: req.body.host_id}, function (err, host) {
								if (err) {
									throw err;
								}
								else if (host.length == 0) {
									res.sendStatus(404);
								}
								else {
									req.group_host = {};
									req.job = {};
									req.group_host.name = host[0].name;
									req.group_host.hostname = host[0].hostname;
									req.job._id = job._id;
									req.job.tmp = job.tmp;
									tasks.runHost(req,res);
								}
							})
						});
					});
				}
				else{
					console.log('The already exist!');
					res.sendStatus(412);
				}
			}
			else{
				fs.writeFile(__dirname+'/../../../streamon/config/'+req.body.play_file+'.xml', req.body.xml_data, 'base64', function(err) {
					if (err) throw err;
					console.log('The file has been saved!');
					job = new models.Job({
						playbook: req.playbook._id,
						name: req.body.name,
						play_file: req.body.play_file+'.xml',
						//extra_vars: req.body.extra_vars,
						//use_vault: req.body.use_vault
					});
					job.save(function () {
						console.log("Run now!");
						models.Host.find({_id: req.body.host_id}, function (err, host) {
							if (err) {
								throw err;
							}
							else if (host.length == 0) {
								res.sendStatus(404);
							}
							else {
								req.group_host = {};
								req.job = {};
								req.group_host.name = host[0].name;
								req.group_host.hostname = host[0].hostname;
								req.job._id = job._id;
								req.job.tmp = job.tmp;
								tasks.runHost(req,res);
							}
						})
					});
				});
			}
		});
	}
}
//------REST------
