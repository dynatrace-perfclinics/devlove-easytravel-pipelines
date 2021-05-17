# EasyTravel Site Reliable Engineering

In this repo you'll find the ressources needed to create an endless CI/CD Jenkins pipeline that triggers deployments (aka ProblemPatterns) for EasyTravel. Jenkins will then notify Keptn with a cloud event and Keptn will start a JMeter Web-Sessionbased Loadtest (full booking procedure). All Steps, Tests and transactions (end-end) are automatically recorded in Dynatrace. Keptn will then fetch the SLI/SLOs via the lighthouse service and evaluate the deployment comparing the actual results with the defined SLO and the previous builds.

With Dynatrace you can on real time analyze and compare Loadtests of different builds. Analyze the GarbaceCollection impact of deployments. Check the Memory Allocation and see which Objects are surviving and which classes are allocated in memory and can't be collected. Do a Thread analysis and find out blocking threads during loadtests. Also analyze the CPU impact of bad code pointing to the imperformant code automatically. 


### Files overview 

The `jmeter` directory contains loadtesting files which are independent of the pipeline. All pipeline files (gitOps) are under the `keptn` directory.

```bash
jmeter
 ├── easytravel-angular
 │   └── easytravel-angular-booking.jmx           JMX File (Loadtest) Full booking process for EasyTravel Angular 
 └── easytravel_classic
    ├── easytravel-classic-random-book.jmx        JMX File (Loadtest) Full booking process for EasyTravel Classic
    ├── easytravel-kata-basics.jmx                JMX File (Loadtest) simplee booking process for EasyTravel Classic
    └── easytravel-users.txt                      File with username/passwords. 

keptn
 ├── dynatrace.conf.yaml                                     dynatrace service provider configuration for Keptn
 ├── easytravel-performancetest-qualitygate.Jenkinsfile      Jenkins deployment Pipeline for EasyTravel
 ├── easytravel-scheduler.Jenkinsfile                        Jenkins scheduler for the deployment pipeline
 ├── helm-jenkins.yaml                                       Helm configuration as code for the Jenkins instance
 ├── jmeter
 │   ├── easytravel-classic-random-book.jmx                  JMX File (Loadtest) Full booking process for EasyTravel Classic
 │   ├── easytravel-users.txt                                File with username/passwords.
 │   └── jmeter.conf.yaml                                    JMeter configuration for Keptn
 ├── sli.yaml                                                SLI definitions for the project   
 └── slo.yaml                                                SLO definitions for the project   

 deployment_schedule.md                                      Overview of the deployment schedule for easytravel CET.
```


