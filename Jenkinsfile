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
        sh '/usr/local/bin/pod install --project-directory=Example/'
      }
      post {
        failure {

          /* try to repo update just in case an outdated repo is the cause for the failed build so it's ready for the next */ 
          lock('refs/remotes/origin/master') {
            sh '/usr/local/bin/pod repo update'
          }
        }
      }
    }
    stage('Build') {
      environment {
        CLIENT_ID = credentials('VisionShowcaseClientID')
        CLIENT_PASSWORD = credentials('VisionShowcaseClientPassword')
      }
      steps {
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        sh 'xcodebuild -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 11\''
      }
    }
    stage('Unit tests') {
      environment {
        CLIENT_ID = credentials('VisionShowcaseClientID')
        CLIENT_PASSWORD = credentials('VisionShowcaseClientPassword')
      }
      steps {
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        sh 'xcodebuild build-for-testing -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 11\''
        sh 'xcodebuild test-without-building -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 11\''
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
