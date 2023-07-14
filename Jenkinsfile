node {
   def mvnHome
  stage('Prepare') {
      git url: 'https://github.com/kesavkummari/cb9amjava.git', branch: 'b69am'
      mvnHome = tool 'maven'
   }
  stage ('Code Scan') {
      sh "'${mvnHome}/bin/mvn' verify sonar:sonar"
  }
  stage ('Clean') {
      sh "'${mvnHome}/bin/mvn' clean"
  }
  stage ('Validate') {
      sh "'${mvnHome}/bin/mvn' validate"
  }
  stage ('Compile') {
      sh "'${mvnHome}/bin/mvn' compile"
  }
  stage ('Test') {
      sh "'${mvnHome}/bin/mvn' test"
  }
  stage ('Package') {
      sh "'${mvnHome}/bin/mvn' package"
  }
  stage ('Verify') {
      sh "'${mvnHome}/bin/mvn' verify"
  }
  stage ('Install') {
      sh "'${mvnHome}/bin/mvn' install"
  }
}
