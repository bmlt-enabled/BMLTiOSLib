# BMLTiOSLib Change Log

## 1.5.4

- **September 16, 2022**

- Updated to latest tools. No API changes.

## 1.5.3

- **July 21, 2022**

- Fixed yet another error in the filtering, where we were a bit too tight.

## 1.5.2

- **July 21, 2022**

- Fixed another error in the new feature, that specified incorrect URIs.

## 1.5.1

- **July 21, 2022**

- Fixed an error in the new feature, that specified incorrect URIs.

## 1.5.0

- **July 21, 2022**

- Added the ability to specify that only certain fields be returned by the server.

## 1.4.2

- **March 15, 2022**

- Updated to the latest tools. No functional or API changes.

## 1.4.1

- **January 28, 2022**

- There was a bug, in which the fetched formats were not being properly parsed, and the formats array was always empty. This has been fixed.

## 1.4.0

- **January 28, 2022**

- Removed the automatic format load from the server, during initialization.
- Added DocC support.

## 1.3.3

- **December 30, 2021**

- Fixed possible crashers, with search criteria.

## 1.3.2

- **December 14, 2021**

- Updated to latest tools version.

## 1.3.1

- **September 28, 2021**

- Updated to latest tools version.
- Minor doc fixes.

## 1.3.0

- **May 12, 2021**

- Updated to latest tools version.
- Updated some protocol declarations to use `AnyObject`, as opposed to `class`.
- Removed CocoaPods support.

## 1.2.22

- **March 9, 2021**

- Updated to latest tools version.

## 1.2.21

- **January 6, 2021**

- Added more support for virtual meetings.

## 1.2.20

- **August 1, 2020**

- Rearranged for GitHub Action

## 1.2.19

- **June 27, 2020**

- Updated docs for SPM support.
- Some basic reformatting.
- Rebuilt the docs.
- Slight refatoring to consolidate the String extension.
- Added the key file to make Markdown render in the project.

## 1.2.18

- **April 25, 2020**

- Fixed an issue where the library could crash, if given bad data in response to a change search.

## 1.2.17

- **April 2, 2020**

- Added support for the phone number field.

## 1.2.16

- **April 1, 2020**

- Added support for the virtual meeting link.

## 1.2.15

- **September 15, 2019**

- Tweaked a couple of inline allocation specifiers, because all of a sudden, things that were structs, are now classes, and "let" is perfectly fine.

## 1.2.14.2001

- **August 24, 2019**

- Updated to Swift 5.1/Xcode 11.
- Updated the file headers to indicate BMLT-Enabled as the authors.
- Updated the podspec to use the latest BMLT-Enabled links.

## 1.2.14.2000

- **August 1, 2019**

- Test release for Carthage.
- Modified the Jazzy docs for use in GH Pages.
- Got rid of the CocoaPods junk in the release project.
- Ensured proper Carthage operation.
- Changed the initial server URI, as the original was no longer valid.
- The minimum supported iOS version is now 11 ("Ours goes to 11").

## 1.2.13

- **April 13, 2019**

- Updated to Swift 5/Xcode 10.2. No operational changes.

## 1.2.12

- **December 28, 2018**

- Another minor date format tweak.
- Tweaked the versions of the harness projects.

## 1.2.11

- **December 28, 2018**

- Fixed another bug, where a date format was not specified correctly. This affected change records.

## 1.2.10

- **December 27, 2018**

- Fixed a bug (Thanks Patrick!) in the way that hours was being set in the meeting node class.
- Tweaked the LICENSE file to see if that helps CocoPods to figure out its the MIT license.

## 1.2.9

- **November 17, 2018**

- Moved the repo to the organizational GitHub repo.
- Changes to use the latest Xcode and Swift.

## 1.2.8

- **April 2, 2018**

- Added a parameter to the end of the URI "callingApp=" that appends the app name to the call, so the server knows what's calling.
- Xcode 9.3 updates.
- Swift 4.1 updates.

## 1.2.7

- **March 15, 2018**

- Force prper uppercasing of Weekday names. Some localizations have only lowercase.

## 1.2.6

- **January 7, 2018**

- Tweaked the sort value to account for weeks that start on days other than Sunday.

## 1.2.4

- **December 26, 2017**

- Added SPM Support (no operational changes).
- Added a CWD saver to the Jazzy script. This will allow it to be reintegrated into the build phases.

## 1.2.3

- **December 20, 2017**

- Broke the main class file into a bunch of smaller files (some, MUCH smaller), to keep Cocopods happy. Absolutely no functional changes.

## 1.2.2

- **December 13, 2017**

- Broke this changelog out into a separate file. Cocoapods is not updating the README, and I'm hoping that having the changelog in a separate file might encourage it to be updated.
- Improved the commenting, documentation and code formatting of the exported classes.
- Some general project cleanup.

## 1.2.1

- **December 12, 2017**

- This implements a bunch of internal structural changes to satisfy [SwiftLint](https://github.com/realm/SwiftLint), a utility for improving code quality. There should be absolutely no visible external changes, but it's a big change, internally.
- Removed the "auto [Jazzy](https://github.com/realm/jazzy)" documentation generator, as it slows down the build, and we can easily do it manually.
- Added a "Direct" test harness app. This implements the framework files directly, so it's easier to step through everything.

## 1.1.2

- **December 5, 2017**

- Updated to latest Xcode version.

## 1.1.1.3001

- **November 29, 2017**

- Spruced up this README, and tweaked some settings in the project.

## 1.1.1

- **November 23, 2017**

- There was a possibility of a crash if the session was terminated without a connection.

## 1.1.0

- **November 14, 2017**

- Some basic refactoring to make the library more "Swift-studly."
- Made some references weak/unowned that should have been declared as such. Even though it has not (yet) resulted in a leak, it could.
- Updating basic project format to Xcode 8-compatible.
- Major restrutcture and history reset for CocoaPods.
- The Git repo has been reset. I'll also keep only a master branch, with release tags.
- Moving repo to GitHub, as GitHub and CocoaPods play better together.
- Fixed an issue with the search tab sometimes crashing when selected (test app).

## 1.0.1

- **August 27, 2017**

- Fixed a possible crash that could be triggered by bad data in the weekday_index.
- Fixed a bug in the integer day and time (used for sorting).
- Added a check for a valid weekday index to the deleted meeting changelist response.
- Fixed a crash in the handler if an empty changelist was returned.
- Fixed an issue where older datasets caused parse problems.
- Slight update for the latest Xcode.
- Fixed an issue where Service bodies with no type would pooch the app.

## 1.0.0

- **January 25, 2017**

- The BMLTiOSLibDelegate protocol now has almost all its functions optional.
- Switched the project to the MIT License. That's better for a project that is destined to be included in other projects, some of which may be commercial.
- This will be a Swift-only library. I have given up on supporting Objective-C. Not that big a loss.

## 1.0.0.2001

- **January 14, 2017**

- Added the silly CYA plist thing that says I'm not consorting with turrists using encryption.

## 1.0.0.2000

- **January 14, 2017**

- First Beta Release of the BMLTiOSLib Project.
- This will include simple demo apps that use the framework.
- Added a "performMeetingSearch()" method to the search criteria object, to make it convenient for apps to use just that object as their interaction.

## 1.0.0.1000

- **January 9, 2017**

- First Alpha Release of the BMLTiOSLib Project.


