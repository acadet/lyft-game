module.exports = function (grunt) {
    'use strict';
    // Project configuration
    grunt.initConfig({
        // Metadata
        // Task configuration
        coffee: {
            dist: {
                options: {
                    bare: true,
                    join: true
                },
                files: {
                    'js/main.js': [
                        'coffee/double_helper.coffee',
                        'coffee/point_helper.coffee',
                        'coffee/users.coffee',
                        'coffee/point.coffee',
                        'coffee/car.coffee',
                        'coffee/grid.coffee',
                        'coffee/home_presenter.coffee',
                        'coffee/main.coffee'
                    ]
                }
            }
        },
        jade: {
            dist: {
                options: {
                    pretty: true
                },
                files: {
                    'index.html': 'jade/home.jade'
                }
            }
        },
        sass: {
            dist: {
                options: {
                    sourcemap: 'none'
                },
                files: {
                    'css/home.css': 'sass/home.scss'
                }
            }
        },
        watch: {
            coffee: {
                files: 'coffee/**/*.coffee',
                tasks: ['coffee'],
                options: {
                    interrupt: true,
                    atBegin: true
                }
            },
            jade: {
                files: 'jade/**/*.jade',
                tasks: ['jade'],
                options: {
                    interrupt: true,
                    atBegin: true
                }
            },
            sass: {
                files: 'sass/**/*.scss',
                tasks: ['sass'],
                options: {
                    interrupt: true,
                    atBegin: true
                }
            }
        }
    });

    // These plugins provide necessary tasks
    grunt.loadNpmTasks('grunt-contrib-coffee');
    grunt.loadNpmTasks('grunt-contrib-jade');
    grunt.loadNpmTasks('grunt-contrib-sass');
    grunt.loadNpmTasks('grunt-contrib-watch');

    // Default task
    //grunt.registerTask('default', []);
};

