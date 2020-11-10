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
          sh '/usr/local/bin/pod install --project-directory=GiniVisionExample/'
	}
      }
      post {
        failure {

          /* try to repo update just in case an outdated repo is the cause for the failed build so it's ready for the next */ 
          lock('refs/remotes/origin/return_assistant') {
            sh '/usr/local/bin/pod repo update'
          }
        }
      }
    }
    stage('Build') {
      environment {
        CLIENT_ID = credentials('VisionReturnAssistantShowcaseClientID')
        CLIENT_PASSWORD = credentials('VisionReturnAssistantShowcaseClientPassword')
      }
      steps {
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        sh 'xcodebuild -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 11\''
      }
    }
    stage('Unit tests') {
      environment {
        CLIENT_ID = credentials('VisionReturnAssistantShowcaseClientID')
        CLIENT_PASSWORD = credentials('VisionReturnAssistantShowcaseClientPassword')
      }
      steps {
        sh 'scripts/create_keys_file.sh ${CLIENT_ID} ${CLIENT_PASSWORD}'
        sh 'xcodebuild build-for-testing -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 11\''
        sh 'xcodebuild test-without-building -workspace GiniVisionExample/GiniVisionExample.xcworkspace -scheme "GiniVisionExample" -destination \'platform=iOS Simulator,name=iPhone 11\''
      }
    }
  }
}
