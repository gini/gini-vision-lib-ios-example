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
    stage('HockeyApp upload') {
      when {
        branch 'master'
      }
      environment {
        HOCKEYAPP_ID = credentials('VisionShowcaseHockeyAppID')
        HOCKEYAPP_API_KEY = credentials('VisionShowcaseHockeyAPIKey')
        CLIENT_ID = credentials('VisionShowcaseClientID')
        CLIENT_PASSWORD = credentials('VisionShowcaseClientPassword')
      }
      steps {
        sh 'rm -rf build'
        sh 'mkdir build'
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        sh 'scripts/build-number-bump.sh ${HOCKEYAPP_API_KEY} ${HOCKEYAPP_ID}'
        sh 'xcodebuild -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme GiniVisionExample -configuration Release archive -archivePath build/GiniVisionExample.xcarchive | /usr/local/bin/xcpretty -c'
        sh 'xcodebuild -exportArchive -archivePath build/GiniVisionExample.xcarchive -exportOptionsPlist scripts/exportOptions.plist -exportPath build -allowProvisioningUpdates | /usr/local/bin/xcpretty -c'
        step([$class: 'HockeyappRecorder', applications: [[apiToken: env.HOCKEYAPP_API_KEY, downloadAllowed: true, filePath: 'build/GiniVisionExample.ipa', mandatory: false, notifyTeam: false, releaseNotesMethod: [$class: 'NoReleaseNotes'], uploadMethod: [$class: 'VersionCreation', appId: env.HOCKEYAPP_ID]]], debugMode: false, failGracefully: false])

        sh 'rm -rf build'
        sh 'rm Example/Release-keys.xcconfig'
      }
    }
  }
}