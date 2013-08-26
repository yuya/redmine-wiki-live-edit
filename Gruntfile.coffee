matchdep = require "matchdep"

module.exports = (grunt) ->
  config =
    pkg: grunt.file.readJSON "package.json"

    exec:
      purr:
        cmd: ->
          "afplay /System/Library/Sounds/Purr.aiff"
      compress:
        cmd: ->
          "zip -r build/#{config.pkg.name}-#{config.pkg.version}.zip ./#{config.pkg.name}"

    watch:
      dev:
        files: "src/*.coffee"
        tasks: ["coffee", "jshint", "exec:purr"]
      prod:
        files: "src/*.coffee"
        tasks: ["coffee", "jshint", "uglify", "exec:compress", "exec:purr"]

    coffee:
      dist:
        options:
          bare: true
        files: [
          "<%= pkg.name %>/background.js"     : "src/background.coffee",
          "<%= pkg.name %>/content_script.js" : "src/content_script.coffee"
        ]

    jshint:
      dist: [
        "<%= pkg.name %>/background.js",
        "<%= pkg.name %>/content_script.js"
      ]

      options: do ->
        ret = { globals: {} }
        opt = ["eqeqeq", "immed", "latedef", "shadow", "sub", "undef",
               "boss", "eqnull", "browser", "devel", "loopfunc"]
        ns  = ["chrome"]

        for o in opt then ret[o]         = true
        for n in ns  then ret.globals[n] = true

        return ret

    uglify:
      dist:
        files: [
          "<%= pkg.name %>/background.js"     : "<%= pkg.name %>/background.js",
          "<%= pkg.name %>/content_script.js" : "<%= pkg.name %>/content_script.js"
        ]

  grunt.initConfig config
  matchdep.filterDev("grunt-*").forEach grunt.loadNpmTasks

  grunt.registerTask "default", "watch:prod"
  grunt.registerTask "compile", ["coffee", "jshint", "uglify", "exec:compress", "exec:purr"]
  grunt.registerTask "dev", ["coffee", "jshint", "exec:purr"]
