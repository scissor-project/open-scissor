var util = require('../util'),
	auth = require('./auth'),
	playbooks = require('./playbook/playbooks'),
	profile = require('./profile'),
	identities = require('./identity/identities'),
	job = require('./job/job'),
	jobs = require('./job/jobs'),
	hosts = require('./host/hosts'),
	tasks = require('./task/tasks'),
	users = require('./user/users'),
	fs = require('fs');

exports.router = function(app) {
	var templates = require('../templates')(app);
	templates.route([
		auth,
		playbooks,
		identities,
		job,
		jobs,
		hosts,
		tasks,
		users
	]);

	templates.add('homepage');
	templates.add('abstract');
	templates.setup();

	app.get('/', layout);
	app.all('*', util.authorized);
	app.post('/createProbes', createProbes)

	// Handle HTTP reqs
	playbooks.httpRouter(app);
	identities.httpRouter(app);
	job.httpRouter(app);
	jobs.httpRouter(app);
	hosts.httpRouter(app);
	tasks.httpRouter(app);
	users.httpRouter(app);

	// only json beyond this point
	app.get('*', function(req, res, next) {
		res.format({
			json: function() {
				next();
			},
			html: function() {
				layout(req, res);
			}
		});
	});



	auth.router(app);
	playbooks.router(app);
	profile.router(app);
	identities.router(app);
	job.router(app);
	jobs.router(app);
	hosts.router(app);
	tasks.router(app);
	users.router(app);
};

function layout (req, res) {
	if (res.locals.loggedIn && res.locals.user !== undefined) {
		res.render('layout');
	} else {
		res.render('auth');
	}
}
//---- REST ----
function createProbes(req, res){
	//play_file, xml_data, force_override
	if (req.body.play_file === undefined || req.body.xml_data === undefined){
		res.sendStatus(400);
	}
	else {
		if (req.body.force_override === undefined){
			req.body.force_override = false;
		}
		req.body.play_file.replace(".xml", "");
		fs.stat(__dirname+'/../../streamon/config/'+req.body.play_file+'.xml', function(err, stats){
			if (stats != undefined){
				if(req.body.force_override){
					fs.writeFile(__dirname+'/../../streamon/config/'+req.body.play_file+'.xml', req.body.xml_data, 'base64', function(err) {
				  	if (err) throw err;
				  	console.log('The file has been saved!');
						res.sendStatus(201)
					});
				}
				else{
					console.log('The already exist!');
					res.sendStatus(412);
				}
			}
			else {
				fs.writeFile(__dirname+'/../../streamon/config/'+req.body.play_file+'.xml', req.body.xml_data, 'base64', function(err) {
					if (err) throw err;
					console.log('The file has been saved!');
					res.sendStatus(201)
				});
			}
		});
	}
}
//---- REST ----
