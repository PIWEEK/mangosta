gulp = require('gulp')

# Utilities
plumber = require("gulp-plumber")
size = require("gulp-filesize")
watch = require("gulp-watch")
cache = require("gulp-cached")

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
    scssMain: "app/styles/main.scss",
    cssDistFold: "dist/styles/"
    cssMainDist: "dist/styles/main.css"
    #################
    elementStyles: "app/styles/elements/**/*.scss"
}

##############################################################################
# HTML Related tasks
##############################################################################

gulp.task "jade", ->
    gulp.src(paths.jade)
    .pipe(plumber())
    .pipe(cache("jade"))
    .pipe(jade({pretty: true}))
    .pipe(gulp.dest(paths.dist))
    .pipe(connect.reload())

##############################################################################
# CSS Related tasks
##############################################################################

gulp.task "scsslint", ->
    gulp.src([paths.scssMain, paths.elementStyles])
    .pipe(cache("scsslint"))
    .pipe(scsslint(
        {'config': 'scsslint.yml'}
    ))

gulp.task "sass", ["scsslint"], ->
    gulp.src([paths.scss, '!' + paths.elementStyles])
    .pipe(plumber())
    .pipe(sass())
    .pipe(gulp.dest(paths.dist))
    .pipe(connect.reload())

gulp.task "elementStyles", ["scsslint", "sass"], ->
    gulp.src(paths.elementStyles)
    .pipe(plumber())
    .pipe(cache("elementStyles"))
    .pipe(sass())
    .pipe(gulp.dest(paths.cssDistFold))
    .pipe(connect.reload())

gulp.task "csslint", ["sass", "elementStyles"], ->
    gulp.src(paths.cssMainDist)
    .pipe(plumber())
    .pipe(cache("csslint"))
    .pipe(csslint("csslintrc.json"))

##############################################################################
# Bullshit related tasks
##############################################################################

# Copy Files
gulp.task "copy",  ->
    gulp.src("#{paths.app}/vendor/**/*")
        .pipe(gulp.dest("#{paths.dist}/vendor/"))

##############################################################################
# Server Related tasks
##############################################################################

# Rerun the task when a file changes
gulp.task "watch", ->
    gulp.watch(paths.jade, ["jade"])
    gulp.watch(paths.scss, ["scsslint", "sass", "elementStyles", "csslint"])

gulp.task('connect', ->
    connect.server({
        root: paths.dist,
        port: 8080,
        livereload: true
    });
);

##############################################################################
# manage Tasks
##############################################################################

gulp.task "default", [
    "jade",
    "scsslint",
    "sass",
    "elementStyles",
    "csslint",
    "copy",
    "connect",
    "watch"
]
