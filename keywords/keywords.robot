*** Settings ***
Library           ../library_files/docker_api.py
Library           ../library_files/netconf_api.py
Variables         ../library_files/constants.py
Library           XML

*** Keywords ***
Start BAA Containers
    [Documentation]    Keyword to start BAA docker containers using docker-compose file
    [Timeout]    10 minutes
    pull_simulator_images
    ${isDockerStarted}    start_dockers
    Should Be True    ${isDockerStarted}
    Wait Until Keyword Succeeds    4m    20s    send_baa_request    get    get-all-adapters.xml
    ${getAdaptersResponse}    send_baa_request    get    get-all-adapters.xml
    Element Text Should Be    ${getAdaptersResponse}    12    data/network-manager/device-adapters/device-adapter-count

Stop BAA Containers
    [Documentation]    Keyword to stop BAA docker containers using docker-compose file
    [Timeout]    5 minutes
    ${isDockerStopped}    stop_dockers
    Should Be True    ${isDockerStopped}
    remove_baa_stores

Check Device Alignment Status
    [Arguments]    ${deviceName}    ${connectionStatus}=${CONNECTED_TRUE}    ${alignmentStatus}=${ALIGNED}
    [Documentation]    Keyword to check the Device's alignment and connectivity status
    [Timeout]    2 minutes
    &{alignmentArgs} =    Create Dictionary    deviceName=${deviceName}
    ${alignmentResponse}    send_baa_request    get    get-device-alignment-status.xml    ${alignmentArgs}
    Element Text Should Be    ${alignmentResponse}    ${connectionStatus}    data/network-manager/managed-devices/device/device-management/device-state/connection-state/connected
    Element Text Should Be    ${alignmentResponse}    ${alignmentStatus}    data/network-manager/managed-devices/device/device-management/device-state/configuration-alignment-state

Delete device from BAA
    [Arguments]    ${deviceName}
    [Documentation]    Keyword to delete a given device from BAA
    [Timeout]    2 minutes
    &{args} =    Create Dictionary    deviceName=${deviceName}
    ${deleteResponse}    send_baa_request    edit-config    delete-device.xml    ${args}
    Element Should Exist    ${deleteResponse}    ${OK_RESPONSE}
    ${getResponse}    send_baa_request    get    get-all-devices.xml
    Should Not Contain    ${getResponse}    <baa-network-manager:name>${deviceName}</baa-network-manager:name>

Reset device simulator
    [Arguments]    ${deviceName}=${OLT_NAME}    ${simulatorName}=${POLT_CONTAINER_NAME}
    [Documentation]    KW to reset the pOLT simulator
    ...
    ...    - Delete Device from BAA
    ...    - Delete polt-simulator docker container
    ...    - Start the polt-simulator container
    [Timeout]    5 minutes
    Delete device from BAA    ${deviceName}
    remove_docker    ${simulatorName}
    Start BAA Containers

Send pOLT CLI Command and Verify Response
    [Arguments]    ${cliCommand}
    [Timeout]    5 minutes
    ${isSuccess}    send_polt_cli_command    ${cliCommand}
    Should Be True    ${isSuccess}
