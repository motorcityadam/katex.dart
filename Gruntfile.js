module.exports = function( grunt ) {

  // Project configuration.
  grunt.initConfig({

    pkg: grunt.file.readJSON( 'package.json' ),

    karma: {
      unit: {
        configFile: 'karma.conf.js',
        background: true,
        singleRun: false,
        browsers: ['Dartium']
      },
      continuous: {
        configFile: 'karma.conf.js',
        singleRun: true,
        browsers: ['Dartium']
      }
    },

    watch: {
      //run unit tests with karma (server needs to be already running)
      karma: {
        files: [ 'lib/**/*.dart',
                 'test/**/*.dart' ],
        tasks: [ 'karma:unit:run' ] //NOTE the :run flag
      }
    }

  });

  grunt.loadNpmTasks( 'grunt-karma' );
  grunt.loadNpmTasks( 'grunt-contrib-watch' );

  grunt.registerTask( 'default', [ 'karma:unit:start',
                                   'watch' ] );

  grunt.registerTask( 'test', [ 'karma:continuous' ] );

};