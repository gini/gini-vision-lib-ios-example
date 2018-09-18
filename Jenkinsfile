pipeline {
  agent any
  environment {
    GIT = credentials('github')
  }
  stages {
    stage('Prerequisites') {
      environment {
        GEONOSIS_USER_PASSWORD = credentials('GeonosisUserPassword')
      }
      steps {
        sh 'security unlock-keychain -p ${GEONOSIS_USER_PASSWORD} login.keychain'
        withEnv(["PATH+=/usr/local/bin", "LANG=en_US.UTF-8"]) {
           	lock('refs/remotes/origin/master') {
              sh 'pod install --repo-update --project-directory=GiniVisionExample/'
            }
        }
      }
    }
    stage('Build') {
      steps {
        sh 'xcodebuild -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 6\''
      }
    }
    stage('Unit tests') {
      steps {
        sh 'xcodebuild build-for-testing -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" generic/platform=iOS'
        sh 'xcodebuild test-without-building -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -parallel-testing-enabled YES -destination \'platform=iOS Simulator,name=iPhone 6s,OS=9.3\''
        sh 'xcodebuild test-without-building -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -parallel-testing-enabled YES -destination \'platform=iOS Simulator,name=iPhone 7,OS=10.3.1\''
        sh 'xcodebuild test-without-building -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -parallel-testing-enabled YES -destination \'platform=iOS Simulator,name=iPhone X,OS=11.4\''
        sh 'xcodebuild test-without-building -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -parallel-testing-enabled YES -destination \'platform=iOS Simulator,name=iPhone XS Max,OS=12.0\''
      }
    }
    stage('HockeyApp upload') {
      when {
        branch 'master'
        expression {
            def tag = sh(returnStdout: true, script: 'git tag --contains $(git rev-parse HEAD)').trim()
            return !tag.isEmpty()
        }
      }
      environment {
        HOCKEYAPP_ID = credentials('VisionShowcaseHockeyAppID')
        HOCKEYAPP_API_KEY = credentials('VisionShowcaseHockeyAPIKey')
        CLIENT_ID = credentials('VisionShowcaseClientID')
        CLIENT_PASSWORD = credentials('VisionShowcaseClientPassword')
      }
      steps {
        sh 'mkdir build'
        sh 'scripts/build-number-bump.sh ${HOCKEYAPP_API_KEY} ${HOCKEYAPP_ID}'
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        sh 'xcodebuild -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme GiniVisionExample -configuration Release archive -archivePath build/GiniVisionExample.xcarchive'
        sh 'xcodebuild -exportArchive -archivePath build/GiniVisionExample.xcarchive -exportOptionsPlist scripts/exportOptions.plist -exportPath build -allowProvisioningUpdates'
        step([$class: 'HockeyappRecorder', applications: [[apiToken: env.HOCKEYAPP_API_KEY, downloadAllowed: true, filePath: 'build/GiniVisionExample.ipa', mandatory: false, notifyTeam: false, releaseNotesMethod: [$class: 'NoReleaseNotes'], uploadMethod: [$class: 'VersionCreation', appId: env.HOCKEYAPP_ID]]], debugMode: false, failGracefully: false])
      }
      post {
        always {
          sh 'rm -rf build || true'
        }
      }
    }
  }
}
