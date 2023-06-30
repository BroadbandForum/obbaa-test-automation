"""
docker API class defines the robot keywords to be used to commands to manage the docker containers

"""
import json
import logging
import os
import subprocess
import time
import requests

from constants import POLT_REST_URL, ONU_SIM_IP, ONU_SIM_PORT

logger = logging.getLogger('docker_api')
logging.basicConfig(level=logging.INFO, format='%(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')

def start_dockers():
    """
    *start_dockers()* - Start docker containers which are defined in the docker-compose(/data/compose_data/docker-compose.yaml) file
    :return:
    """
    logger.info('\n Starting Dockers ...')
    cmd = './data/compose_data/start_dockers.sh &'
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, text=True)
    time.sleep(20)
    p.poll()
    if p.returncode == 0:
        logger.info('\n Started docker containers ...')
        p.kill()
        return True
    else:
        logger.info('\n Failed to start docker containers ... %s', p.stderr)
        p.kill()
        return False

def stop_dockers():
    """
    *stop_dockers()* - Stop all docker containers defined in the docker-compose(/data/compose_data/docker-compose.yaml) file
    :return:
    """
    logger.info('\n Stopping Dockers ...')
    cmd = 'docker-compose -f ./data/compose_data/docker-compose.yaml down'
    result = subprocess.run(cmd, shell=True, timeout=60, capture_output=True, text=True)
    time.sleep(20)
    if result.returncode == 0:
        logger.info('\n Successfully stopped docker containers ... %s', result.stderr)
        return True
    else:
        logger.info('\n Failed to stop docker containers ... %s', result.stderr)
        return False

def remove_baa_stores():
    """
    *remove_baa_stores()* - Delete /baa/stores directory from the docker host machine
    :return:
    """
    logger.info('\n Cleaning up stores ...')
    cmd = 'sudo rm -rf /baa/stores'
    result = subprocess.run(cmd, shell=True, timeout=60, capture_output=True, text=True)
    logger.info('Clean up stores result %s', result.stderr)
    logger.info('\n Clean up stores completed!')

def pull_simulator_images():
    """
    *pull simulator_images* - pull simulator images from dockerHub
    :return:
    """
    logger.info('\n Pulling docker Images ...')
    cmd = './data/compose_data/pull_simulator_images.sh &'
    result = subprocess.run(cmd, shell=True, timeout=120, capture_output=True, text=True)
    logger.info('Docker pull result %s', result.stderr)

def copy_adapter_archive(version, karfile):
    """
    *copy_adapter_archive(version, archive)* - Copy given adapter archive file to the staging area
    :param version:
    :param karfile:
    :return:
    """
    logger.info('\n Copying the kar file ...')
    cmd = 'sudo cp ./data/baa_adapters/' + version + '/' + karfile + ' /baa/stores/deviceAdapter'
    result = subprocess.run(cmd, shell=True, timeout=60, capture_output=True, text=True)
    if result.returncode == 0:
        logger.info('\n Successfully copied the kar file!! : %s', karfile)
        logger.info('\n Copy archive result %s', result.stderr)
        return True
    else:
        logger.info('\n Failed copy the kar file!! :%s', karfile)
        logger.info('\n Copy archive result %s', result.stderr)
        return False

def delete_adapter_archive(karfile):
    """
     *delete_adapter_archive(archive)* - Delete given adapter archive from staging area
    :param karfile:
    :return:
    """
    logger.info('\n Deleting the kar file %s from stores!', karfile)
    cmd = 'sudo rm -rf /baa/stores/deviceAdapter/' + karfile
    result = subprocess.run(cmd, shell=True, timeout=60, capture_output=True, text=True)
    logger.info(result.stderr)
    logger.info('\n Removed the adapter archive %s from stores!', karfile)

def restart_docker(docker_name):
    """
    *restart_docker(docker_name)* - Restart the given docker container
    :param docker_name:
    :return:
    """
    os.system("docker restart " + docker_name)
    time.sleep(5)
    logger.info('\n Docker restart of %s container is completed!', docker_name)

def stop_docker(docker_name):
    """
    *stop_docker(docker_name)* - Restart the given docker container
    :param docker_name:
    :return:
    """
    os.system("docker stop " + docker_name)
    time.sleep(5)
    logger.info('\n Docker stop of %s completed!', docker_name)

def start_docker(docker_name):
    """
    *start_docker(docker_name)* - Start the given docker container
    :param docker_name:
    :return:
    """
    os.system("docker start " + docker_name)
    time.sleep(5)
    logger.info('\n Docker start of %s container completed!', docker_name)

def remove_docker(docker_name):
    """
    *remove_docker(docker_name)* - Remove the given docker container
    :param docker_name:
    :return:
    """
    os.system("docker rm -f " + docker_name)
    time.sleep(5)
    logger.info('\n Docker remove of %s container completed!', docker_name)

def connect_onu_simulator():
    """
    *connect_onu_simulator()* - Connect pOLT and ONU Simulators
    :return:
    """
    logger.info('\n Connecting OLT and ONU simulators ...')
    cmd = './data/compose_data/connect_onu_sim.sh &'
    p = subprocess.Popen(cmd, stdout=subprocess.PIPE, shell=True, text=True)
    time.sleep(20)
    p.kill()
    logger.info('\n Successfully connected OLT and ONU simulators...')

def send_polt_cli_command(cmd):
    """
    *send_polt_cli_command(cmd)* - Sends polt cli commands
    :return:
    """
    logger.info('\n Sending REST Request to pOLT simulator ...')
    data = json.dumps(cmd)
    logger.info('\n Data to be sent in REST request:\n %s ', data)
    response = requests.post(url=POLT_REST_URL, data=data)
    if response.status_code == 200:
        logger.info('\n Received the response from POLT REST API %s \n', response.json())
        if response.json()['responses'][0]['status'] == 0:
            logger.info('\n Received Success Response code: %s and Status code: %s from POLT REST API\n', response.status_code, response.json()['responses'][0]['status'] )
            return True
        else:
            logger.error('\n Error: pOLT Simulator returned a non-zero status %s \n', response.json()['responses'][0]['status'])
    else:
        logger.error('\n Received the response from POLT REST API %s \n', response.json())
        logger.error('\n Received Non Success Response code: %s from POLT REST API \n', response.status_code)
    return False


def compose_REST_request_body(action='ADDONU',
                              channel_term='CT_1',  onu_id=1, serial_vendor_id="ABCD",
                              serial_vendor_specific=12345678, flags='present+in_o5+expected',
                              management_state='relying-on-vomci',
                              mode="onu_sim", onu_sim_ip=ONU_SIM_IP, onu_sim_port=ONU_SIM_PORT, loid=None, v_ani=None):
    """
    *compose_REST_request_body(channel_term='CT_1', action='ADDONU', onu_id=1, serial_vendor_id="ABCD",
                    serial_vendor_specific=12345678, flags='present+in_o5+expected',
                    management_state='relying-on-vomci',
                    mode="onu_sim", onu_sim_ip="172.27.0.6", onu_sim_port=50000,
                    loid=None, v_ani=None)* - Composes POLT's REST API body based on the arguments passed

    :param action: valid arguments are "ADDONU", "REMOVEONU" and "RxMODE"
    :param channel_term: Used in spicifying channel terminal of ont
    :param onu_id:
    :param serial_vendor_id:
    :param serial_vendor_specific:
    :param flags:
    :param management_state:
    :param mode:
    :param onu_sim_ip:
    :param onu_sim_port:
    :param loid:
    :param v_ani:
    :return request_body:

    The below is the request body returned if no arugments are passed
    "requests":[
        {
                    "channel_term": "CT_1",
                    "action": "ADDONU",
                    "onu_id": 1,
                    "serial_vendor_id": "ABCD",
                    "serial_vendor_specific": 12345678,
                    "flags": "present+in_o5+expected",
                    "management_state": "relying-on-vomci"
        }
      ]
    }

    The below is the request body returned if action argument is passed as "RxMODE"
    { 
      "requests":[
        {
          "mode": "onu_sim",
          "action": "RxMODE",
          "onu_sim_ip": "172.27.0.6",
          "onu_sim_port": 50000
        }
      ]
    }

    The below is the request body returned if action argument is passed as "REMOVEONU"
    {
      "requests":
      [
        {
          "channel_term": 1,
          "action": "REMOVEONU",
          "onu_id": 2,
          "serial_vendor_id": 1,
          "serial_vendor_specific": 1,
          "flags": present+in_o5,
          "management_state": relying-on-vomci,
          "loid": test1, 
          "v_ani": vani-user1
        }
      ]
    }
    """
    request_body = {}
    if action == "ADDONU":
        request_body["channel_term"] = channel_term
        request_body["action"] = action
        request_body["onu_id"] = onu_id
        request_body["serial_vendor_id"] = serial_vendor_id
        request_body["serial_vendor_specific"] = serial_vendor_specific
        request_body["flags"] = flags
        request_body["management_state"] = management_state

    elif action == "RxMODE":
        request_body["mode"] = mode
        request_body["action"] = action
        request_body["onu_sim_ip"] = onu_sim_ip
        request_body["onu_sim_port"] = onu_sim_port

    elif action == "REMOVEONU":
        request_body["channel_term"] = channel_term
        request_body["action"] = action
        request_body["onu_id"] = onu_id
        request_body["serial_vendor_id"] = serial_vendor_id
        request_body["serial_vendor_specific"] = serial_vendor_specific
        request_body["management_state"] = management_state

    else:
        logger.error('\n Received an invalid action argument %s \n', action)
        return None
    if loid is not None:
        request_body["loid"] = loid
    if v_ani is not None:
        request_body["v_ani"] = v_ani
    print(request_body)
    request_body = [request_body]
    request_body = {"requests": request_body}
    return request_body
