define([
	'app',
	'jquery',
	'services/jobs',
	'factories/job'
], function(app, $) {
	app.registerController('PlaybookJobsCtrl', ['$scope', 'jobs', '$compile', '$http', function($scope, jobs, $compile, $http) {

		$scope.jobs = jobs;

		jobs.get($scope.playbook, function () {
		});

		$scope.deleteJob = function (job) {
			job.delete($scope.playbook);
			jobs.get($scope.playbook, function () {
			});
		};

		$scope.runJob = function (job) {
			var data = JSON.parse($('#whereToRun option:selected').val());

			if(data.type == 0){
				alert("You have to choose where to turn the probes");
				return false;
			}
			var editor = ace.edit("editor");
			var save = document.getElementById('save').checked;
			var update = $("#update").val();
			var file = {};
			var name = "";

			if(update == 'true' && save == true){
				//console.log("caso uno");
				name = $('#nameFileXml').val();
				name = name.replace(".xml","");
				file.name = name;
				file.body = editor.getValue();
				file.playbook = job.data.playbook;

				$http({
					method : "POST",
					url : "/saveXml",
					data: file,
					dataType: "json"
				})
				.then(function mySuccess(newJob) {
					if (data.type == 1) {
						$http.post('/playbook/'+newJob.data.playbook+'/job/'+newJob.data._id+'/run');
					}
					else if (data.type == 2) {
						$http.post('/playbook/'+newJob.data.playbook+'/job/'+newJob.data._id+'/hostgroup/'+data.group_id+'/run');
					}
					else if (data.type == 3) {
						$http.post('/playbook/'+newJob.data.playbook+'/job/'+newJob.data._id+'/host/'+data.host_id+'/run');
					}
					$('#runProbesPanel').modal('hide');
					$('#whereToRun').val('{"type": 0}');
					$('#save').prop('checked', false);

				});
			}
			else if (update == 'true' && save == false){
				//console.log("caso due");
				name = "tmp";
				file.name = name;
				file.body = editor.getValue();
				file.playbook = job.data.playbook;
				$http({
					method : "POST",
					url : "/saveTmpXml",
					data: file,
					dataType: "json"
				})
				.then(function mySuccess(newJob) {
					if (data.type == 1) {
						$http.post('/playbook/'+newJob.data.playbook+'/job/'+newJob.data._id+'/run');
					}
					else if (data.type == 2) {
						$http.post('/playbook/'+newJob.data.playbook+'/job/'+newJob.data._id+'/hostgroup/'+data.group_id+'/run');
					}
					else if (data.type == 3) {
						$http.post('/playbook/'+newJob.data.playbook+'/job/'+newJob.data._id+'/host/'+data.host_id+'/run');
					}
					$('#runProbesPanel').modal('hide');
					$('#whereToRun').val('{"type": 0}');
					$('#save').prop('checked', false);
				});
			}
			else if (update == 'false') {
				//console.log("caso tre");
				if (data.type == 1) {
					$http.post('/playbook/'+job.data.playbook+'/job/'+job.data._id+'/run');
				}
				else if (data.type == 2) {
					$http.post('/playbook/'+job.data.playbook+'/job/'+job.data._id+'/hostgroup/'+data.group_id+'/run');
				}
				else if (data.type == 3) {
					$http.post('/playbook/'+job.data.playbook+'/job/'+job.data._id+'/host/'+data.host_id+'/run');
				}
				$('#runProbesPanel').modal('hide');
				$('#whereToRun').val('{"type": 0}');
				$('#save').prop('checked', false);
			}

			// $('#runProbesPanel').modal('hide');
			// $('#whereToRun').val('{"type": 0}');
			// $('#save').prop('checked', false);
			// $('#update').val(false);

			//job.run($scope.playbook);
			//$('#runProbesPanel').modal('hide');
		};

		$scope.openRunProbesPanel = function (job,hosts) {
			if(hosts > 0){
				var editor = ace.edit("editor");
				editor.setTheme("../ace/theme/xcode");
				editor.session.setMode("../ace/mode/xml");
				editor.$blockScrolling = Infinity;

				document.getElementById('editor').style.fontSize='16px';

				$('#btnRun').attr('ng-click','runThisJob()');
				$compile($("#btnRun"))($scope);
				$scope.runThisJob = function () {
						$scope.runJob(job);
				}

				var data = {};
				data.play_file = job.data.play_file;

				$http({
	        method : "POST",
	        url : "/getXml",
					data: data,
	    	})
				.then(function mySuccess(response) {
	      	editor.setValue(response.data);
					editor.gotoLine(1);
					$('#nameFileXml').val(job.data.play_file);
					$('#runProbesPanel').modal('show');

					editor.on('change', function() {
						$('#update').val(true);
						$('#save').removeAttr('disabled');
						$('#nameFileXml').removeAttr('disabled');
					});
	    	});

				$('#runProbesPanel').on('hide.bs.modal', function () {
					$('#btnRun').removeAttr('ng-click');
					$('#whereToRun').val('{"type": 0}');
					$('#save').prop('checked', false);
					$('#update').val(false);
					location.reload();
				});
			}
			else{
				$('#runProbesPanel').modal('show');
			}

		};

	}]);
});
