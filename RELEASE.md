# Release Process

This document describes the release process for a new version of the Gini Vision Library Showcase app for iOS.

1. Add new features only in separate `feature` branches and merge them into `develop`
2. Create a `release` branch from `develop`
  * Update version in Example App in Xcode project
3. Merge `release` branch into `master` and `develop`
4. Tag `master` branch with the same version used in 2
5. Push all branches to remote including tags
6. Build is automatically created and released on AppCenter: https://appcenter.ms/users/enrique-01/apps/Gini-Vision-Lib-Showcase

