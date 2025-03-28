# rea1shane/zircon

A fork of the Zim official theme [eriner](https://github.com/zimfw/eriner).
Some style changes and more last execution info.

The aim of this theme is to only show you _relevant_ information. Like most
prompts, it will only show git information when in a git working directory.
However, it goes a step further: everything from the current user and hostname
to whether the last call exited with an error to whether background jobs are
running in this shell will all be displayed automatically when appropriate.

<img width="706" src="https://raw.githubusercontent.com/rea1shane/zircon/master/screenshot.png" alt="Afterglow Theme">

## What does it show?

- Last execution info:
  - Execution start time.
  - Execution duration.
  - Return value when there was an error.
- Status segment:
  - `⚡` when you're root.
  - Background jobs count when there are background jobs.
  - Python [venv](https://docs.python.org/3/library/venv.html) indicator.
  - `username@hostname` when in a ssh session.
- Working directory segment.
  - Red background when there was an error.
- Git segment (background color varies if working tree is clean or dirty):
  - Current branch name, or commit short hash when in ['detached HEAD' state](https://git-scm.com/docs/git-checkout#_detached_head).
  - `●` when in a dirty working tree.

## Settings

The background color for each segment can be customized with an environment
variable. If the variable is not defined, the respective default value is used.

| Variable     | Description                                             | Default value |
| ------------ | ------------------------------------------------------- | ------------- |
| STATUS_COLOR | Status segment color                                    | black         |
| PWD_COLOR    | Working directory segment color                         | blue          |
| ERR_COLOR    | Working directory segment color when there was an error | red           |
| CLEAN_COLOR  | Clean git working tree segment color                    | green         |
| DIRTY_COLOR  | Dirty git working tree segment color                    | yellow        |

## Advanced settings

You can customize how the current working directory is shown with the
[prompt-pwd module settings](https://github.com/zimfw/prompt-pwd/blob/master/README.md#settings).

The git indicators can be customized by changing the following git-info module
context formats:

| Context name | Description         | Default format |
| ------------ | ------------------- | -------------- |
| branch       | Branch name         | ` %b`         |
| commit       | Commit short hash   | `➦ %c`         |
| action       | Special action name | ` (%s)`        |
| dirty        | Dirty state         | ` ●`           |

Use the following command to override a git-info context format:

    zstyle ':zim:git-info:<context_name>' format '<new_format>'

For detailed information about these and other git-info settings, check the
[git-info documentation](https://github.com/zimfw/git-info/blob/master/README.md#settings).

These advanced settings must be overridden after the theme is initialized.

## Requirements

In order for this theme to render correctly, a font with Powerline symbols is
required. A simple way to install a font with Powerline symbols is to follow the
[instructions here](https://github.com/powerline/fonts/blob/master/README.rst#installation).

Requires rea1shane's [execution-info](https://github.com/rea1shane/execution-info) module to show the last execution's start/end time and duration, Zim's [prompt-pwd](https://github.com/zimfw/prompt-pwd) module to show the current working directory, and
[git-info](https://github.com/zimfw/git-info) to show git information.
