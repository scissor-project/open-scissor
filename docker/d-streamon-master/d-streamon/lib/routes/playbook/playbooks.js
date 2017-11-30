var models = require('../../models');
var mongoose = require('mongoose');

var playbook = require('./playbook');

exports.unauthorized = function (app, template) {
	template([
		'add',
		'list'
	], {
		prefix: 'playbook'
	});

	playbook.unauthorized(app, template);
};

exports.httpRouter = function (app) {
	playbook.httpRouter(app);
};

exports.router = function (app) {
	app.get('/playbooks', getPlaybooks)
		.post('/playbooks', addPlaybook);

	//------REST------
  app.get('/networks', getNetworks)
	  .post('/networks', addNetwork);
  //------REST------

	playbook.router(app);
};

function getPlaybooks (req, res) {
	models.Playbook.find({
	}).sort('-created').select('-vault_password').exec(function (err, playbooks) {
		res.send(playbooks);
	});
}

function addPlaybook (req, res) {
	//console.log(req);
	var playbook = new models.Playbook({
		name: req.body.name,
		location: req.body.location,
		vault_password: req.body.vault_password
	});

	if (typeof req.body.identity == 'string' && req.body.identity.length > 0) {
		try {
			playbook.identity = mongoose.Types.ObjectId(req.body.identity);
		} catch (e) {}
	}

	playbook.save(function () {
		// console.log("wwwww");
		// console.log(JSON.stringify(playbook));
		var default_net = new models.HostGroup({
			name: "default",
			playbook: playbook._id
		});
		default_net.save(function () {
			res.send(playbook);
		});
	});
}


//------REST------
function getNetworks (req, res) {
	models.Playbook.find({
	}).sort('-created').select('-vault_password').exec(function (err, playbooks) {
		res.json(playbooks);
	});
}

function addNetwork (req, res) {
	if (req.body.name == undefined ){
		res.send(400);
	}
	else {
		var playbook = new models.Playbook({
			name: req.body.name
		});

		playbook.save(function () {
			res.json(playbook);
		});
	}
}
//------REST------
