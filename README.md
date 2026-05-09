rea1shane/zircon
======

A fork of the Zim official [eriner] theme, which is itself a fork of the
Powerline-inspired [agnoster] theme.
The git segment display also references the Zim official [asciiship] theme.

The aim of this theme is to only show you *relevant* information. Like most
prompts, it will only show git information when in a git working directory.
However, it goes a step further: information such as the current SSH identity,
whether the last call exited with an error, and how long the last command took
will all be displayed automatically when appropriate.

<img width="706" src="https://raw.githubusercontent.com/rea1shane/zircon/master/screenshot.png">

What does it show?
------------------

  * Last execution information:
    * Start time of the last command.
    * Duration of the last command.
    * Return value when the command exited with an error.
  * Status segment:
    * `username@hostname` when in an SSH session.
  * Working directory segment:
    * Red background when the last command exited with an error.
  * Git segment (background color varies if working tree is clean or dirty):
    * Current branch name, or commit short hash with a `:` prefix when in
      ['detached HEAD' state].
    * Git action, when there's an operation in progress.
    * `$` when there are stashed states.
    * `!` when there are modified files.
    * `+` when there are staged files.
    * `>` and/or `<` when there are commits ahead and/or behind of remote,
      respectively.

Settings
--------

The background color for each segment can be customized with an environment
variable. If the variable is not defined, the respective default value is used.

| Variable     | Description                                      | Default value |
| ------------ | ------------------------------------------------ | ------------- |
| STATUS_COLOR | Status segment color                             | black         |
| PWD_COLOR    | Working directory segment color                  | blue          |
| ERR_COLOR    | Working directory segment color after an error   | red           |
| CLEAN_COLOR  | Clean git working tree segment color             | green         |
| DIRTY_COLOR  | Dirty git working tree segment color             | yellow        |

Advanced settings
-----------------

You can customize how the current working directory is shown with the
[prompt-pwd module settings].

The execution information can be customized by changing the following
execution-info module settings:

| Setting name       | Description           | Default value                   |
| ------------------ | --------------------- | ------------------------------- |
| duration-threshold | Duration threshold    | `0`                             |
| start-format       | Start time format     | `Executed at %Y-%m-%d %H:%M:%S` |
| duration-format    | Duration format       | `, took %d`                     |

Use the following command to override an execution-info setting:

    zstyle ':zim:execution-info' <setting_name> '<new_value>'

The git indicators can be customized by changing the following git-info module
context formats:

| Context name | Description              | Default format |
| ------------ | ------------------------ | -------------- |
| branch       | Branch name              | `%b`           |
| commit       | Commit short hash        | `:%c`          |
| action       | Special action name      | ` (%s)`        |
| stashed      | Stashed changes          | `\$`           |
| unindexed    | Unstaged changes         | `!`            |
| indexed      | Staged changes           | `+`            |
| ahead        | Ahead of upstream        | `>`            |
| behind       | Behind upstream          | `<`            |

Use the following command to override a git-info context format:

    zstyle ':zim:git-info:<context_name>' format '<new_format>'

For detailed information about these and other git-info settings, check the
[git-info documentation].

These advanced settings must be defined at the bottom of your `~/.zshrc`, after
the modules are initialized with `source ${ZIM_HOME}/init.zsh`, in order to
override the theme defaults.

Requirements
------------

In order for this theme to render correctly, a font with Powerline symbols is
required. A simple way to install a font with Powerline symbols is to follow the
[instructions here].

Requires rea1shane's [execution-info] module to show the last execution's start
time and duration, Zim Framework's [prompt-pwd] module to show the current
working directory, and [git-info] to show git information.

[eriner]: https://github.com/zimfw/eriner
[asciiship]: https://github.com/zimfw/asciiship
[agnoster]: https://github.com/agnoster/agnoster-zsh-theme
['detached HEAD' state]: https://git-scm.com/docs/git-checkout#_detached_head
[prompt-pwd module settings]: https://github.com/zimfw/prompt-pwd/blob/master/README.md#settings
[git-info documentation]: https://github.com/zimfw/git-info/blob/master/README.md#settings
[instructions here]: https://github.com/powerline/fonts/blob/master/README.rst#installation
[execution-info]: https://github.com/rea1shane/execution-info
[prompt-pwd]: https://github.com/zimfw/prompt-pwd
[git-info]: https://github.com/zimfw/git-info
