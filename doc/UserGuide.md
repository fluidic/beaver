# Beaver CI User Guide
## Overview
Beaver is a continuous integration and delivery (CI/CD) system. CI is a practice of integrating changes in a software frequently possibly performing build and test on every change or commit. And CD is to ensure that a software is deliverable at any time in doing so. A CI/CD system assists implementation of such a practice by performing automated build, test, and deployment of software in response to various events including code changes.

## Why Beaver?
Beaver is different from other CI/CD systems in the following aspects:
* Cloud native
* Flexible
* Extensible

### Cloud Native
CI/CD is by nature a good fit for public cloud.

* **Low cost**: A CI/CD system is most of time just on standbye without performing any useful work. Dedicating machines to CI/CD is almost always a waste of the resources due to such underutilization. On public clouds, you only pay the resource you used.
* **Low maintenance burden**: A CI/CD system is usually not a core competency of any development, but must be kept up not to hinder development. In public clouds, there are many managed components that are required to implement a CI/CD system, such as database, storage, and web server, and Beaver is designed to leverage them from the start.
* **Flexible test environment setup**: setting up an ideal test environments on premise is not always possible due to various factors including setup cost and space requirement. On public clouds, you may spin up and shut down when done servers and mobile devices of required settings in whatever quantity required. 

Beaver leverages a recent addition to the offerings of popular public cloud providers, the serverless architecture. AWS Lambda, Azure Functions, and Google Cloud Functions are all products for enabling the serverless architecture. In such an architecture, you do not pay while your system is just on standby. Also, you only provide codes to run in response to external requests and public cloud providers ensure them up instead of you. 

Upon receiving events from outside, Beaver spins up virtual machines in public clouds for performing builds and tests, and shuts them down when done. Since some public clouds meter the usage of virtual machines in minutes, the virtual machines are efficiently operated.

### Flexible
 