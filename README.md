# OB-BAA Test Automation
This repository contains the automated end-to-end test cases for the OB-BAA project

Here we use Robot Framework automation tool to automate OB-BAA test cases. More details about the automation framework can be found [here](https://robotframework.org/robotframework/4.1.2/RobotFrameworkUserGuide.html)

## Steps to Run Automated Tests Using Robot Framework
- Robot fwk and required tools must be installed (Look at the Robot Framework documentation for installation instructions)
- Checkout the obbaa-test-automation code "git clone https://github.com/BroadbandForum/obbaa-test-automation.git"
- Navigate to the obbaa-test-automation directory
- Run command **make run-robot-tests** (this command will trigger the robot framework, it will run all the tests under the folder ~/obbaa-test-automation/robot_test_cases/ in sequential order)
- At the end of the run, Results will be placed under ~/obbaa-test-automation/robot_test_results/
- We shall be able to check the logs by opening the log.html file from a web browser
- Run command **make run-tagged-tests tag=abc**(This command will run tests that has the tag named abc)

```
Note : 

1) By Default, the docker compose files will pull the develop branch images from(dockerHub). If we want to use the local images to run the tests, we must update the docker-compose file (~/obbaa-test-automation/data/compose_data/docker-compose.yaml) with right image tags and start the test

2) Whenever someone make any changes to the existing library files(~/obbaa-test-automation/library_files)/keywords(~/obbaa-test-automation/keywords) or add new files to the directories we must generate the documentation for the keywords.

3) Run Script mentioned below to generate documents(This step needs to be performed only if the lib files or keywords are updated)    
    
    Example:
    cd obbaa-test-automation/docs
    ~/obbaa-test-automation/docs$ ./generate_kw_docs.sh

4) If a new library file is added to the library_files/keywords directory, one must update the generate_kw_docs.sh script to include the newly added file.
```

## Keyword Documentation
Details about the pre-defined robot framework python keywords can be found below
- [docker_api](docs/docker_api.html)

- [netconf_api](docs/netconf_api.html)

- [user_keywords](docs/user_keywords.html)

```
Note : The mentioned HTML documentation pages appear better in web browsers. 
Open a web browser and view the required files after the code has already been checked out locally.
```
