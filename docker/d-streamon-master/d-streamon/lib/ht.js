var models = require('./models');
var fs = require('fs');
var spawn = require('child_process').spawn;

var HashTable = require('hashtable');
var hashtable = new HashTable();

var CronJob = require('cron').CronJob;

var home = process.env.HOME + '/';
var user = process.env.USER;

var app = require('./app');

//Initialize hashtable
models.Task.find({}, function(err, resp) {
    resp.forEach(function(resp) {

    	if (resp.installation == "Completed") {

    		fs.writeFile( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', "42", function(err) {
    			if(err) {
        			return console.log(err);
    			}
    			else{
					console.log("Ht: File set on 42 and Task set on Unreachable");
					resp.status = "Unreachable";
    				resp.save();
    				app.io.emit('task.statusUpdate', {
						task_id: resp._id,
						playbook_id: resp.playbook,
						task_status: resp.status
					});
	    		}
			});


		    var cronJob = new CronJob({
				cronTime: '*/5 * * * * *',
  				onTick: function() {
  					var last;
     				fs.stat( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', function(err, stat) {
    					if(err === null) {
        					//console.log('Ht: File exists 1');
							fs.readFile( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', 'utf8', function (err,data) {
  								if (err) {
    								return ('Failed on readFile '+err);
  								}
  								else {
  									last = data;
  								}
							});
    					}
    					else if(err.code == 'ENOENT') {
        					console.log("Ht: File not found "+err);
    					}
    					else {
    						return ('Ht: Some other error on stat '+err);
    					}
					});

     				var p_playbookgo = spawn("ansible-playbook", ['-u root', '-v', '-i', 'semaphore_hosts', '--private-key='+ home + '.ssh/id_rsa', 'status.yml'], {
						cwd: __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/',
						env: {
							HOME: home,
							OLDPWD: home,
							PWD: __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/',
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
							fs.stat( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', function(err, stat) {
    							if(err === null) {
        							//console.log('Ht: File exists 2');
									fs.readFile( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', 'utf8', function (err,data) {
  										if (err) {
    										return ('Failed on readFile: '+err);
  										}
	  									else {
  											if (parseInt(data) != 42){
  												fs.writeFile( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', "42", function(err) {
    												if(err) {
        												return console.log(err);
    												}
    												else{
														//console.log("Ht: The file 42 was saved and task updated");
														resp.status = "Unreachable";
    													resp.save();
    													app.io.emit('task.statusUpdate', {
															task_id: resp._id,
															playbook_id: resp.playbook,
															task_status: resp.status
														});
	    											}
												});
  											}
  										}
									});
    							}
    							else if(err.code == 'ENOENT') {
        							console.log("Ht: File not found "+err);
	    						}
    							else {
    								return ('Ht: Some other error on stat '+err);
    							}
							});
								return ('Ht: Failed on playbook_go with code: '+code);
						}
						else{
							fs.stat( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', function(err, stat) {
    							if(err === null) {
        							//console.log('Ht: File exists 3');
							    	fs.readFile( __dirname + '/../running/status/playbook_'+resp.playbook+'/task_'+resp._id+'/resp', 'utf8', function (err,data) {
  										if (err) {
    										return ('Ht: Failed on readFile: '+err);
  										}
  										else {

  											if (last != data) {
  												if (data == 1){
  													resp.status = "Running";
  												}
  												else if (data == 0 ){
  													resp.status = "Stopped";
  												}
  												//console.log("Ht: task update!");
  												resp.save();
  												app.io.emit('task.statusUpdate', {
													task_id: resp._id,
													playbook_id: resp.playbook,
													task_status: resp.status
												});
  											}
  										}
									});
    							}
    							else if(err.code == 'ENOENT') {
        							console.log("Ht: File non trovato "+err);
	    						}
    							else {
    								return ('Ht: Some other error on stat 2 '+ err);
    							}
							});
						}
					});
					return 0;
  				},
  				start: false
			});

			hashtable.put(resp._id.toString(), cronJob);

			if (hashtable.has(resp._id.toString())) {
				cronJob.start();
			}
			else {
				return ('Some error on hashtable.put');
			}
		}
    });
});

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

	//console.log(chunk);
}

/*function zmqClientOutputHandler (chunk) {

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

	//console.log(chunk);
}*/

exports.put = function (id, cronJob){
	id = id.toString();
	hashtable.put(id,cronJob);
};


exports.remove = function (id){
	id = id.toString();

	if (hashtable.has(id)) {
		cronJob = hashtable.get(id);
		cronJob.stop();
	}

	return (hashtable.remove(id));
};
