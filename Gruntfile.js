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
                        'coffee/config.coffee',
                        // Events
                        'coffee/events/car_move_event.coffee',
                        'coffee/events/pickup_event.coffee',
                        'coffee/events/drop_event.coffee',
                        'coffee/events/pickup_zone_vanished_event.coffee',
                        'coffee/events/drop_zone_vanished_event.coffee',
                        'coffee/events/game_over_event.coffee',
                        // Utils
                        'coffee/utils/event_bus.coffee',
                        // Helpers
                        'coffee/helpers/double_helper.coffee',
                        'coffee/helpers/point_helper.coffee',
                        // Structs
                        'coffee/structs/point.coffee',
                        // Game
                        'coffee/game/grid.coffee',
                        'coffee/game/car.coffee',
                        'coffee/game/users/source.coffee',
                        'coffee/game/users/user_engine.coffee',
                        'coffee/game/zones/zone.coffee',
                        'coffee/game/zones/pickup_zone.coffee',
                        'coffee/game/zones/drop_zone.coffee',
                        'coffee/game/ride_engine.coffee',
                        'coffee/game/score_manager.coffee',
                        'coffee/presenters/home_presenter.coffee',
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

