"""
netconf API class defines the robot keywords to be used to send netconf requests and receive and parse the netconf responses

"""
import logging
from typing import Any
from xml.dom.minidom import parseString

from jinja2 import FileSystemLoader, Environment, select_autoescape
from ncclient import manager
from netconf_console.operations import Rpc

import constants

logger = logging.getLogger('netconf_api')
logging.basicConfig(level=logging.INFO, format='%(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')

env = Environment(loader=FileSystemLoader(constants.BAA_REQUEST_PATH), autoescape=select_autoescape(['xml']))


def send_baa_request(operation, template_name, *args):
    """
    *send_baa_request(operation, template_name, *args)* - Can send different netconf requests(get,edit-config,action and get-config requests) to BAA,
                                                        Sample netconf requests can be found in /data/netconf_requests/
    :param operation:
    :param template_name:
    :param args:
    :return:
    """
    with manager.connect(host=constants.BAA_SERVER_IP,
                         port=constants.BAA_NBI_PORT,
                         username=constants.BAA_USERNAME,
                         password=constants.BAA_PASSWORD,
                         timeout=30,
                         hostkey_verify=False,
                         device_params={'name': 'nexus'}) as m:
        if operation == 'get':
            logger.info('\n get operation')
            get_template = env.get_template(template_name)
            thisFilter = get_template.render(*args)
            logger.info('\n get filter: %s', thisFilter)
            response = m.get(filter=thisFilter)
            logger.info('\n get response: %s', parseString(response.xml).toprettyxml())
            return parseString(response.xml).toprettyxml()
        elif operation == 'edit-config':
            logger.info('\n edit-config operation')
            edit_config_template = env.get_template(template_name)
            config = edit_config_template.render(*args)
            response = m.edit_config(target='running', config=config)
            logger.info('\n edit-config response: %s', parseString(response.xml).toprettyxml())
            return parseString(response.xml).toprettyxml()
        elif operation == 'get-config':
            logger.info('get-config operation')
            get_config_template = env.get_template(template_name)
            getConfigFilter = get_config_template.render()
            response = m.get_config(filter=getConfigFilter)
            logger.info('get-config response %s', parseString(response.xml).toprettyxml())
            return parseString(response.xml).toprettyxml()
        elif operation == 'action':
            template_path = constants.BAA_REQUEST_PATH + template_name
            return Rpc.invoke(self=None, ns=Any, mc=m, filename=template_path)
        else:
            logger.info('Operation not supported')