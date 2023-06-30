*** Settings ***
Suite Setup       Start BAA Containers
Suite Teardown    Stop BAA Containers
Force Tags        Sanity
Resource          ../../keywords/keywords.robot
Library           XML
*** Test Cases ***
Verify Management of multiple vONU with 2 vOMCI Function using BAA
    [Documentation]    Author : Pradeep
    ...    Verify Management of multiple vONU with 2 vOMCI Function using BAA
    ...    Start containers with the docker-compose file in attachment
    ...    1- 1-create-olt.xml
    ...    2- Wait for alignment
    ...    3- 2-create-infra-std-2.1.xml
    ...    4- Wait for alignment
    ...    5- 3-grpc-settings-olt.xml
    ...    6- Wait for alignment and hello received in vOMCI proxy logs
    ...    7- 5-network-functions.xml
    ...    8- Wait for copy config in vomci logs and vOMCI, vOMCI2 and vProxy gets aligned.
    ...    9- 6-configure-vProxy-with-new-endpoint.xml
    ...    10- Wait for vProxy gets aligned.
    ...    11- 7-create-onu2-use-vomci2.xml
    ...    12- 8-configure-onu2-std-1.0.xml
    ...    13- Connect ONU simulator pOLT simulator rest
    ...    14- 9- Trigger the ONU state change notification using pOLT simulator rest
    ...    15- Wait for the onu2 to be connected and aligned. 9-get-alignment-status-onu2.xml
    ...    16- 11-get-onu2-Device-Status.xml get ont2 device details
    ...    17- create-onu1-use-vomci.xml
    ...    18- 13-configure-onu1-std-1.0.xml
    ...    19- Trigger the ONU state change notification using pOLT simulator rest
    ...    20- Wait for the onu1 to be connected and aligned.17-get-alignment-status-onu1.xml
    ...    21- 16-get-onu1-Device-Status.xml get ont1 device details
    ...    22- Wait for the onu1 to be connected and aligned.
    ...    23- 10-get-onu2-Device-Status.xml get ont2 device details.
    ...    24- create-onu4-use-vomci2.xml
    ...    25- 20-configure-onu4-std-1.0.xml
    ...    26- Trigger the ONU state change notification using pOLT simulator rest
    ...    27- Wait for the onu4 to be connected and aligned.
    ...    28- 23-get-alignment-status-onu4.xml
    ...    29- 24-get-onu2-Device-Status.xml get ont4 device details.
    [Tags]    vONU
    [Timeout]    20 minutes
    #    1-create-olt.xml    and    wait for alignment
    &{args} =    Create Dictionary    deviceName=OLT1    version=2.1    ipAddress=${POLT_SIM_IP}    port=${POLT_SIM_PORT}    userName=${POLT_SIM_USER}    password=${POLT_SIM_PASSWORD}
    ${response}    Send Baa Request    edit-config    create-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT1
    #    2-create-infra-std-2.1.xml and    Wait for alignment
    &{args} =    Create Dictionary    deviceName=OLT1
    ${response}    Send Baa Request    edit-config    create-infra-std-2.1.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT1
    &{args} =    Create Dictionary    deviceName=OLT1    vproxy=obbaa-vproxy
    ${response}    Send Baa Request    edit-config    grpc-settings-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT1
    ${response}    Send Baa Request    edit-config    network-functions2.xml
    Element Should Exist    ${response}    ${OK_RESPONSE}
    BuiltIn.Sleep    2m
    ${response}    Send Baa Request    edit-config    configure-vproxy.xml
    Element Should Exist    ${response}    ${OK_RESPONSE}
    BuiltIn.Sleep    2m
    &{args} =    Create Dictionary    oltName=OLT1    ontName=ont2    expectedSerialNumber=ABCD23456789    nfName=bbf-vomci2    vomci_gRPC=vOMCi-grpc-2    proxy_gRPC=proxy-grpc-3
    ${response}    send_baa_request    edit-config    create-onu-use-vomci.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    &{args} =    Create Dictionary    ontName=ont2
    ${response}    send_baa_request    edit-config    configure-onu-std-1.0.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    ${requestBody} =    Compose REST Request Body    action=RxMODE
    Send pOLT CLI Command and Verify Response    ${requestBody}
    ${requestBody} =    Compose REST Request Body    action=ADDONU    onu_id=2    serial_vendor_specific=23456789
    Send pOLT CLI Command and Verify Response    ${requestBody}
    BuiltIn.Sleep    1m
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    ont2
    Comment    BuiltIn.Sleep    10s
    Comment    &{args} =    Create Dictionary    deviceName=ont2
    Comment    ${getResponse}    send_baa_request    get    get-device-data.xml    ${args}
    Comment    Element Text Should Be    ${getResponse}    ont2 xpath=data/hardware[1]/component/name
    Comment    Element Text Should Be    ${getResponse}    enet_uni_ont2_1_1 xpath=data/interfaces-state/interface[1]/name
    Comment    Element Text Should Be    ${getResponse}    ontUni_ont2_1_1 xpath=data/interfaces-state/interface[1]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[1]/type
    Comment    Element Text Should Be    ${getResponse}    uni2_ont2 xpath=data/interfaces-state/interface[2]/name
    Comment    Element Text Should Be    ${getResponse}    port_uni2_ont2 xpath=data/interfaces-state/interface[2]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[2]/type
    Comment    Element Text Should Be    ${getResponse}    ontAni_ont2 xpath=data/interfaces-state/interface[3]/name
    Comment    Element Text Should Be    ${getResponse}    bbf-xponift:ani xpath=data/interfaces-state/interface[3]/type
    &{args} =    Create Dictionary    oltName=OLT1    ontName=ont1    expectedSerialNumber=ABCD12345678    nfName=bbf-vomci    vomci_gRPC=vOMCi-grpc-1    proxy_gRPC=proxy-grpc-1
    ${response}    send_baa_request    edit-config    create-onu-use-vomci.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    &{args} =    Create Dictionary    ontName=ont1
    ${response}    send_baa_request    edit-config    configure-onu-std-1.0.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    ${requestBody} =    Compose REST Request Body    action=ADDONU    onu_id=1    serial_vendor_specific=12345678
    Send pOLT CLI Command and Verify Response    ${requestBody}
    BuiltIn.Sleep    1m
    Wait Until Keyword Succeeds    2m    10s    Check Device Alignment Status    ont1
    Comment    BuiltIn.Sleep    10s
    Comment    &{args} =    Create Dictionary    deviceName=ont1
    Comment    ${getResponse}    send_baa_request    get    get-device-data.xml    ${args}
    Comment    Element Text Should Be    ${getResponse}    ont1 xpath=data/hardware[1]/component/name
    Comment    Element Text Should Be    ${getResponse}    enet_uni_ont1_1_1 xpath=data/interfaces-state/interface[1]/name
    Comment    Element Text Should Be    ${getResponse}    ontUni_ont1_1_1 xpath=data/interfaces-state/interface[1]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[1]/type
    Comment    Element Text Should Be    ${getResponse}    uni2_ont1 xpath=data/interfaces-state/interface[2]/name
    Comment    Element Text Should Be    ${getResponse}    port_uni2_ont1 xpath=data/interfaces-state/interface[2]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[2]/type
    Comment    Element Text Should Be    ${getResponse}    ontAni_ont1 xpath=data/interfaces-state/interface[3]/name
    Comment    Element Text Should Be    ${getResponse}    bbf-xponift:ani xpath=data/interfaces-state/interface[3]/type
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    ont2
    Comment    BuiltIn.Sleep    10s
    Comment    &{args} =    Create Dictionary    deviceName=ont2
    Comment    ${getResponse}    send_baa_request    get    get-device-data.xml    ${args}
    Comment    Element Text Should Be    ${getResponse}    ont2 xpath=data/hardware[1]/component/name
    Comment    Element Text Should Be    ${getResponse}    enet_uni_ont2_1_1 xpath=data/interfaces-state/interface[1]/name
    Comment    Element Text Should Be    ${getResponse}    ontUni_ont2_1_1 xpath=data/interfaces-state/interface[1]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[1]/type
    Comment    Element Text Should Be    ${getResponse}    uni2_ont2 xpath=data/interfaces-state/interface[2]/name
    Comment    Element Text Should Be    ${getResponse}    port_uni2_ont2 xpath=data/interfaces-state/interface[2]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[2]/type
    Comment    Element Text Should Be    ${getResponse}    ontAni_ont2 xpath=data/interfaces-state/interface[3]/name
    Comment    Element Text Should Be    ${getResponse}    bbf-xponift:ani xpath=data/interfaces-state/interface[3]/type
    &{args} =    Create Dictionary    oltName=OLT1    ontName=ont4    expectedSerialNumber=ABCD45678900    nfName=bbf-vomci2    vomci_gRPC=vOMCi-grpc-2    proxy_gRPC=proxy-grpc-3
    ${response}    send_baa_request    edit-config    create-onu-use-vomci.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    &{args} =    Create Dictionary    ontName=ont4
    ${response}    send_baa_request    edit-config    configure-onu-std-1.0.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Send pOLT CLI Command and Verify Response    ${requestBody}
    ${requestBody} =    Compose REST Request Body    action=ADDONU    onu_id=4    serial_vendor_specific=45678900
    Send pOLT CLI Command and Verify Response    ${requestBody}
    BuiltIn.Sleep    1m
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    ont4
    Comment    BuiltIn.Sleep    10s
    Comment    &{args} =    Create Dictionary    deviceName=ont4
    Comment    ${getResponse}    send_baa_request    get    get-device-data.xml    ${args}
    Comment    Element Text Should Be    ${getResponse}    ont4 xpath=data/hardware[1]/component/name
    Comment    Element Text Should Be    ${getResponse}    enet_uni_ont4_1_1 xpath=data/interfaces-state/interface[1]/name
    Comment    Element Text Should Be    ${getResponse}    ontUni_ont4_1_1 xpath=data/interfaces-state/interface[1]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[1]/type
    Comment    Element Text Should Be    ${getResponse}    uni2_ont4 xpath=data/interfaces-state/interface[2]/name
    Comment    Element Text Should Be    ${getResponse}    port_uni2_ont4 xpath=data/interfaces-state/interface[2]/port-layer-if
    Comment    Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd xpath=data/interfaces-state/interface[2]/type
    Comment    Element Text Should Be    ${getResponse}    ontAni_ont4 xpath=data/interfaces-state/interface[3]/name
    Comment    Element Text Should Be    ${getResponse}    bbf-xponift:ani xpath=data/interfaces-state/interface[3]/type
    ${requestBody} =    Compose REST Request Body    action=REMOVEONU    onu_id=4    serial_vendor_specific=45678900
    Send pOLT CLI Command and Verify Response    ${requestBody}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    ont4    connectionStatus=${CONNECTED_FALSE}    alignmentStatus=${ALIGNMENT_UNKNOWN}
    Delete device from BAA    deviceName=ont4
    ${requestBody} =    Compose REST Request Body    action=REMOVEONU    onu_id=2    serial_vendor_specific=23456789
    Send pOLT CLI Command and Verify Response    ${requestBody}
    Wait Until Keyword Succeeds    2m    10s    Check Device Alignment Status    ont2    connectionStatus=${CONNECTED_FALSE}    alignmentStatus=${ALIGNMENT_UNKNOWN}
    Delete device from BAA     deviceName=ont2
    ${requestBody} =    Compose REST Request Body    action=REMOVEONU    onu_id=1    serial_vendor_specific=12345678
    Send pOLT CLI Command and Verify Response    ${requestBody}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    ont1    connectionStatus=${CONNECTED_FALSE}    alignmentStatus=${ALIGNMENT_UNKNOWN}
    [Teardown]    Run Keywords    Reset device simulator    deviceName=ont1    simulatorName=${ONU_SIMULATOR_NAME}
    ...    AND    Reset device simulator    deviceName=OLT1
