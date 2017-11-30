define(['app'], function (app) {
	app.registerFactory('Task', ['$http', function ($http) {
		var Task = function (id) {
			if (!id) {
				return;
			}

			this.id = id;
		};

		Task.prototype.delete = function (playbook, job) {
			return $http.delete('/playbook/'+playbook.data._id+'/job/'+job._id+'/task/'+this.data._id);
		};

		Task.prototype.get = function () {
			return $http.get('/task/'+this.id);
		};

		Task.prototype.getConfig = function (){
			return $http.get('/getConfig/'+this.data._id);
		};

		Task.prototype.edit = function (newValues){
			var data = {};
			data.newValues = newValues;
			return $http.post('/editConfig/'+this.data._id, data);
		};

		return Task;
	}]);
});
