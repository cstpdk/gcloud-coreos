#!/bin/bash

wget -q -O - http://pkg.jenkins-ci.org/debian/jenkins-ci.org.key | sudo apt-key add -

deb http://pkg.jenkins-ci.org/debian binary/

sudo apt-get update
sudo apt-get install jenkins
