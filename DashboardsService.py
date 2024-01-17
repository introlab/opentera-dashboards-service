from FlaskModule import flask_app
import Globals as Globals
from ConfigManager import ConfigManager
from opentera.redis.RedisClient import RedisClient
from opentera.redis.RedisVars import RedisVars

# Twisted
from twisted.internet import reactor
from twisted.python import log
import sys
import os

from opentera.services.ServiceOpenTeraWithAssets import ServiceOpenTeraWithAssets
from sqlalchemy.exc import OperationalError
from FlaskModule import FlaskModule
import opentera.messages.python as messages
import argparse

from requests import Response, get, post, delete

# TODO: Rename OMRService to something more appropriate for you
class OMRService(ServiceOpenTeraWithAssets):
    def __init__(self, config_man: ConfigManager, this_service_info):
        ServiceOpenTeraWithAssets.__init__(self, config_man, this_service_info)

        self.verify_file_upload_directory(config_man)

        # Create REST backend
        self.flaskModule = FlaskModule(config_man, self)

        # Create twisted service
        self.flaskModuleService = self.flaskModule.create_service()

        # self.application = service.Application(self.config['name'])
        self.init_service()

    def init_service(self):
        # Service must be initialized first with the setup_omr_service_run_once.py
        pass

    def verify_file_upload_directory(self, config: ConfigManager, create=True):
        file_upload_path = config.specific_service_config['files_directory']

        if not os.path.exists(file_upload_path):
            if create:
                os.mkdir(file_upload_path, 0o700)
            else:
                return None
        return file_upload_path

    def notify_service_messages(self, pattern, channel, message):
        pass

    # @defer.inlineCallbacks
    def register_to_events(self):
        super().register_to_events()

    def asset_event_received(self, event: messages.DatabaseEvent):
        # Automatically register to "assets" event so we can manage the files and database accordingly
        if event.object_type == 'asset':
            if event.type == messages.DatabaseEvent.DB_DELETE:
                # TODO: Properly manage delete asset event for your service
                print("OMR Service - Delete Asset Event")
                asset_info = json.loads(event.object_value)
                from libomr.db.models.AssetFileData import AssetFileData
                asset = AssetFileData.get_asset_for_uuid(asset_info['asset_uuid'])
                if asset:
                    flask_app.app_context().push()
                    asset.delete_file_asset(flask_app.config['UPLOAD_FOLDER'])

    def post_to_opentera_with_token(self, token: str,  api_url: str, json_data: dict) -> Response:
        # Synchronous call to OpenTera backend
        url = "https://" + self.backend_hostname + ':' + str(self.backend_port) + api_url
        request_headers = {'Authorization': 'OpenTera ' + token}
        return post(url=url, verify=False, headers=request_headers, json=json_data)

    def get_from_opentera_with_token(self, token: str, api_url: str, params: dict) -> Response:
        from flask import jsonify, Response
        # Synchronous call to OpenTera backend
        url = "https://" + self.backend_hostname + ':' + str(self.backend_port) + api_url
        request_headers = {'Authorization': 'OpenTera ' + token}
        return get(url=url, verify=False, headers=request_headers, params=params)

    def delete_from_opentera_with_token(self, token: str, api_url: str, params: dict) -> Response:
        # Synchronous call to OpenTera backend
        url = "https://" + self.backend_hostname + ':' + str(self.backend_port) + api_url
        request_headers = {'Authorization': 'OpenTera ' + token}
        return delete(url=url, verify=False, headers=request_headers, params=params)

if __name__ == '__main__':
    # Very first thing, log to stdout
    log.startLogging(sys.stdout)

    parser = argparse.ArgumentParser(description='OMR Service')
    # TODO use real database, for now will use sqlite in RAM...
    parser.add_argument('--enable_tests', help='Test mode for service.', default=False)
    args = parser.parse_args()

    # Load configuration
    if not Globals.config_man.load_config('OMRService.json'):
        print('Invalid config')
        exit(1)

    # Global redis client
    Globals.redis_client = RedisClient(Globals.config_man.redis_config)

    # Get service UUID
    service_info = Globals.redis_client.redisGet(RedisVars.RedisVar_ServicePrefixKey +
                                                 Globals.config_man.service_config['name'])
    import sys
    if service_info is None:
        sys.stderr.write('Error: Unable to get service info from OpenTera Server - is the server running and config '
                         'correctly set in this service?')
        exit(1)

    import json
    service_info = json.loads(service_info)
    if 'service_uuid' not in service_info:
        sys.stderr.write('OpenTera Server didn\'t return a valid service UUID - aborting.')
        exit(1)

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

    try:
        if args.enable_tests:
            Globals.db_man.open_local(None, echo=True)
        else:
            Globals.db_man.open(POSTGRES, Globals.config_man.service_config['debug_mode'])
    except OperationalError as e:
        print("Unable to connect to database - please check settings in config file!", e)
        quit()

    with flask_app.app_context():
        Globals.db_man.create_defaults(Globals.config_man, False) #TODO change to false when working in publication mode

        # Create the Service
        Globals.service = OMRService(Globals.config_man, service_info)

        # Start App / reactor events
        reactor.run()
