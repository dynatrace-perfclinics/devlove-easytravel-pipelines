node {
    properties([
        parameters([
         string(defaultValue: 'http://easytravel-dynatrace.com', description: 'URI of the EasyTravel Application you want to run a test against', name: 'DeploymentURI', trim: false),
        ])
    ])

    stage('Triggering a scheduled job') {

       def now = new Date()
       println(now.format("yyMMdd.HHmm", TimeZone.getTimeZone('UTC')))

       def t = Integer.parseInt(now.format("HH", TimeZone.getTimeZone('UTC')))

       println("And the number is: " + t.toString())

       //  0  1  2  3  4  5 
       //  6  7  8  9 10 11 
       // 12  13 14 15 16 17 
       // 18  19 20 21 22 23
       def problemPattern = "None"

       if ( t == 0 ||  t == 6 ||  t == 12 ||  t == 18 ){
          problemPattern = "None"
       } else if( t == 1 ||  t == 7 ||  t == 13 ||  t == 19 ){
          problemPattern = "CPULoadJourneyService"
       } else if( t == 2 ||  t == 8 ||  t == 14 ||  t == 20 ){
           problemPattern = "DBSpammingAuthWithAppDeployment"
       } else if( t == 3 ||  t == 9 ||  t == 15 ||  t == 21 ){
           problemPattern = "LoginProblems"
       } else if( t == 4 ||  t == 10 ||  t == 16 ||  t == 22 ){
           problemPattern = "JourneyUpdateSlow"
       } else if( t == 5 ||  t == 11 ||  t == 17 ||  t == 23 ){
           problemPattern = "CreditCardCheckError500"
       } else {
          problemPattern = "None"
       }

       println("And the problemPattern is:" + problemPattern)

       build(
             job: 'easytravel-continuous-deployment',
             parameters: [
               [ $class: 'StringParameterValue', name: 'EasyTravelDeployment',value: "${problemPattern}" ],
               [ $class: 'StringParameterValue', name: 'Project',value: "easytravel" ],
               [ $class: 'StringParameterValue', name: 'Stage',value: "integration" ],
               [ $class: 'StringParameterValue', name: 'Service',value: "frontend-classic" ],
               [ $class: 'StringParameterValue', name: 'TestStrategy',value: "performance_10" ],
               [ $class: 'StringParameterValue', name: 'DeploymentURI',value: "${params.DeploymentURI}" ]
             ],
            )
    }
}

