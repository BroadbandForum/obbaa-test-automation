#!/bin/bash
docker exec -i polt-simulator bash <<< 'echo -e "/polt/set client_server=client enable=yes \n /log/n name=POLT log_level_print=DEBUG log_level_save=DEBUG \n /po/rx_mode mode=onu_sim onu_sim_ip=172.27.0.6 onu_sim_port=50000" > t.cli; /usr/local/start_netconf_server.sh -dummy_tr385 -f /t.cli -d'
