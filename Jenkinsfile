node {
    stage 'Checkout'
    checkout scm

    stage 'Build'
    sh "docker build --tag applicaster/nginx-small-light:${env.BRANCH_NAME}-${env.JENKINS_SHA} ."
    sh 'env'

    stage 'Test'
    print "Testing..."

    stage 'Wait for approval'
    input message: "Does staging look good?"
}
