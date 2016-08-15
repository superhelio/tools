# SuperHelio Tools

Collection of cool tools that make life easier.

## The tools

- [release.sh](release.sh) - [Git Flow](http://nvie.com/posts/a-successful-git-branching-model/) release flow with automatic version bumping and changelog updating.
    - **Requires:** `bash`, `git` and `sed`
    - **Features:**
        - Helps you [keep your CHANGELOG.md up to date](http://keepachangelog.com/): Lists your commit messages, gives you a change to modify results before committing.
        - Supports GitHub and Bitbucket tag comparison urls
    - **Usage:**
        - Commit everything, run `release.sh` and follow directions

## How to use in your project

We try to keep this as easy as possible to include to your projects, so we are open to pull requests.

Currently we have [composer.json](composer.json) that installs the tools to your `vendor/bin` folder, you can [include the project as git submodule](https://gist.github.com/gitaarik/8735255) or just copy the files to your project. Which ever works best for you.

## Changelog

Please see [CHANGELOG](CHANGELOG.md) for more information what has changed recently. We use [release.sh](release.sh) to update the CHANGELOG.

## License

The MIT License (MIT). Please see [License File](LICENSE.md) for more information.
