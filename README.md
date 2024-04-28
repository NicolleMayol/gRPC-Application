# Prueba técnica Rol de DevOps

## Table of Contents

- [About](#about)
- [Getting Started](#getting_started)
- [Usage](#usage)
- [Contributing](../CONTRIBUTING.md)

## About <a name = "about"></a>

Write about 1-2 paragraphs describing the purpose of your project.

## Getting Started <a name = "getting_started"></a>

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See [deployment](#deployment) for notes on how to deploy the project on a live system.

### Prerequisites

What things you need to install the software and how to install them.

```
Give examples
```

### Installing

A step by step series of examples that tell you how to get a development env running.

Say what the step will be

```
Give the example
```

And repeat

```
until finished
```

End with an example of getting some data out of the system or using it for a little demo.


## Infrastructure

<img src='./img/diagram.jpg'>

### Networking

The project infrastructure is built on Amazon Web Services (AWS) and consists of the following components:

#### Virtual Private Cloud (VPC):
Provides isolated networking environment for our resources.
* CIDR Block: 10.0.0.0/16
#### Subnets:
`Public Subnets:`
Hosts resources accessible from the internet.
* CIDR Blocks: 10.0.3.0/24, 10.0.4.0/24

`Private Subnet:`
Hosts resources that require internal communication only.
* CIDR Block: 10.0.2.0/24
#### Internet Gateway (IGW):
Facilitates internet connectivity for resources in public subnets.
* Route Tables:
    * Public Route Table:
            Routes internet-bound traffic to the IGW.
#### Security Groups:
* Allow All:
    Controls inbound and outbound traffic for resources.
#### Amazon EKS Cluster:
Managed Kubernetes service for containerized applications.
* Cluster Name: simetrik-cluster
* Version: 1.24
#### Application Ingress (ALB):
Acts as the entry point for incoming traffic to our application.
Listens on port 50051 and routes traffic to the EKS cluster.
#### CI/CD Pipeline (AWS CodeBuild):
Automates the build and deployment process of the application to the EKS cluster.
Integrates with the version control system (CodeCommit)
Automates the deployment process of the infrastructure 

## Usage <a name = "usage"></a>

Add notes about how to use the system.
