# objective-octocat-notifications


Objective Octocat Notifications is a mac app to hook Github Notifications into the Mac Notifications Center. The app will poll the Github API for new notifications. When it gets new notifications it uses the Mac Notifications Center to display an alert to the user. When the alert is clicked it will open a browser with the related url as well as mark the Github Notification as read.

## Features

- Uses Github OAuth for authentication.
- Github OAuth will only authorize the app for read access to your notifications compared to complete read/write access to everything (private repos included) on your account granted by a user auth token.
- Mac Keychain integration to save your Github Auth Token so authentication doesn't need to be run on every launch of the app.
- Status bar app with a circle icon designed after the github button so it doesn't take space on your dock.
- The status bar icon glows blue when you have notifications that need to be addressed.

## Features Coming Soon

See [Issues](https://github.com/squaresurf/objective-octocat-notifications/issues) for upcoming work to be done.

## Download

You can download the latest build of app from the [Releases](https://github.com/squaresurf/objective-octocat-notifications/releases) page.

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).


## LICENSE

This project is released under the [MIT License](LICENSE).

## Thanks

### [Flowboard](https://flowboard.com)

First off I would like to thank [Flowboard](https://flowboard.com) for which I would not have been inspired to create this app not to mention the fact that they provide me a wonderful environment to build beautiful things. I also couldn't have done this without my co-workers who have contributed quite a bit of testing and patience.

### [AFNetworking](https://github.com/AFNetworking/AFNetworking)

Thank you [Mattt Thompson](https://github.com/mattt) for creating AFNetworking! It greatly reduced the amount of time needed to create this app.

### [Popup Example](https://github.com/shpakovski/Popup)

Thank you [Vadim Shpakovski](https://github.com/shpakovski) for creating a great Mac status bar example app. It has taught me a ton, not to mention contributed quite a bit to the usefulness of this app.


==============

Happy hacking,  
Daniel
