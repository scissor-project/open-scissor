define([
	'app',
	'factories/job'
], function(app) {
	app.registerService('jobs', ['$http', 'Job', function($http, Job) {
		var self = this;

		self.get = function(playbook, cb) {
			$http.get('/playbook/'+playbook.data._id+'/jobs').success(function(data) {
				self.jobs = [];
				self.hosts = [];
				self.HostGroups = [];

				var probes = [];
				var hosts = [];
				var HostGroups = [];

				for (var j = 0; j < data.jobs.length; j++){
					probes.push(data.jobs[j]);
				}

				for (j = 0; j < data.hosts.length; j++){
					hosts.push(data.hosts[j]);
				}

				for (j = 0; j < data.HostGroups.length; j++){
					HostGroups.push(data.HostGroups[j]);
				}

				for (var i = 0; i < probes.length; i++) {
					var job = new Job();
					job.data = probes[i];

					self.jobs.push(job);
				}

				for (i = 0; i < hosts.length; i++) {
					var host = {};
					host.data = hosts[i];

					self.hosts.push(host);
				}

				for (i = 0; i < HostGroups.length; i++) {
					var HostGroup = {};
					HostGroup.data = HostGroups[i];

					self.HostGroups.push(HostGroup);
				}

				cb();
			});
		};
	}]);
});
