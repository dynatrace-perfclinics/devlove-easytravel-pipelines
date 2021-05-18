@Library('keptn-library')_

//import sh.keptn.*
//keptn = Keptn.instance
def keptn = new sh.keptn.Keptn()


node {
    try {

        properties([
            parameters([
            choice(choices: ['None', 'CPULoadJourneyService', 'DBSpammingAuthWithAppDeployment', 'LoginProblems', 'JourneyUpdateSlow', 'CreditCardCheckError500'], description: 'Name of the Deployment (Bug) in Easytravel to enable', name: 'EasyTravelDeployment', trim: false), 
            string(defaultValue: 'easytravel', description: 'Name of your Keptn Project for Performance as a Self-Service', name: 'Project', trim: false), 
            string(defaultValue: 'staging', description: 'Stage in your Keptn project used for Performance Feedback', name: 'Stage', trim: false), 
            string(defaultValue: 'classic-eval', description: 'Servicename (tag) used to keep SLIs, SLOs, test files ...(in Classic ET is the easyTravel Customer Frontend', name: 'Service', trim: false),
            choice(choices: ['performance', 'performance_10', 'performance_50', 'performance_100', 'performance_long'], description: 'Test Strategy aka Workload, e.g: performance, performance_10, performance_50, performance_100, performance_long', name: 'TestStrategy', trim: false),
            string(defaultValue: 'easytravel-public-ip.nip.io', description: 'Magic Domain of the EasyTravel Application you want to run a test against, example 10.12.34.123.nip.io. The REST endpoint and EasyTravel Classic application will be accessed via subdomains e.g. http://rest.10.12.34.123.nip.io ', name: 'DeploymentURI', trim: false),
            string(defaultValue: '60', description: 'How many minutes to wait until Keptn is done? 0 to not wait', name: 'WaitForResult'),
            ])
        ])

        stage('Deploy EasyTravel Change') {

            //TODO Push Deployment Event to Dynatrace?
            def response = httpRequest url: "http://rest.${params.DeploymentURI}/services/ConfigurationService/setPluginEnabled?name=${params.EasyTravelDeployment}&enabled=true",
                httpMode: 'GET',
                timeout: 5,
                validResponseCodes: "202"

            println("Status: "+response.status)
            println("Content: "+response.content)
            /*
            More about EasyTravel problems
            https://community.dynatrace.com/community/pages/viewpage.action?title=Available+easyTravel+Problem+Patterns&spaceKey=DL        
            */
        }

        stage('Initialize Keptn') {

            // Only Upload files if Project, Stage and Service exists, otherwise we give the customer the chance to modify them directly in GitOps.
            echo "Evaluating if Project.Stage.Service is availbale on Keptn, if not it will be created and the ressources will be uploaded."
            def exists = keptn.keptnProjectServiceExists project:"${params.Project}", service:"${params.Service}", stage:"${params.Stage}", keptn_endpoint: env.KEPTN_ENDPOINT, keptn_api_token:env.KEPTN_API_TOKEN 

            if (exists) {
                echo "Project.Stage.Service already available in Keptn. No further action required!"
            } else {
                echo "Project.Stage.Service not available in Keptn. Further action required! Setting up the Project.Stage.Service"
                echo "Initialize Keptn and upload SLI,SLO and JMeter files from Github https://github.com/dynatrace-perfclinics/devlove-easytravel-pipelines/"
                keptn.downloadFile("https://raw.githubusercontent.com/dynatrace-perfclinics/devlove-easytravel-pipelines/master/keptn/shipyard.yaml", 'keptn/shipyard.yaml')
                keptn.downloadFile("https://raw.githubusercontent.com/dynatrace-perfclinics/devlove-easytravel-pipelines/master/keptn/dynatrace.conf.yaml", 'keptn/dynatrace.conf.yaml')
                keptn.downloadFile("https://raw.githubusercontent.com/dynatrace-perfclinics/devlove-easytravel-pipelines/master/keptn/slo.yaml", 'keptn/slo.yaml')
                keptn.downloadFile("https://raw.githubusercontent.com/dynatrace-perfclinics/devlove-easytravel-pipelines/master/keptn/sli.yaml", 'keptn/sli.yaml')
                keptn.downloadFile('https://raw.githubusercontent.com/dynatrace-perfclinics/devlove-easytravel-pipelines/master/keptn/jmeter/easytravel-classic-random-book.jmx', 'keptn/jmeter/easytravel-classic-random-book.jmx')
                keptn.downloadFile('https://raw.githubusercontent.com/dynatrace-perfclinics/devlove-easytravel-pipelines/master/keptn/jmeter/jmeter.conf.yaml', 'keptn/jmeter/jmeter.conf.yaml')

                //keptn.downloadFile('https://raw.githubusercontent.com/dynatrace-perfclinics/devlove-easytravel-pipelines/master/keptn/jmeter/easytravel-users.txt', 'keptn/jmeter/easytravel-users.txt')
                archiveArtifacts artifacts:'keptn/**/*.*'

                // Initialize the Keptn Project
                keptn.keptnInit project:"${params.Project}", service:"${params.Service}", stage:"${params.Stage}", monitoring:"dynatrace" , shipyard:'keptn/shipyard.yaml'

                // Upload all the files
                keptn.keptnAddResources('keptn/shipyard.yaml','shipyard.yaml')
                keptn.keptnAddResources('keptn/dynatrace.conf.yaml','dynatrace/dynatrace.conf.yaml')
                keptn.keptnAddResources('keptn/sli.yaml','dynatrace/sli.yaml')
                keptn.keptnAddResources('keptn/slo.yaml','slo.yaml')
                keptn.keptnAddResources('keptn/jmeter/easytravel-classic-random-book.jmx','jmeter/easytravel-classic-random-book.jmx')
                keptn.keptnAddResources('keptn/jmeter/jmeter.conf.yaml','jmeter/jmeter.conf.yaml')
                //keptn.keptnAddResources('keptn/jmeter/easytravel-users.txt','jmeter/easytravel-users.txt')
                //TODO How to add ressources to loadtest?
                //https://github.com/keptn/enhancement-proposals/issues/21
            }
        }

        stage('Trigger Performance Test') {
            echo "Performance as a Self-Service: Triggering Keptn to execute Tests against http://classic.${params.DeploymentURI}"

            // send deployment finished to trigger tests
            //TODO Remove port due bug in 0.8
            //https://github.com/keptn/keptn/issues/3916
            def keptnContext = sendConfigurationTriggeredEventEasyTravel testStrategy:"${params.TestStrategy}", deploymentURI:"http://classic.${params.DeploymentURI}:80" , problemPattern:"${params.EasyTravelDeployment}"
            // sendConfigurationTriggeredEvent
            String keptn_bridge = env.KEPTN_BRIDGE
            echo "Open Keptns Bridge: ${keptn_bridge}/trace/${keptnContext}"
        }

        stage('Wait for evaluation result') {
            waitTime = 0
            if(params.WaitForResult?.isInteger()) {
                waitTime = params.WaitForResult.toInteger()
            }

            if(waitTime > 0) {
                echo "Waiting until Keptn is done and returns the results"
                def result = keptn.waitForEvaluationDoneEvent setBuildResult:true, waitTime:waitTime
                echo "${result}"
            } else {
                echo "Not waiting for results. Please check the Keptns bridge for the details!"
            }

            // Generating the Report so you can access the results directly in Keptns Bridge
            publishHTML(
                target: [
                    allowMissing         : false,
                    alwaysLinkToLastBuild: false,
                    keepAll              : true,
                    reportDir            : ".",
                    reportFiles          : 'keptn.html',
                    reportName           : "Keptn Result in Bridge"
                ]
            )
        }
        stage('Rollback EasyTravel Deployment Change') {

            def response = httpRequest url: "http://rest.${params.DeploymentURI}/services/ConfigurationService/setPluginEnabled?name=${params.EasyTravelDeployment}&enabled=false",
                httpMode: 'GET',
                validResponseCodes: "202",
                timeout: 5
            
            println("Status: "+response.status)
            println("Content: "+response.content)
        }

    } catch (e) {
        echo 'The new deployment failed, we do the needed action here'
        // Since we're catching the exception in order to report on it,

        throw e
        // we need to re-throw it, to ensure that the build is marked as failed
   } finally {

    def currentResult = currentBuild.result ?: 'SUCCESS'
    if (currentResult == 'UNSTABLE') {
        echo 'This will run only if the run was marked as unstable'
    }

    echo 'Rolling back the Problempattern regardless of the result'
    def response = httpRequest url: "http://rest.${params.DeploymentURI}/services/ConfigurationService/setPluginEnabled?name=${params.EasyTravelDeployment}&enabled=false",
    httpMode: 'GET',
    validResponseCodes: "202",
    timeout: 5
    println("Status: "+response.status)
    println("Content: "+response.content)

 }
}


/**
 * sendConfigurationTriggeredEvent(project, stage, service, image, [labels, keptn_endpoint, keptn_api_token])
 * Example: sendConfigurationTriggeredEvent
 * Will trigger a full delivery workflow in keptn!
 * changed to delivery.triggered for keptn 0.8.0
 */
def sendConfigurationTriggeredEventEasyTravel(Map args) {
    //def keptnInit = keptnLoadFromInit(args)
    def keptn = new sh.keptn.Keptn()
    def keptnInit = keptn.keptnLoadFromInit(args)

    /* String project, String stage, String service, String deploymentURI, String testStrategy */
    String keptn_endpoint = args.containsKey('keptn_endpoint') ? args.keptn_endpoint : env.KEPTN_ENDPOINT
    String keptn_api_token = args.containsKey('keptn_api_token') ? args.keptn_api_token : env.KEPTN_API_TOKEN

    def labels = args.containsKey('labels') ? args.labels : [:]

    String project = keptnInit['project']
    String stage = keptnInit['stage']
    String service = keptnInit['service']
    String deploymentURI = args.containsKey("deploymentURI") ? args.deploymentURI : ""
    String testStrategy = args.containsKey("testStrategy") ? args.testStrategy : ""
    String problemPattern = args.containsKey('problemPattern') ? args.problemPattern : ''    
    String image = "easytravel.${problemPattern}"
    String tag = args.containsKey("tag") ? args.tag : "${BUILD_NUMBER}"

    echo "Sending a Configuration triggered event to Keptn for ${project}.${stage}.${service}"
    
    def requestBody = """{
        |  "data": {
        |    "project": "${project}",
        |    "service": "${service}",
        |    "stage": "${stage}",
        |    "image" : "${image}",
        |    "teststrategy": "${testStrategy}",
        |    "configurationChange": {
        |      "values": {
        |      "deploymentURIsPublic": "${deploymentURI}",
        |      "teststrategy": "${testStrategy}"
        |      }
        |    },
        |    "deployment": {
        |      "deploymentstrategy": "direct",
        |      "deploymentURIsPublic": [
        |                "${deploymentURI}"
        |             ]        
        |    },
        |    "labels": {
        |      "buildId" : "${problemPattern}.${tag}",
        |      "jobname" : "${JOB_NAME}",
        |      "buildNumber": "${BUILD_NUMBER}",
        |      "joburl" : "${BUILD_URL}",
        |      "problemPattern" : "${problemPattern}"
        |    }
        |  },
        |  "datacontenttype": "application/json",
        |  "source": "jenkins-library",
        |  "specversion": "1.0",
        |  "type": "sh.keptn.event.${stage}.delivery.triggered"
        |}
    """.stripMargin()

    echo requestBody

    // lets add our custom labels
    requestBody = keptn.addCustomLabels(requestBody, labels)
   
    echo requestBody

    def response = httpRequest contentType: 'APPLICATION_JSON', 
      customHeaders: [[maskValue: true, name: 'x-token', value: "${keptn_api_token}"]], 
      httpMode: 'POST', 
      requestBody: requestBody, 
      responseHandle: 'STRING', 
      url: "${keptn_endpoint}/v1/event", 
      validResponseCodes: "100:404", 
      ignoreSslErrors: true

    // write response to keptn.context.json & add to artifacts
    def keptnContext = keptn.writeKeptnContextFiles(response)
    
    return keptnContext
}