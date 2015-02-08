#!/bin/bash

#########################################
##                                     ##
## Creates Demo Project Automagically! ##
##                                     ##
#########################################

# no args need to show help.
if [ $# -ne 1 ]
then
	echo Usage: 
	echo
	echo "     `basename $0` projectname"
	echo
	exit 
fi

# create project directory.
echo
echo "Created project directory."
echo
mkdir $1
cd $1

echo 
echo "Adding main readme file."
echo

echo "JBoss $1 Quickstart Guide
============================================================
Demo based on JBoss [product-name] products.

Setup and Configuration
-----------------------
See docs directory for details on this project.

For those that can't wait, see README in 'installs' directory, add products, 
run 'init.sh' and follow the instructions given.

[insert-quickstart-steps]


Supporting articles
-------------------
None yet...


Released versions
-----------------
See the tagged releases for the following versions of the product:
" > README.md

# create dirs.
echo
echo "Creating installs directory and readme."
echo
mkdir installs 
echo 'In this directory you fill in this readme file to point the user
to any software needed to run your demo. See below for example of 
what you will find for our current JBoss product demos.

The init scripts that install your project will be looking in this
directory for software that might be needed to install for your project
to run on.

=======================================================
Download the following from the JBoss Customer Portal

* [insert-product] ([insert-product-file].zip)

and copy to this directory for the init.sh script to work.

Ensure that this file is executable by running:

chmod +x <path-to-project>/installs/[insert-product-file].zip
=======================================================
' > installs/README

echo
echo "Creating projects directory and readme."
echo
mkdir projects
echo 'This directory is for putting your projects source code into. The install script 
will then be pointed here to do any builds, copy of built source binaries to an 
installed product server, etc.

Most often in JBoss demo projects, the web applications, web services, and other
client jars will be created here in a maven project. After building the JAR / WAR
would be copied into the JBoss application server.
' > projects/README

echo
echo "Creating support files directory and readme."
echo
mkdir support
echo 'Everything not held in the projects, installs, docs or root of your project 
goes in here... everything means everything... even if it is needed at some point 
to run from the root level of your project, have the init.sh automate it.

Very important to keep the root of the template clean and consistent.
' > support/README

echo
echo "Creating documentation files directory and readme."
echo
mkdir -p docs/demo-images
echo 'This directory contains any project documentation and you can place images
of screenshots into the demo-images directory. We often link the images into our
root level Readme.md for nice visual displays on github.com.
' > docs/README

echo 
echo "Creating various .gitignores."
echo
echo 'target/
.DS_Store
' > .gitignore
echo '.zip' > installs/.gitignore
echo '.metadata' > projects/.gitignore

echo 
echo "Create example inital init.sh for installation of the project."
echo
echo '#!/bin/sh 
# This is a generated example init for your project, just adjust as needed
# for your needs. It is not a complete setup but parts that give you a few
# hints on how to install a product, build a project and install it on the
# application server (java project).
#
# This same principle can be applied to any language project, the point is
# to keep it simple and clean (KISS). 
#
# Note everything is installed into the target directory, so now that we
# have an easily repeatable installation of your project, you can throw away
# the target directory at any time and run your init.sh to start over!
#

DEMO="YOUR-PROJECT-NAME-HERE"
AUTHORS="YOUR-NAME-HERE"
PROJECT="YOUR-GIT-URL-HERE"
PRODUCT="JBoss BPM Suite"
JBOSS_HOME=./target/jboss-eap-6.1
SERVER_DIR=$JBOSS_HOME/standalone/deployments/
SERVER_CONF=$JBOSS_HOME/standalone/configuration/
SERVER_BIN=$JBOSS_HOME/bin
SRC_DIR=./installs
SUPPORT_DIR=./support
PRJ_DIR=./projects
BPMS=jboss-bpms-installer-6.0.3.GA-redhat-1.jar
VERSION=6.0.3

# wipe screen.
clear 

echo
echo "##################################################################"
echo "##                                                              ##"   
echo "##  Setting up the ${DEMO}                           ##"
echo "##                                                              ##"   
echo "##                                                              ##"   
echo "##     ####  ####   #   #      ### #   # ##### ##### #####      ##"
echo "##     #   # #   # # # # #    #    #   #   #     #   #          ##"
echo "##     ####  ####  #  #  #     ##  #   #   #     #   ###        ##"
echo "##     #   # #     #     #       # #   #   #     #   #          ##"
echo "##     ####  #     #     #    ###  ##### #####   #   #####      ##"
echo "##                                                              ##"   
echo "##                                                              ##"   
echo "##  brought to you by,                                          ##"   
echo "##                     ${AUTHORS}          ##"
echo "##                                                              ##"   
echo "##  ${PROJECT} ##"
echo "##                                                              ##"   
echo "##################################################################"
echo

command -v mvn -q >/dev/null 2>&1 || { echo >&2 "Maven is required but not installed yet... aborting."; exit 1; }

# make some checks first before proceeding.	
if [ -r $SRC_DIR/$BPMS ] || [ -L $SRC_DIR/$BPMS ]; then
	echo Product sources are present...
	echo
else
	echo Need to download $BPMS package from the Customer Portal 
	echo and place it in the $SRC_DIR directory to proceed...
	echo
	exit
fi

# Move the old JBoss instance, if it exists, to the OLD position.
if [ -x $JBOSS_HOME ]; then
	echo "  - existing JBoss product install removed..."
	echo
	rm -rf target
fi

# Run installer.
echo Product installer running now...
echo
java -jar $SRC_DIR/$BPMS $SUPPORT_DIR/installation-bpms -variablefile $SUPPORT_DIR/installation-bpms.variables

if [ $? -ne 0 ]; then
	echo Error occurred during $PRODUCT installation!
	exit
fi

echo "  - setting up web services..."
echo
mvn clean install -f $PRJ_DIR/pom.xml
cp -r $PRJ_DIR/acme-demo-flight-service/target/acme-flight-service-1.0.war $SERVER_DIR
cp -r $PRJ_DIR/acme-demo-hotel-service/target/acme-hotel-service-1.0.war $SERVER_DIR

echo
echo "========================================================================"
echo "=                                                                      ="
echo "=  You can now start the $PRODUCT with:                         ="
echo "=                                                                      ="
echo "=   $SERVER_BIN/standalone.sh                           ="
echo "=                                                                      ="
echo "=  Login into business central at:                                     ="
echo "=                                                                      ="
echo "=    http://localhost:8080/business-central  (u:erics / p:bpmsuite1!)  ="
echo "=                                                                      ="
echo "=  See README.md for general details to run the various demo cases.    ="
echo "=                                                                      ="
echo "=  $PRODUCT $VERSION $DEMO Setup Complete.            ="
echo "=                                                                      ="
echo "========================================================================"

echo' > init.sh

echo
echo You can new view your project directory setup in $1.
echo