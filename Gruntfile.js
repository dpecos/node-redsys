module.exports = function(grunt) {

   grunt.loadNpmTasks('grunt-simple-mocha');
   grunt.loadNpmTasks('grunt-contrib-watch');

   grunt.initConfig({
      simplemocha: {
         src: ['test/**/*.coffee'],
         options: {
            reporter: 'spec',
            growl: true
         }
      },

      watch: {
         files:['src/**/*.coffee', 'test/**/*.coffee'],
         tasks:['simplemocha']
      }
   });

   grunt.registerTask('test', ['simplemocha']);
   grunt.registerTask('default', ['watch']);

};
