'use strict';
const sass = require('node-sass');
module.exports = function (grunt) {

    grunt.initConfig({
        sass: {
            dist: {
                options: {
                    implementation: sass,
                    outputStyle: 'compressed',
                    sourceMap: true
                },
                files: [{
                    expand: true,
                    cwd: "lib/",
                    dest: "lib/",
                    src: ['**/*.scss'],
                    ext: '.css'
                }]
            }
        },
        watch: {
            options: {
                livereload: true,
                reload: true,
                atBegin: true // Runs every tasks at the beginning (once)
            },
            sass: {
                files: [
                    '**/*.scss'
                ],
                tasks: ['sass', 'postcss']
            }
        },
        postcss: {
            options: {
                remove: false,
                processors: [
                    require('autoprefixer')({remove: false})
                ]
            },
            dist: {
                src: '**/*.css'
            }
        }
    });

    // Load tasks
    grunt.loadNpmTasks('grunt-contrib-watch');
    grunt.loadNpmTasks('grunt-sass');
    grunt.loadNpmTasks('grunt-postcss');

    grunt.registerTask('dev', [
        'watch'
    ]);

};