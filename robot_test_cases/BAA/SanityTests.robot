*** Settings ***
Suite Setup       Start BAA Containers
Suite Teardown    Stop BAA Containers
Force Tags        Sanity
Resource          ../../keywords/keywords.robot
Library           XML
*** Test Cases ***
Verify vONU Management using BAA
    [Documentation]    Author : Pradeep
    ...
    ...    Verify vONU Management using BAA
    ...    1. Start containers with the docker-compose file in attachment
    ...    2. 1-create-olt.xml
    ...    3. Wait for alignment
    ...    4. 2-create-infra-std-2.1.xml
    ...    5. Wait for alignment
    ...    6. 3-grpc-settings-olt.xml
    ...    7. Wait for alignment and hello received in vOMCI proxy logs
    ...    8. 5-network-functions.xml
    ...    9. Wait for copy config in vomci logs
    ...    10. 6-create-onu-use-vomci.xml
    ...    11. 7-configure-onu-std-1.0.xml
    ...    12. Attach ONU Simulator to pOLT Simulator
    ...    13. Send PRESENT_AND_UNEXPECTED notification though OLT
    ...    14. Wait for alignment of onu
    ...    15. Send DELETE_ONU notification though OLT
    ...    16. Wait for alignment state of onu to be false.
    [Tags]    vONU
    [Timeout]    10 minutes
    # \ \ \ 1-create-olt.xml \ \ \ and \ \ \ wait for alignment
    &{args} =    Create Dictionary    deviceName=OLT1    version=2.1    ipAddress=${POLT_SIM_IP}    port=${POLT_SIM_PORT}    userName=${POLT_SIM_USER}    password=${POLT_SIM_PASSWORD}
    ${response}    Send Baa Request    edit-config    create-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT1
    # \ \ \ 2-create-infra-std-2.1.xml and \ \ \ Wait for alignment
    &{args} =    Create Dictionary    deviceName=OLT1
    ${response}    Send Baa Request    edit-config    create-infra-std-2.1.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT1
    &{args} =    Create Dictionary    deviceName=OLT1
    ${getResponse}    send_baa_request    get    get-device-data.xml    ${args}
    Element Text Should Be    ${getResponse}    TDP0    xpath=data/network-manager/managed-devices/device/root/xpongemtcont/traffic-descriptor-profiles/traffic-descriptor-profile/name
    Element Text Should Be    ${getResponse}    DHCP_Default    xpath=data/network-manager/managed-devices/device/root/l2-dhcpv4-relay-profiles/l2-dhcpv4-relay-profile/name
    Element Text Should Be    ${getResponse}    classifier_eg0    xpath=data/network-manager/managed-devices/device/root/classifiers/classifier-entry[1]/name
    Element Text Should Be    ${getResponse}    classifier_eg1    xpath=data/network-manager/managed-devices/device/root/classifiers/classifier-entry[2]/name
    Element Text Should Be    ${getResponse}    classifier_ing6    xpath=data/network-manager/managed-devices/device/root/classifiers/classifier-entry[15]/name
    Element Text Should Be    ${getResponse}    classifier_ing7    xpath=data/network-manager/managed-devices/device/root/classifiers/classifier-entry[16]/name
    Element Text Should Be    ${getResponse}    CG_1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[1]/name
    Element Text Should Be    ${getResponse}    CG_1.CPart_1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[2]/name
    Element Text Should Be    ${getResponse}    CG_1.CPart_1.CPair_gpon    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[3]/name
    Element Text Should Be    ${getResponse}    CT_1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[4]/name
    Element Text Should Be    ${getResponse}    CG_2    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[5]/name
    Element Text Should Be    ${getResponse}    CG_2.CPart_1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[6]/name
    Element Text Should Be    ${getResponse}    CG_2.CPart_1.CPair_gpon    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[7]/name
    &{args} =    Create Dictionary    deviceName=OLT1
    ${response}    Send Baa Request    edit-config    grpc-settings-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT1
    &{args} =    Create Dictionary    deviceName=OLT1
    ${getResponse}    send_baa_request    get    get-device-data.xml    ${args}
    Element Text Should Be    ${getResponse}    olt-grpc-2    xpath=data/network-manager/managed-devices/device/root/remote-network-function/nf-client/nf-initiate/remote-endpoints/remote-endpoint/name
    Element Text Should Be    ${getResponse}    olt-grpc-2    xpath=data/network-manager/managed-devices/device/root/remote-network-function/nf-client/nf-initiate/remote-endpoints/remote-endpoint/local-endpoint-name
    Element Text Should Be    ${getResponse}    olt-grpc-2    xpath=data/network-manager/managed-devices/device/root/remote-network-function/nf-endpoint-filter/rule/resulting-endpoint
    ${response}    Send Baa Request    edit-config    network-functions.xml
    Element Should Exist    ${response}    ${OK_RESPONSE}
    BuiltIn.Sleep    1m
    &{args} =    Create Dictionary    oltName=OLT1    ontName=ont1    expectedSerialNumber=ABCD12345678    nfName=bbf-vomci    vomci_gRPC=vOMCi-grpc-1    proxy_gRPC=proxy-grpc-1
    ${response}    send_baa_request    edit-config    create-onu-use-vomci.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    &{args} =    Create Dictionary    ontName=ont1
    ${response}    send_baa_request    edit-config    configure-onu-std-1.0.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    ${requestBody} =    Compose REST Request Body    action=RxMODE
    Send pOLT CLI Command and Verify Response    ${requestBody}
    ${requestBody} =    Compose REST Request Body    action=ADDONU
    Send pOLT CLI Command and Verify Response    ${requestBody}
    Wait Until Keyword Succeeds    3m    10s    Check Device Alignment Status    ont1
    #BuiltIn.Sleep    40s
    #&{args} =    Create Dictionary    deviceName=ont1
    #${getResponse}    send_baa_request    get    get-device-data.xml    ${args}
    #Element Text Should Be    ${getResponse}    ont1    xpath=data/hardware[1]/component/name
    #Element Text Should Be    ${getResponse}    enet_uni_ont1_1_1    xpath=data/interfaces-state/interface[1]/name
    #Element Text Should Be    ${getResponse}    ontUni_ont1_1_1    xpath=data/interfaces-state/interface[1]/port-layer-if
    #Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd    xpath=data/interfaces-state/interface[1]/type
    #Element Text Should Be    ${getResponse}    uni2_ont1    xpath=data/interfaces-state/interface[2]/name
    #Element Text Should Be    ${getResponse}    port_uni2_ont1    xpath=data/interfaces-state/interface[2]/port-layer-if
    #Element Text Should Be    ${getResponse}    ianaift:ethernetCsmacd    xpath=data/interfaces-state/interface[2]/type
    #Element Text Should Be    ${getResponse}    ontAni_ont1    xpath=data/interfaces-state/interface[3]/name
    #Element Text Should Be    ${getResponse}    bbf-xponift:ani    xpath=data/interfaces-state/interface[3]/type
    ${requestBody} =    Compose REST Request Body    action=REMOVEONU
    Send pOLT CLI Command and Verify Response    ${requestBody}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    ont1    connectionStatus=${CONNECTED_FALSE}    alignmentStatus=${ALIGNMENT_UNKNOWN}
    [Teardown]    Run Keywords    Reset device simulator    deviceName=ont1    simulatorName=${ONU_SIMULATOR_NAME}
    ...    AND    Reset device simulator    deviceName=OLT1

Verify Standard OLT device addition to BAA and connection status
    [Documentation]    Author : Selva
    ...
    ...    Add OLT device and check the connection status
    ...
    ...    Test Steps:
    ...    1) Add Standard OLT device
    ...    2) Verify Device is connected and Aligned
    ...    3) Stop pOLT simulator and verify device is disconnected
    ...    4) Start pOLT simulator
    ...    5) Verify device is connected and aligned
    ...    6) Send some configurations to device
    ...    7) Verify device is connected and aligned
    [Tags]    olt
    [Timeout]    5 minutes
    &{args} =    Create Dictionary    deviceName=OLT    version=1.0    ipAddress=${POLT_SIM_IP}    port=${POLT_SIM_PORT}    userName=${POLT_SIM_USER}    password=${POLT_SIM_PASSWORD}
    ${response}    send_baa_request    edit-config    create-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT
    #Stop Simulator and verify device is disconnected
    stop_docker    ${POLT_CONTAINER_NAME}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT    ${CONNECTED_FALSE}    ${ALIGNED}
    #Start Simulator again and verify device is connected
    start_docker    ${POLT_CONTAINER_NAME}
    #connect_onu_simulator
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT
    #verify configurations after restart of Simulator
    ${interfaceArgs}=    Create Dictionary    deviceName=OLT
    ${response}    send_baa_request    edit-config    create-interfaces-olt-1.0.xml    ${interfaceArgs}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT
    &{getArgs} =    Create Dictionary    deviceName=OLT
    ${getResponse}=    send_baa_request    get    get-device-data.xml    ${getArgs}
    Element Text Should Be    ${getResponse}    wavelengthprofile.A    xpath=data/network-manager/managed-devices/device/root/xpon/wavelength-profiles/wavelength-profile/name
    Element Text Should Be    ${getResponse}    channelgroup.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[1]/name
    Element Text Should Be    ${getResponse}    channelpartion.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[2]/name
    Element Text Should Be    ${getResponse}    channelpair.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[3]/name
    Element Text Should Be    ${getResponse}    channeltermination.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[4]/name
    [Teardown]    Reset device simulator

Verify interface configuration on pOLT using std adapter
    [Documentation]    Author : Selva
    ...
    ...    Add OLT device and check the connection status after pOLT has been reset.
    ...
    ...    Test Steps:
    ...    1) Add Standard OLT device
    ...    2) Verify Device is connected and Aligned
    ...    3) Send some configurations
    ...    4) Verify device is connected and aligned after configurations are pushed
    [Tags]    olt
    [Timeout]    5 minutes
    &{args} =    Create Dictionary    deviceName=OLT2    version=1.0    ipAddress=${POLT_SIM_IP}    port=${POLT_SIM_PORT}    userName=${POLT_SIM_USER}    password=${POLT_SIM_PASSWORD}
    ${response}    send_baa_request    edit-config    create-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT2
    ${interfaceArgs}=    Create Dictionary    deviceName=OLT2
    ${response}    send_baa_request    edit-config    create-interfaces-olt-1.0.xml    ${interfaceArgs}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT2
    &{args} =    Create Dictionary    deviceName=OLT2
    ${getResponse}=    send_baa_request    get    get-device-data.xml    ${args}
    Element Text Should Be    ${getResponse}    wavelengthprofile.A    xpath=data/network-manager/managed-devices/device/root/xpon/wavelength-profiles/wavelength-profile/name
    Element Text Should Be    ${getResponse}    channelgroup.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[1]/name
    Element Text Should Be    ${getResponse}    channelpartion.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[2]/name
    Element Text Should Be    ${getResponse}    channelpair.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[3]/name
    Element Text Should Be    ${getResponse}    channeltermination.1    xpath=data/network-manager/managed-devices/device/root/interfaces/interface[4]/name
    [Teardown]    Reset device simulator    deviceName=OLT2

Verify Deploy and Undeploy operations for sample adapter
    [Documentation]    Author : Selva
    ...
    ...    Verify that the sample adapter 'sample-DPU-protocoltls-1.0.kar' can be deployed and undeployed successfully
    [Tags]    vda
    [Timeout]    3 minutes
    ${isKarFileCopied}    copy_adapter_archive    ${CURRENT_RELEASE}    sample-DPU-protocoltls-1.0.kar
    Should Be True    ${isKarFileCopied}
    send_baa_request    action    deploy-sample-adapter.xml
    ${getAdaptersResponse}    send_baa_request    get    get-all-adapters.xml
    Element Text Should Be    ${getAdaptersResponse}    13    data/network-manager/device-adapters/device-adapter-count
    Should Contain    ${getAdaptersResponse}    protocoltls
    send_baa_request    action    undeploy-sample-adapter.xml
    ${getAdaptersResponse}    send_baa_request    get    get-all-adapters.xml
    Element Text Should Be    ${getAdaptersResponse}    12    data/network-manager/device-adapters/device-adapter-count
    Should Not Contain    ${getAdaptersResponse}    protocoltls
    [Teardown]    Run Keywords    Run Keyword and Ignore Error    send_baa_request    action    undeploy-sample-adapter.xml
    ...    AND    delete_adapter_archive    sample-DPU-protocoltls-1.0.kar

Verify deployment of adapter fails due to version mismatch
    [Documentation]    Author : Selva
    ...
    ...    Verify that the adapter deployment fails when version mismatch is encountered.
    ...
    ...    (i.e) if BAA is running with version 1.0.0 and adapter kar file is built on version 5.0 of BAA deployment should fail.
    [Tags]    vda
    [Timeout]    2 minutes
    ${isKarFileCopied}    copy_adapter_archive    5.0    sample-DPU-protocoltls-1.0.kar
    Should Be True    ${isKarFileCopied}
    send_baa_request    action    deploy-sample-adapter.xml
    ${getAdaptersResponse}    send_baa_request    get    get-all-adapters.xml
    Element Text Should Be    ${getAdaptersResponse}    12    data/network-manager/device-adapters/device-adapter-count
    Should Not Contain    ${getAdaptersResponse}    protocoltls
    [Teardown]    Run Keywords    send_baa_request    action    undeploy-sample-adapter.xml
    ...    AND    delete_adapter_archive    sample-DPU-protocoltls-1.0.kar

Verify eONU flow with pOLT simulator
    [Documentation]    Author : Selva
    ...
    ...    Verify the BBWF flow for eONU with pOLT simulator.
    ...
    ...    Send eONU configurations to pOLT simulator
    ...    Verify that the pOLT simulator is connected and aligned after the configuration is sent
    [Tags]    eONU    olt
    [Timeout]    5 minutes
    &{args} =    Create Dictionary    deviceName=OLT    version=1.0    ipAddress=${POLT_SIM_IP}    port=${POLT_SIM_PORT}    userName=${POLT_SIM_USER}    password=${POLT_SIM_PASSWORD}
    ${response}    send_baa_request    edit-config    create-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT
    &{eONUInfraargs} =    Create Dictionary    deviceName=OLT
    ${response}    send_baa_request    edit-config    eONU-Infra_OLT_1.0.xml    ${eONUInfraargs}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT
    &{eONUargs} =    Create Dictionary    deviceName=OLT
    ${response}    send_baa_request    edit-config    eONU-Infra_OLT_1.0.xml    ${eONUargs}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    OLT
    [Teardown]    Reset device simulator    deviceName=OLT

Verify device-alignment-state changed to In Error when device rejects the configuration
    [Documentation]    Author : Selva
    ...
    ...    Verify device's alignment state is changed to In Error state when device rejects the configuration
    [Tags]    olt
    [Timeout]    5 minutes
    &{args} =    Create Dictionary    deviceName=OLT    version=1.0    ipAddress=${POLT_SIM_IP}    port=${POLT_SIM_PORT}    userName=${POLT_SIM_USER}    password=${POLT_SIM_PASSWORD}
    ${response}    send_baa_request    edit-config    create-olt.xml    ${args}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Wait Until Keyword Succeeds    1m    10s    Check Device Alignment Status    ${OLT_NAME}
    &{eONUInfraargs} =    Create Dictionary    deviceName=OLT
    ${response}    send_baa_request    edit-config    interfaces-with-wrong-config.xml    ${eONUInfraargs}
    Element Should Exist    ${response}    ${OK_RESPONSE}
    Sleep    30s
    &{alignmentArgs} =    Create Dictionary    deviceName=${OLT_NAME}
    ${alignmentResponse}    send_baa_request    get    get-device-alignment-status.xml    ${alignmentArgs}
    Element Text Should Be    ${alignmentResponse}    ${CONNECTED_TRUE}    data/network-manager/managed-devices/device/device-management/device-state/connection-state/connected
    Should Contain    ${alignmentResponse}    ${ALIGNMENT_ERROR}
    Log    ${ALIGNMENT_ERROR} is present in configuration-alignment-state
    [Teardown]    Reset device simulator    deviceName=OLT
