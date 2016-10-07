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
* **Flexible test environment setup**: setting up an ideal test environments on premise is not always possible due to various factors including setup cost. On public clouds, you may spin up and shut down when done servers and mobile devices of differing architectures and OSes in whatever quantity required. 

Beaver leverages a recent addition to the offerings of popular public cloud providers, the serverless architecture. AWS Lambda, Azure Functions, and Google Cloud Functions are all products for enabling the serverless architecture. In the architecture, you do not pay while your system is just on standby. Pay only when something is in progress. Also, you only provide codes to run in response to external requests and public cloud providers ensure them up instead of you. 

Upon receiving events from outside, Beaver spins up virtual machines in public clouds for performing builds and tests, and shuts them down when done. Since some public clouds meter the usage of virtual machines in minutes, the cost involved can be extremely minimized.

### Flexible
In today's standard, a simple flat CI/CD pipeline of cloning a single source code repository, building it, running tests on single environment, and uploading single artifact produced by the previous step to a server is no longer enough. For example, a software may involve multiple source repositories, require tests on more than one CPU architectures, and must be packaged for differnt OSes and package managers.

Beaver is designed to make construction of flexible pipelines possible. It supports event types other than source code changes such as periodic triggers and changes in the language runtime. And execution of tasks can be ochestrated with conditionals, sequential and parallel combinators over multiple source code repositories in a project.

### Extensible
Beaver is designed to be extensible. The extensibility also comes with reusability. Other CI systems rely on shell scripts in describing jobs to be done and don't provide a means to create and share with other users reusable packages of codes that extend various aspects of the CI systems.

Beaver is different in that regard, since it is written and designed to be extended in high level languages including Dart instead of shell scripts. So extensions can manage its external dependencies such as external libraries, and shared on a package server for other users both within and outside your organization.

