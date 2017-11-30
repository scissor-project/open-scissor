var models = require('../../models');
var mongoose = require('mongoose');
var express = require('express');
var fs = require('fs');
var path = require('path');

exports.unauthorized = function (app, template) {
	template([
		'job'
	], {
		prefix: 'job'
	});
};

exports.httpRouter = function (app) {
};

exports.router = function (app) {
	var job = express.Router();
	var probe = express.Router();

	job.get('/', view)
	.put('/', save)
	.delete('/', remove);

	app.param('job_id', get);
	app.use('/playbook/:playbook_id/job/:job_id', job);

	//------REST------
	probe.put('/', probeSave)
		.delete('/', probeRemove);

	app.param('probe_id', get);
	app.use('/network/:network_id/probe/:probe_id', probe);
  //------REST------

};

function get (req, res, next, id) {
	//console.log("ciao");
	fs.readdir(__dirname+'/../../../streamon/config/', function (err,files) {
		var availablePlayFile = [];
		var tmp = {};
		for (var i in files){
			if(path.extname(files[i]) === ".xml"){
				tmp = {name: files[i]};
				availablePlayFile.push(tmp);
			}
		}
		models.Job.findOne({
			_id: id
		}).exec(function (err, job) {
			if (err || !job) {
				req.job ={
					_id: id,
					available_play_file: availablePlayFile
				};
				next();
			}
			else {
				job.available_play_file = availablePlayFile;
				req.job = job;
				next();
			}
		});
	});
}

function view (req, res) {
	//console.log(req.job);
	res.send(req.job);
}

function remove (req, res) {
	req.job.remove(function (err) {
		res.sendStatus(201);
	});
}

function save (req, res) {
	req.job.name = req.body.name;
	req.job.play_file = req.body.play_file;
	req.job.extra_vars = req.body.extra_vars;

	req.job.save();
	res.sendStatus(201);
}


//------REST------
function probeRemove (req, res) {
	req.job.remove(function (err) {
		res.sendStatus(200);
	});
}

function probeSave (req, res) {
	if (req.body.name === undefined || req.body.play_file === undefined){
		res.sendStatus(400);
	}
	else {
		req.job.name = req.body.name;
		req.job.play_file = req.body.play_file;

		req.job.save();
		res.sendStatus(201);
	}
}
//------REST-----
