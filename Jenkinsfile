pipeline {
  agent any
  environment {
    GIT = credentials('github')
  }
  stages {
    stage('Prerequisites') {
      steps {
        sh '/usr/local/bin/pod install --project-directory=GiniVisionExample/'
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 6\' | /usr/local/bin/xcpretty -c'
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild test -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 6\' | /usr/local/bin/xcpretty -c'
      }
    }
  }
}
