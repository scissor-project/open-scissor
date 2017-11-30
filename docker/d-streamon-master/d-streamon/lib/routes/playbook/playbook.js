var models = require('../../models');
var mongoose = require('mongoose');
var express = require('express');

exports.unauthorized = function (app, template) {
	template([
		'tasks',
		'job',
		'jobs',
		'hosts',
		'view'
	], {
		prefix: 'playbook'
	});
};

exports.httpRouter = function (app) {
};

exports.router = function (app) {
	var playbook = express.Router();
	var network = express.Router();

	playbook.get('/', view)
		.put('/', save)
		.delete('/', remove);

	app.param('playbook_id', getPlaybook);
	app.use('/playbook/:playbook_id', playbook);

	//------REST------
	network.put('/', networkSave)
		.delete('/', networkRemove);

	app.param('network_id', getPlaybook);
	app.use('/network/:network_id', network);
  //------REST------

};

function getPlaybook (req, res, next, id) {
	models.Playbook.findOne({
		_id: id
	}).select('-vault_password').exec(function (err, playbook) {
		if (err || !playbook) {
			return res.send(404);
		}

		req.playbook = playbook;
		next();
	});
}

function view (req, res) {
	res.send(req.playbook);
}

function save (req, res) {
	req.playbook.name = req.body.name;
	req.playbook.location = req.body.location;

	if (typeof req.body.vault_password == 'string' && req.body.vault_password.length > 0) {
		req.playbook.vault_password = req.body.vault_password;
	}

	if (typeof req.body.identity == 'string' && req.body.identity.length > 0) {
		try {
			req.playbook.identity = mongoose.Types.ObjectId(req.body.identity);
		} catch (e) {}
	}

	req.playbook.save();
	res.send(201);
}

function remove (req, res) {
	req.playbook.remove(function (err) {
		res.send(201);
	});
}

// ------REST-------
function networkSave (req, res) {
	if (req.body.name === undefined ){
		res.sendStatus(400);
	}
	else {
		req.playbook.name = req.body.name;

		req.playbook.save();
		res.sendStatus(201);
	}
}

function networkRemove (req, res) {
	req.playbook.remove(function (err) {
		res.sendStatus(200);
	});
}
// ------REST-------
