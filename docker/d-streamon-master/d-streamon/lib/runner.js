var async = require('async'),
fs = require('fs'),
spawn = require('child_process').spawn;

var config = require('./config'),
models = require('./models'),
app = require('./app');

var home = process.env.HOME + '/';
var user = process.env.USER;

var CronJob = require('cron').CronJob;

var hashtable = require('./ht');

exports.queue = async.queue(worker, 1);

function worker (task, callback) {
	// Task is to be model Task

	// Download the git project
	// Set up hosts file
	// Set up vault pwd file
	// Set up private key
	// Compile streamon
	// Execute ansible-playbook -i hosts --ask-vault-pass --private-key=~/.ssh/ansible_key task.yml
	// Create check monitoring
	// Start the zmq socket

	async.waterfall([
		function (done) {

			task.populate('job', function (err) {
				done(err, task);
			});
		},
		function (task, done) {
			models.Playbook.findOne({ _id: task.playbook }, function (err, playbook) {
				done(err, task, playbook);
			});
		},
		function (task, playbook, done) {
			// mark task as running and send an update via socketio
			task.installation = 'Running';
			task.status = 'Unreachable';

			//console.log("nel runner: "+task._id);

			app.io.emit('playbook.update', {
				task_id: task._id,
				playbook_id: playbook._id,
				task: task
			});

			models.Task.update({
				_id: task._id
			}, {
				$set: {
					installation: 'Running',
					status: 'Unreachable'
				}
			}, function (err) {
				done(err, task, playbook);
			});
		},
		function (task, playbook, done) {
			playbook.populate('identity', function (err) {
				done(err, task, playbook);
			});
		},
		//installHostKeys,
		//pullGit,
		setupFolders,
		setupHosts,
		setupVault,
		compileLib,
		playTheBook,
		setupCheckStatus,
		checkStatus
	], function (err) {
		if (err) {
			console.error(err);
			task.installation = 'Failed';
		} else {
			task.installation = 'Completed';
		}

		var rmrf = spawn('rm', ['-rf', __dirname + '/../running/tmp/playbook_'+task.playbook]);
		rmrf.on('close', function () {
			app.io.emit('playbook.update', {
				task_id: task._id,
				playbook_id: task.playbook,
				task: task
			});
			task.save();

			callback(err);
		});
	});
}

// function installHostKeys (task, playbook, done) {
// 	// Install the private key
// 	playbookOutputHandler.call(task, "Updating SSH Keys\n");
//
// 	var location = home + '.ssh/id_rsa';
// 	fs.mkdir( home + '.ssh', 448, function() {
// 		async.parallel([
// 			function (done) {
// 				fs.writeFile(location, playbook.identity.private_key, {
// 					mode: 384 // base 8 = 0600
// 				}, done);
// 			},
// 			function (done) {
// 				fs.writeFile(location+'.pub', playbook.identity.public_key, {
// 					mode: 420 // base 8 = 0644
// 				}, done);
// 			},
// 			function (done) {
// 				var config = "Host *\n\
// 				StrictHostKeyChecking no\n\
// 				CheckHostIp no\n\
// 				PasswordAuthentication no\n\
// 				PreferredAuthentications publickey\n";
//
// 				fs.writeFile(home + '.ssh/config', config, {
// 					mode: 420 // 0644
// 				}, done);
// 			}
// 		], function (err) {
// 			playbookOutputHandler.call(task, "SSH Keys Updated.\n");
// 			done(err, task, playbook);
// 		});
// 	});
// }

// function pullGit (task, playbook, done) {
// 	// Pull from git
// 	playbookOutputHandler.call(task, "\nDownloading Playbook.\n");
//
// 	var install = spawn(config.path+"/scripts/pullGit.sh", [playbook.location, 'playbook_'+playbook._id], {
// 		cwd: home,
// 		env: {
// 			HOME: home,
// 			OLDPWD: home,
// 			PWD: home,
// 			LOGNAME: user,
// 			USER: user,
// 			TERM: 'xterm',
// 			SHELL: '/bin/bash',
// 			PATH: process.env.PATH+':/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin:/root/bin',
// 			LANG: 'en_GB.UTF-8'
// 		}
// 	});
// 	install.stdout.on('data', playbookOutputHandler.bind(task));
// 	install.stderr.on('data', playbookOutputHandler.bind(task));
//
// 	install.on('close', function(code) {
// 		playbookOutputHandler.call(task, "\n\nPlaybook Downloaded.\n");
//
// 		done(null, task, playbook);
// 	});
// }

function setupFolders (task, playbook, done){
	// Create folders
	playbookOutputHandler.call(task, "\nCreating Playbook Folders...\n");

	var opt = spawn('mkdir', ['-p', './running/tmp/playbook_'+playbook._id], {
		cwd: __dirname + '/../'
	});
	opt.stdout.on('data', playbookOutputHandler.bind(task));
	opt.stderr.on('data', playbookOutputHandler.bind(task));

	opt.on('close', function(code) {

		if (code !== 0) {
			return done('Error on creating playbook folders!');
		}
		else {
			playbookOutputHandler.call(task, "\n\nFolders Created.\n");
		}

		done(null, task, playbook);

	});

}

function setupHosts (task, playbook, done) {

	fs.writeFile( __dirname + '/../running/tmp/playbook_'+playbook._id+'/semaphore_hosts', task.hostlist, function (err) {
		done(err, task, playbook);
	});

}

function setupVault (task, playbook, done) {
	fs.writeFile( __dirname +'/../running/tmp/playbook_'+playbook._id+'/semaphore_vault_pwd', playbook.vault_password, function (err) {
		done(err, task, playbook);
	});
}

function compileLib (task, playbook, done){

	playbookOutputHandler.call(task, "\nCompile\n");

	var path = "config/";

	console.log("ttttttt",task.job.tmp);

	if(task.job.tmp){
		path = path+"tmp/";
	}

	var compile = spawn('./start.sh', [path+task.job.play_file, task._id], {
		cwd: __dirname +'/../streamon/'
	});

	compile.stdout.on('data', playbookOutputHandler.bind(task));
	compile.stderr.on('data', playbookOutputHandler.bind(task));

	compile.on('close', function(code) {
		if (code !== 0) {
			// Task failed
			return done('Compile error');
		}
		else {
			console.log('Compile ok!');
		}
		done(null, task, playbook);
	});
}

function playTheBook (task, playbook, done) {
	playbookOutputHandler.call(task, "\nStarting play "+task.job.play_file+".\n");

	var args = ['-u root', '-v', '-i', 'semaphore_hosts'];
	if (task.job.use_vault && playbook.vault_password && playbook.vault_password.length > 0) {
		args.push('--vault-password-file='+'semaphore_vault_pwd');
	}
	// private key to login to server[s]
	args.push('--private-key=' + home + '.ssh/id_rsa');
	// the playbook file
	args.push( __dirname + '/../sys/setup.yml');
	// the extra vars
	if( task.job.extra_vars !== undefined && task.job.extra_vars.length>0){
		var vars = task.job.extra_vars.split(" ");

		for (var i=0; i < vars.length; i++){
			args.push('-e');
			args.push(vars[i]);
		}
	}

	//console.log(args);

	var playbookgo = spawn("ansible-playbook", args, {
		cwd: __dirname + '/../running/tmp/playbook_'+playbook._id,
		env: {
			HOME: home,
			OLDPWD: home,
			PWD: __dirname + '/../running/tmp/playbook_'+playbook._id,
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

	//console.log(playbookgo);
	playbookgo.stdout.on('data', playbookOutputHandler.bind(task));
	playbookgo.stderr.on('data', playbookOutputHandler.bind(task));

	playbookgo.on('close', function(code) {
		//console.log('done.', code);

		if (code !== 0) {
			// Task failed
			return done('Failed with code '+code);
		}

		done(null, task, playbook);
	});
}

function setupCheckStatus (task, playbook, done){
	playbookOutputHandler.call(task, "\nStarting setupCheckStatus.\n");

	var opt = spawn('mkdir', ['-p', 'running/status/playbook_'+playbook._id+'/task_'+task._id], {
		cwd: __dirname + '/../'
	});

	opt.stdout.on('data', playbookOutputHandler.bind(task));
	opt.stderr.on('data', playbookOutputHandler.bind(task));

	opt.on('close', function(code) {

		if (code !== 0) {
			return done('Create directory error');
		}
		else {
			console.log('Create directory ok!');

			var riOpt = spawn('cp', ['packet/values.txt', '../running/status/playbook_'+playbook._id+'/task_'+task._id+'/values.txt'], {
				cwd: __dirname +'/../streamon/'
			});

			riOpt.stdout.on('data', playbookOutputHandler.bind(task));
			riOpt.stderr.on('data', playbookOutputHandler.bind(task));

			riOpt.on('close', function(code) {
				if (code !== 0) {
					return done('Copy values.txt error');
				}
				else {
					console.log('Copy values.txt ok!');
					var opt2 = spawn('cp', ['semaphore_hosts', '../../status/playbook_'+playbook._id+'/task_'+task._id+'/semaphore_hosts'], {
						cwd: __dirname + '/../running/tmp/playbook_'+playbook._id
					});

					opt2.stdout.on('data', playbookOutputHandler.bind(task));
					opt2.stderr.on('data', playbookOutputHandler.bind(task));

					opt2.on('close', function(code) {

						if (code !== 0) {
							return done('Copy hostfile error');
						}
						else {
							console.log('Copy hostfile ok!');

							var opt3 = spawn('cp', ['status.yml','edit.yml', '../running/status/playbook_'+playbook._id+'/task_'+task._id], {
								cwd: __dirname + '/../sys'
							});

							opt3.stdout.on('data', playbookOutputHandler.bind(task));
							opt3.stderr.on('data', playbookOutputHandler.bind(task));

							opt3.on('close', function(code) {

								if (code !== 0) {
									return done('Copy status.yml and edit.yml error');
								}
								else {
									console.log('Copy status.yml and edit.yml ok!');

									done(null, task, playbook);
								}
							});
						}
					});
				}
			});
		}
	});
}

function checkStatus (task, playbook, done){

	playbookOutputHandler.call(task, "\nStarting checkStatus.\n");

	var args = ['-u root', '-vvvv', '-i', 'semaphore_hosts'];
	if (task.job.use_vault && playbook.vault_password && playbook.vault_password.length > 0) {
		args.push('--vault-password-file='+'semaphore_vault_pwd');
	}

	// private key to login to server[s]
	args.push('--private-key=' + home + '.ssh/id_rsa');

	// the playbook file
	args.push('status.yml');

	// the extra vars
	if( task.job.extra_vars !== undefined && task.job.extra_vars.length>0){
		var vars = task.job.extra_vars.split(" ");

		for (var i=0; i < vars.length; i++){
			args.push('-e');
			args.push(vars[i]);
		}
	}

	//console.log(args);

	var cronJob = new CronJob({
		cronTime: '*/5 * * * * *',
		onTick: function() {
			var last;
			fs.stat( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', function(err, stat) {
				if(err === null) {
					//console.log('File exists 1');
					fs.readFile( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', 'utf8', function (err,data) {
						if (err) {
							return ('Failed on readFile '+err);
						}
						else {
							last = data;
						}
					});
				}
				else if(err.code == 'ENOENT') {
					//console.log("File not found: "+err);
				}
				else {
					return ('Some other error on stat: '+err);
				}
			});

			var p_playbookgo = spawn("ansible-playbook", args, {
				cwd: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
				env: {
					HOME: home,
					OLDPWD: home,
					PWD: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
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

			//p_playbookgo.stdout.on('data', playbookOutputHandler.bind(task));
			//p_playbookgo.stderr.on('data', playbookOutputHandler.bind(task));

			p_playbookgo.on('close', function(code) {
				if (code !== 0) {
					// Failed
					fs.stat( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', function(err, stat) {
						if(err === null) {
							//console.log('File exists 2');
							fs.readFile( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', 'utf8', function (err,data) {
								if (err) {
									return ('Failed on readFile: '+err);
								}
								else {
									if (parseInt(data) != 42){
										fs.writeFile( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', "42", function(err) {
											if(err) {
												return console.log(err);
											}
											else {
												//console.log("The file 42 was saved and task updated");
												task.status = "Unreachable";
												task.save();
												app.io.emit('task.statusUpdate', {
													task_id: task._id,
													playbook_id: task.playbook,
													task_status: task.status
												});
											}
										});
									}
								}
							});
						}
						else if(err.code == 'ENOENT') {
							console.log("File not found: "+err);
						}
						else {
							return ('Some other error on stat: '+err);
						}
					});
					return ('Failed on playbook_go with code: '+code);
				}
				else{
					fs.stat( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', function(err, stat) {
						if(err === null) {
							//console.log('File exists 3');
							fs.readFile( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', 'utf8', function (err,data) {
								if (err) {
									return ('Failed on readFile: '+err);
								}
								else {
									if (last != data) {
										if (data == 1){
											task.status = "Running";
										}
										else if (data == 0 ){
											task.status = "Stopped";
										}
										//console.log("task update!");
										task.save();
										app.io.emit('task.statusUpdate', {
											task_id: task._id,
											playbook_id: task.playbook,
											task_status: task.status
										});
									}
								}
							});
						}
						else if(err.code == 'ENOENT') {
							console.log("File non trovato: "+err);
						}
						else {
							return ('Some other error on stat 2: '+ err);
						}
					});
				}
			});
			return 0;
		},
		start: false
	});

	//console.log(task._id);

	hashtable.put(task._id.toString(), cronJob);

	var playbookgo = spawn("ansible-playbook", args, {
		cwd: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
		env: {
			HOME: home,
			OLDPWD: home,
			PWD: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
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

	//console.log(playbookgo);

	//playbookgo.stdout.on('data', playbookOutputHandler.bind(task));
	//playbookgo.stderr.on('data', playbookOutputHandler.bind(task));

	playbookgo.on('close', function(code) {
		if (code !== 0) {
			// Failed
			spawn("echo", ['42', '>', 'resp'], {
				cwd: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
				env: {
					HOME: home,
					OLDPWD: home,
					PWD: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
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
			task.status = "Unreachable";
			task.save();
			app.io.emit('task.statusUpdate', {
				task_id: task._id,
				playbook_id: task.playbook,
				task_status: task.status
			});
			return done('Failed with code '+code);
		}
		else {
			fs.stat( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', function(err, stat) {
				if(err === null) {

					//console.log('File exists 4');

					fs.readFile( __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/resp', 'utf8', function (err,data) {
						if (err) {
							return done('Failed on readFile: '+err);
						}
						else {
							if (data == 1) {
								task.status = "Running";
							}
							else if (data === 0 ) {
								task.status = "Stopped";
							}
							task.save();
							app.io.emit('task.statusUpdate', {
								task_id: this._id,
								playbook_id: this.playbook,
								task_status: task.status
							});
							cronJob.start();
							done(null, task, playbook);
						}
					});
				}
				else if(err.code == 'ENOENT') {
					console.log("File not found: "+err);
				}
				else {
					console.log('Some other error: ', err);
					spawn("echo", ['42', '>', 'resp'], {
						cwd: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
						env: {
							HOME: home,
							OLDPWD: home,
							PWD: __dirname + '/../running/status/playbook_'+playbook._id+'/task_'+task._id+'/',
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
					task.status = "Unreachable";
					task.save();
					app.io.emit('task.statusUpdate', {
						task_id: task._id,
						playbook_id: task.playbook,
						task_status: task.status
					});
					return done('Some other error: ', err);
				}
			});
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

function zmqClientOutputHandler (chunk) {

	chunk = chunk.toString('utf8');

	if (!this.output) {
		this.outputZmq = "";
	}

	this.outputZmq += chunk;
	app.io.emit('zmqClient.output', {
		task_id: this._id,
		playbook_id: this.playbook,
		outputZmq: chunk
	});

	console.log(chunk);
}
