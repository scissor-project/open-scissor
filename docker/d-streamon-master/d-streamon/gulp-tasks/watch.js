var gulp = require("gulp");

gulp.task("watch", function(){
  gulp.watch("api/swagger/swagger.yaml", ["swagger"]);
});
