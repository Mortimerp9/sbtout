#Running SBT as a "service"

This is a work in progress to run compilation tasks in SBT non interactively and to get a meaningul output from it. You can see it as running sbt as a local server, or as a service or whatever you want to call it.

It's mostly a hack to get [`flycheck-mode`](http://flycheck.readthedocs.org/) in emacs to highlight errors of compilation and not just of syntax. It would probably work well with other editors such as vi or sublime I guess.

![missing import example](https://raw.githubusercontent.com/Mortimerp9/sbtout/master/screenshots/screenshot1.png)

##why not ensime

Ensime seems to have been abandoned and is a very heavy beast that doesn't deal very well with complex sbt projects.

##what's wrong with flycheck's scala support?

flycheck will only call the `scalac` command on the current file and asks it to only show syntax errors. Syntax error highlighting is nice, but in scala, these are not the most common errors. What's interesting is to get feedback on type errors, missing imports, etc.

#How does it work

With a bit of sweat you can get it to work. Right now, it's mostly a manual process to get it started, but once it's running, it works smoothly.

The idea is to have sbt run as a background process somewhere and to send it `compile` commands when we want to get a list of errors. We could run `sbt compile` every time, but that has quite a big overhead and you don't want to do that at every file save.

Instead, we run `sbt` in a `screen` process and send commands to it, redirecting its output to a file we can parse. It's a two step process:

  1- start sbt in your project with the command:

    screen -d -m -S sbt PATHTO/sbtout/runsbt.sh
    
   (adapting the path to the `runsbt.sh` executable)

  2- when you want to compile, run 

     PATHTO/sbtout/sbtout.sh
     
   This will send a `compile` command to sbt and output to stdout the compilation errors (or a success message) from sbt.
   

#Integration with FlyCheck

In your `init.el` or `.emacs`, setup a new checker:

    ```elisp

    (flycheck-define-checker sbt
                         "Checker for compilation with SBT"
                         :command ("PATHTO/sbtout/sbtout.sh") ;;<- SET THIS TO YOUR PATH
                         :error-patterns
                         ((error line-start "[error] " (file-name) ":" line ": " (message) line-end))
                         :modes scala-mode)

    ```
    
Be sure to set the right path to the executable.

In your scala buffer, start `flycheck-mode`, then run `flycheck-select-checker` and enter `sbt`. Next time flycheck will run, it will use your project sbt process to check for errors.
You can also get it to run a compilation with `flycheck-compile`.

![type error](https://raw.githubusercontent.com/Mortimerp9/sbtout/master/screenshots/screenshot2.png)

#Work In Progress

This works fine for me, but clearly, it's a bit of a hack and requires some manual work. You should be careful as the scripts use some hardcoded output files:  `/tmp/sbtout` and `/tmp/sbtlastcnt` to store the sbt errors and some state. If you are going to work on different projects at the same time, this might be an issue.
