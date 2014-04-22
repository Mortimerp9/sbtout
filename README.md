#Running SBT as a "service"

This is a work in progress to run compilation tasks in SBT non interactively and to get a meaningul output from it.
You can see it as running sbt as a local server, or as a service or whatever you want to call it.

It's mostly a hack to get "linter" or "error checker" plugins for text editors to be able to use the sbt `compile` command to check your code.
I give an example later in this README of how to set it up with [`flycheck-mode`](http://flycheck.readthedocs.org/) in emacs to highlight errors of compilation
and not just of syntax.
It would be as easy to setup a plugin for [Sublime Text Linter](https://github.com/SublimeLinter/SublimeLinter3) or vi to check your code with all the right
sbt compile configurations.

![missing import example](https://raw.githubusercontent.com/Mortimerp9/sbtout/master/screenshots/screenshot1.png)

##why not ensime

Ensime seems to have been abandoned and is a very heavy beast that doesn't deal very well with complex sbt projects.

#How does it work

You first have to manually start sbt for your project with the instruction given below, then you can start the "linter" plugin and it will communicate with sbt using `screen`.

The idea is to have sbt run as a background process somewhere and to send it `compile` commands when we want to get a list of errors.
We could run `sbt compile` every time, but that has quite a big overhead and you don't want to do that at every file save.

Instead, we run `sbt` in a `screen` process and send commands to it, redirecting its output to a file we can parse. It's a two step process:

  1- start sbt in your project with the command:

    PATHTO/sbtout/runsbt.sh

   (adapting the path to the `runsbt.sh` executable)

  2- when you want to compile, run

     PATHTO/sbtout/sbtout.sh

   This will send a `compile` command to sbt and output to stdout the compilation errors (or a success message) from sbt.
   In practice, you will not do that part manually but the text editor plugin will do it for you.

When you are finished, make sure to kill the sbt running in screen.

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

##what's wrong with flycheck's standard scala support?

flycheck will only call the `scalac` command on the current file and asks it to only show syntax errors. Syntax error highlighting is nice, but in scala, these are not the most common errors. What's interesting is to get feedback on type errors, missing imports, etc.

# Integration with Sublime Text and VI

Looking at the instruction for [Sublime Linter](https://sublimelinter.readthedocs.org/en/latest/#developer-documentation), it wouldn't be too difficult to write a plugin that
calls `sbtout.sh` properly, if you want to contribute, please feel free to do it.

If any `vi` users want to contribute to get it to work with it, it would be great!

#Work In Progress

This works fine for me, but clearly, it's a bit of a hack and requires some manual work.
