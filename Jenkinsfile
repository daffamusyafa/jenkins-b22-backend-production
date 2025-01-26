def secret = 'ssh-global'
def server = 'team1@103.127.139.123'
def directory = 'wayshub-backend'
def branch = 'main'
def image = 'daffamusyafa/wayshub-be-b22:latest'
def discordWebhook = 'https://discord.com/api/webhooks/1328944292546482177/BSr4ChhnW6K2m6sNTj8IffnO7edFjYFxWZe2nW7fJSu96uFhYlZtjNE6aPBLpyIgEjtB'

pipeline {
    agent any
    stages {
        stage('Pulling New Code') {
            steps {
                sshagent([secret]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd backend/${directory}
                    git pull origin ${branch}
                    exit
                    EOF
                    """
                }
                sh """
                curl -X POST -H "Content-Type: application/json" \
                -d '{"content": "✅ Stage: Pulling New Code berhasil."}' \
                ${discordWebhook}
                """
            }
        }
        stage('Build Process') {
            steps {
                sshagent([secret]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd backend/${directory}
                    docker build --no-cache -t ${image} .
                    exit
                    EOF
                    """
                }
                sh """
                curl -X POST -H "Content-Type: application/json" \
                -d '{"content": "✅ Stage: Build Process berhasil."}' \
                ${discordWebhook}
                """
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('SonarQube') { // Ganti 'SonarQube' dengan nama server yang dikonfigurasi di Jenkins
                    sh """
                    sonar-scanner \
                    -Dsonar.projectKey=wayshub-backend \
                    -Dsonar.sources=./ \
                    -Dsonar.host.url=http://localhost:9000 \ // Sesuaikan dengan URL server SonarQube Anda
                    -Dsonar.login=YOUR_TOKEN_HERE
                    """
                }
                sh """
                curl -X POST -H "Content-Type: application/json" \
                -d '{"content": "✅ Stage: SonarQube Analysis berhasil."}' \
                ${discordWebhook}
                """
            }
        }
        stage('Quality Gate') {
            steps {
                timeout(time: 1, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
                sh """
                curl -X POST -H "Content-Type: application/json" \
                -d '{"content": "✅ Quality Gate passed! Kode Anda sudah memenuhi standar kualitas."}' \
                ${discordWebhook}
                """
            }
        }
        stage('Deploy') {
            steps {
                sshagent([secret]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${server} << EOF
                    cd backend/${directory}
                    docker compose down
                    docker compose up -d
                    exit
                    EOF
                    """
                }
                sh """
                curl -X POST -H "Content-Type: application/json" \
                -d '{"content": "✅ Stage: Deploy berhasil. Aplikasi berhasil di-deploy!"}' \
                ${discordWebhook}
                """
            }
        }
    }
    post {
        failure {
            sh """
            curl -X POST -H "Content-Type: application/json" \
            -d '{"content": "❌ Pipeline gagal. Mohon periksa logs Jenkins untuk informasi lebih lanjut."}' \
            ${discordWebhook}
            """
        }
    }
}
