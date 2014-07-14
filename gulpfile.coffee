gulp = require('gulp')

# Utilities
plumber = require("gulp-plumber")
size = require("gulp-filesize")
watch = require("gulp-watch")

# HTML
jade = require("gulp-jade")
# CSS
sass = require("gulp-ruby-sass")
# Linter
csslint = require("gulp-csslint")
scsslint = require("gulp-scss-lint")
# Connect
connect = require("gulp-connect")

##############################################################################
# Ordered list of paths
##############################################################################
paths = {
    app: "app",
    dist: "dist",
    #################
    jade: "app/**/*.jade",
    #################
    scss: "app/**/*.scss",
    scssMain: "app/styles/styles.scss",
    scssMainDist: "dist/styles"
}

##############################################################################
# HTML Related tasks
##############################################################################

gulp.task "templates", ->
    gulp.src(paths.jade)
    .pipe(plumber())
    .pipe(jade({pretty: true}))
    .pipe(gulp.dest(paths.dist))
    .pipe(size())

##############################################################################
# CSS Related tasks
##############################################################################

gulp.task "scsslint", ->
    gulp.src([paths.scssMain, '!app/vendor/bourbon/**/*.scss'])
    .pipe(scsslint(
        {'config': 'scsslint.yml'}
    ))

gulp.task "sass", ->
    gulp.src(paths.scssMain)
    .pipe(plumber())
    .pipe(sass())
    .pipe(gulp.dest(paths.scssMainDist))

gulp.task "csslint", ->
    gulp.src(paths.scssMainDist)
    .pipe(csslint("csslintrc.json"))
    .pipe(csslint.reporter())

##############################################################################
# Server Related tasks
##############################################################################

# Rerun the task when a file changes
gulp.task "watch", ->
    gulp.watch(paths.jade, ["jade"])
    gulp.watch(paths.scss, ["scsslint", "sass", "csslint"])

##############################################################################
# manage Tasks
##############################################################################

gulp.task "default", [
    "templates",
    "scsslint",
    "sass",
    "csslint",
    "watch"
]
