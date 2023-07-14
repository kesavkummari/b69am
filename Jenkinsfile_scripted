node {
   def mvnHome
  stage('Prepare') {
      git url: 'https://github.com/kesavkummari/cb9amjava.git', branch: '10am'
      mvnHome = tool 'maven'
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
