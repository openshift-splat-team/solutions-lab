# OpenShift Solutions Lab

This repository provides a reference implementation for specific OpenShift solutions to customers and partners. 

# How this works?

Executing the ```run-all.sh``` script will run all test cases defined in the ```test-cases```. Each test case is a directory containing the configuration templates and scripts to execute it. For each case, the script will generate the configuration text files, execute hooks, create cluster, run test, and finally dispose of resources. 

In the ```cases-lib``` directory you will find examples demonstrating specific scenarios, such as different cloud providers, infrastructure tools, operators selection, and general configuration.


# Features

## Done
* Provision clusters, run tests and compare results
* Configuration text templates (envsubst)
* Cloud Development Environment (gitpod)
* Auto-download latest clients release (openshift-install, oc, ccoctl) 
* Optionally preserve clusters for post-mortem analysis

## TODO
* Provide hooks for custom infrastructure providers (CloudFormation, Terraform, CDK, ...)
