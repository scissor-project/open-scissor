define(['app'], function (app) {
	app.registerFactory('Job', ['$http', function ($http) {
		var Job = function (playbook,id,cb) {
			if (!id || !playbook) {
				return;
			}
			this.id = id;
			this.get(playbook,cb);
		};

		Job.prototype.save = function (playbook) {
			return $http.put('/playbook/'+playbook.data._id+'/job/'+this.data._id, this.data);
		};

		Job.prototype.add = function (playbook) {
			return $http.post('/playbook/'+playbook.data._id+'/jobs', this.data);
		};

		Job.prototype.delete = function (playbook) {
			return $http.delete('/playbook/'+playbook.data._id+'/job/'+this.data._id);
		};

		Job.prototype.get = function (playbook,cb) {
			var self = this;

			return $http.get('/playbook/'+playbook.data._id+'/job/'+this.id).success(function (data, status) {
				self.data = data;
				cb();
			})
			.error(function (data, status) {
				cb(data, status);
			});
		};

		// Job.prototype.run = function (playbook) {
		// 	return $http.post('/playbook/'+playbook.data._id+'/job/'+this.data._id+'/run');
		// };

		Job.prototype.runAll = function (playbook,save) {
			console.log("run all");
			return $http.post('/playbook/'+playbook.data._id+'/job/'+this.data._id+'/run');
		};

		Job.prototype.runGroup = function (playbook, hostgroup_id) {
			console.log("run group");
			return $http.post('/playbook/'+playbook.data._id+'/job/'+this.data._id+'/hostgroup/'+hostgroup_id+'/run');
		};

		Job.prototype.runSingle = function (playbook, host_id) {
			console.log("run host", host_id);
			return $http.post('/playbook/'+playbook.data._id+'/job/'+this.data._id+'/host/'+host_id+'/run');
		};

		return Job;
	}]);
});
