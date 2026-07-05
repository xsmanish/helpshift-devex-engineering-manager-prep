# Enterprise Guide: Jenkins Shared Libraries as Infrastructure as Code (IaC)

This document provides a production-grade, enterprise blueprint for automating and standardizing Jenkins pipelines across hundreds of service repositories using a **Jenkins Shared Library**. This setup treats the pipeline lifecycle as software development, ensuring zero-touch onboarding, strict compliance, and effortless pipeline mutations.

---

## 1. Enterprise Architecture & Workflow

In an enterprise environment, individual product teams own their application code and a minimal, declarative configuration file (`Jenkinsfile`). The DevOps/Platform engineering team owns the **Centralized Pipeline Library**, which dictates compliance, security scans, and deployment logic.

```text
+------------------------------------------------------------+

|                Centralized Shared Library                  |
|               (Managed by Platform Team)                    |
|                                                            |
|    +-------------------+      +-----------------------+    |
|    | vars/             |      | src/                  |    |
|    | standardPipeline  |      | com.enterprise.build  |    |
|    +---------+---------+      +-----------+-----------+    |
+--------------|----------------------------|----------------+

               | Imports                    | Instantiates
               |                            v
+--------------v---------------------------------------------+

|                Product Service Repository                  |
|                (Managed by App Developers)                 |
|                                                            |
|    +-------------------+      +-----------------------+    |
|    | Jenkinsfile       |      | Application Code      |    |
|    | (Passes Params)   |      | (Java, Node.js, etc.) |    |
|    +----+--------------+      +-----------------------+    |
+---------|--------------------------------------------------+
          |
          v Triggers
+------------------------------------------------------------+

|                   Dynamic Jenkins Pipeline                 |
|                                                            |
| [Checkout] -> [Compile & Test] -> [SonarQube] -> [Deploy]  |
+------------------------------------------------------------+
```

### CI/CD Mutation Workflow
1. A developer modifies the application code or changes a deployment parameter in their service repository's `Jenkinsfile`.
2. A Git `push` or Pull Request triggers the Jenkins webhook.
3. Jenkins reads the `Jenkinsfile` and dynamically pulls the immutable, versioned code from the **Shared Library Repository**.
4. The centralized library executes uniform stages (Lint, Test, SonarQube, Docker Build, Aqua/Trivy Scan, ArgoCD Sync) while adapting to the parameters passed by the service repo.

---

## 2. Directory Structures

### A. Centralized Shared Library Repository (`pipeline-shared-library`)
This repository contains the global variables (DSL steps) and underlying object-oriented helper classes.

```text
pipeline-shared-library/
├── vars/
│   ├── standardPipeline.groovy     # Main declarative pipeline wrapper (The entry point)
│   ├── log.groovy                  # Shared utility for standardized logging
│   └── notify.groovy               # Shared utility for Slack/Teams notifications
├── src/
│   └── com/
│       └── enterprise/
│           ├── pipeline/
│           │   ├── BuildManager.groovy     # Logic for Maven, Gradle, npm, etc.
│           │   └── SecurityScanner.groovy  # Logic for SonarQube, Trivy, Veracode
│           └── utils/
│               └── GitUtils.groovy         # Helper methods for git metadata extraction
└── README.md
```

### B. Microservice Repository (`sample-java-service`)
This is all that is required in a product team's application repository. No complex logic is exposed.

```text
sample-java-service/
├── src/                            # Application source code
├── pom.xml                         # Build configuration file
├── Jenkinsfile                     # Simple, declarative pipeline configuration
└── README.md
```

---

## 3. Production-Grade Enterprise Code

### Shared Library: Entry Point (`vars/standardPipeline.groovy`)
This script intercepts and abstracts the entire Jenkins pipeline lifecycle. It enforces strict compliance stages (like Security Scanning) that product teams cannot bypass.

```groovy
#!/usr/bin/env groovy
import com.enterprise.pipeline.BuildManager
import com.enterprise.pipeline.SecurityScanner

def call(Map config = [:]) {
    // 1. Merge default configuration with user-provided parameters
    def defaults = [
        techStack       : 'maven',
        sonarEnabled    : true,
        trivyEnabled    : true,
        agentLabel      : 'jenkins-agent-linux',
        slackChannel    : '#alerts-ci-cd'
    ]
    def pipelineConfig = defaults + config

    // 2. Instantiate backend pipeline managers from src/
    def buildManager = new BuildManager(this, pipelineConfig.techStack)
    def scanner      = new SecurityScanner(this)

    pipeline {
        agent { label "${pipelineConfig.agentLabel}" }
        
        options {
            timeout(time: 1, unit: 'HOURS')
            timestamps()
            buildDiscarder(logRotator(numToKeepStr: '30'))
            disableConcurrentBuilds()
        }

        environment {
            APP_NAME = "${env.JOB_BASE_NAME}"
            SCANNER_CLI = 'trivy'
        }

        stages {
            stage('Initialization & Checkout') {
                steps {
                    script {
                        log.info("Starting pipeline for ${env.APP_NAME} on branch ${env.BRANCH_NAME}")
                        checkout scm
                    }
                }
            }

            stage('Compile & Test') {
                steps {
                    script {
                        buildManager.executeTests()
                    }
                }
            }

            stage('Security & Static Code Analysis') {
                when { expression { pipelineConfig.sonarEnabled } }
                steps {
                    script {
                        scanner.runSonarQube(env.APP_NAME)
                    }
                }
            }

            stage('Vulnerability Scan') {
                when { expression { pipelineConfig.trivyEnabled } }
                steps {
                    script {
                        scanner.runContainerScan(env.APP_NAME)
                    }
                }
            }

            stage('Build & Publish Artifact') {
                steps {
                    script {
                        buildManager.buildAndPublish(env.APP_NAME)
                    }
                }
            }
        }

        post {
            always {
                cleanWs()
            }
            success {
                script {
                    notify.slack(pipelineConfig.slackChannel, "SUCCESS", "Pipeline built successfully!")
                }
            }
            failure {
                script {
                    notify.slack(pipelineConfig.slackChannel, "FAILURE", "Pipeline failed at stage: ${env.STAGE_NAME}")
                }
            }
        }
    }
}
```

### Shared Library: Backend Object Model (`src/com/enterprise/pipeline/BuildManager.groovy`)
Encapsulating logic inside standard Groovy classes keeps your `vars/` files uncluttered and allows for standard unit testing (via JenkinsSpock framework).

```groovy
package com.enterprise.pipeline

class BuildManager implements Serializable {
    private def steps
    private String techStack

    // Pass the Jenkins pipeline context ('this') into the class to access standard steps like sh, echo, error
    BuildManager(def steps, String techStack) {
        this.steps = steps
        this.techStack = techStack.toLowerCase()
    }

    void executeTests() {
        if (techStack == 'maven') {
            steps.sh 'mvn clean test'
        } else if (techStack == 'nodejs') {
            steps.sh 'npm install && npm test'
        } else {
            steps.error "Unsupported technology stack: ${techStack}"
        }
    }

    void buildAndPublish(String appName) {
        steps.echo "Packaging application for ${appName}..."
        if (techStack == 'maven') {
            steps.sh 'mvn package -DskipTests'
        } else if (techStack == 'nodejs') {
            steps.sh 'npm run build'
        }
    }
}
```

### Shared Library: Helper Utility (`vars/notify.groovy`)
```groovy
#!/usr/bin/env groovy

def slack(String channel, String status, String message) {
    def color = (status == 'SUCCESS') ? '#00FF00' : '#FF0000'
    slackSend(
        channel: channel,
        color: color,
        message: "JOB: ${env.JOB_NAME} | BUILD: #${env.BUILD_NUMBER}\nSTATUS: ${status}\nINFO: ${message}\nURL: ${env.BUILD_URL}"
    )
}
```

### Service Repository Configuration (`Jenkinsfile`)
This is all the application development team needs to manage. If they want to mutate their infrastructure—for example, upgrading their build matrix or disabling a heavy scanner temporarily—they simply modify this configuration.

```groovy
#!/usr/bin/env groovy

// Import the centralized library dynamically (or configure it globally in Jenkins settings)
@Library('pipeline-shared-library@v2.4.0') _ 

// Invoke the standardized enterprise pipeline
standardPipeline(
    techStack   : 'maven',
    sonarEnabled: true,
    trivyEnabled: true,
    slackChannel: '#team-alpha-ci'
)
```

---

## 4. Key Interview Discussion Points

