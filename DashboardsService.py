# Twisted
import sys
import json
import os
import argparse

from twisted.internet import reactor
from twisted.python import log

from opentera.services.ServiceOpenTeraWithAssets import ServiceOpenTera
from opentera.redis.RedisClient import RedisClient
from opentera.redis.RedisVars import RedisVars

# from sqlalchemy.exc import OperationalError
from FlaskModule import FlaskModule, flask_app
import Globals
from ConfigManager import ConfigManager


class DashboardsService(ServiceOpenTera):
    def __init__(self, config_man: ConfigManager, this_service_info):
        ServiceOpenTera.__init__(self, config_man, this_service_info)

        # Create REST backend
        self.flaskModule = FlaskModule(config_man, self)

        # Create twisted service
        self.flaskModuleService = self.flaskModule.create_service()

        # self.application = service.Application(self.config['name'])
        self.init_service()

    def init_service(self):
        # Service must be initialized first
        pass

    def notify_service_messages(self, pattern, channel, message):
        pass


if __name__ == '__main__':
    # Very first thing, log to stdout
    log.startLogging(sys.stdout)

    parser = argparse.ArgumentParser(description='DashboardsService')


    parser.add_argument('--enable_tests', help='Test mode for service.', default=False)
    parser.add_argument('--config', help='Specify config file.', default='DashboardsService.json')
    args = parser.parse_args()

    # Load configuration
    if not Globals.config_man.load_config(args.config):
        print('Invalid config')
        sys.exit(1)

    # Global redis client
    Globals.redis_client = RedisClient(Globals.config_man.redis_config)

    # Get service UUID
    service_info = Globals.redis_client.redisGet(RedisVars.RedisVar_ServicePrefixKey +
                                                 Globals.config_man.service_config['name'])

    if service_info is None:
        sys.stderr.write('Error: Unable to get service info from OpenTera Server - is the server running and config '
                         'correctly set in this service?')
        sys.exit(1)


    service_info = json.loads(service_info)
    if 'service_uuid' not in service_info:
        sys.stderr.write('OpenTera Server didn\'t return a valid service UUID - aborting.')
        sys.exit(1)

    # Update service uuid
    Globals.config_man.service_config['ServiceUUID'] = service_info['service_uuid']

    # Update port, hostname, endpoint
    Globals.config_man.service_config['port'] = service_info['service_port']
    Globals.config_man.service_config['hostname'] = service_info['service_hostname']

    # DATABASE CONFIG AND OPENING
    #############################
    POSTGRES = {
        'user': Globals.config_man.db_config['username'],
        'pw': Globals.config_man.db_config['password'],
        'db': Globals.config_man.db_config['name'],
        'host': Globals.config_man.db_config['url'],
        'port': Globals.config_man.db_config['port']
    }

    # TODO Handle open database here
    # try:
    #    if args.enable_tests:
    #        Globals.db_man.open_local(None, echo=True)
    #    else:
    #        Globals.db_man.open(POSTGRES, Globals.config_man.service_config['debug_mode'])
    #except OperationalError as e:
    #    print("Unable to connect to database - please check settings in config file!", e)
    #    quit()

    with flask_app.app_context():
        # Create the Service
        Globals.service = DashboardsService(Globals.config_man, service_info)

        # Start App / reactor events
        reactor.run()
