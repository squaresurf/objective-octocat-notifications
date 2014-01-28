# Contributing

## Workflow:
- Ensure an [issue](https://github.com/squaresurf/objective-octocat-notifications/issues) exists before making a pull request.
- Create a branch for your pull request.
- Open a pull request from your feature branch to the master branch.

## Authentication

In order for api authentication to work correctly you will need to add to the
GithubKeys.h file in the objective-octocat-notifications directory with either
a personal access token or a client id and client secret. If you've never built
the app then you will also need to create that file. 

The GithubKeys.h file is a part of the .gitignore file due to the sensitive
nature of its contents. So it doesn't exist on a clean checkout. There is a
build phase that ensures that file exists before compiling on a build. By doing
that the compiler is able to give a useful error about missing constants rather
than an ambiguous missing file error.

### Personal Access Token

This is the method most developers will use since it doesn't require
registering a new application with github. You can create a new "Personal
Access Token" on github here: https://github.com/settings/applications

Once you've created a new personal access token create the GithubKeys.h file in
the objective-octocat-notifications directory if it doesn't exists and fill it
with the following. Make sure to replace `TOKEN` with the access token value
from github.

```obj-c
#define GITHUB_TOKEN @"TOKEN"
```

### Registering 

There is a good chance that there are other items that need to be changed in
order for this codebase to work with multiple registered github apps. That
being said the GithubKeys.h file will look like the following if
objective-octocat-notifications is configured to work with a registered github
app.

```obj-c
#define GITHUB_CLIENT_ID @"CLIENT ID FROM GITHUB"
#define GITHUB_CLIENT_SECRET @"CLIENT SECRET FROM GITHUB"
```

