from FlaskModule import CustomAPI, authorizations
import requests
from requests.auth import _basic_auth_str
from ConfigManager import ConfigManager
from libDashboards.db.DBManager import DBManager
from opentera.modules.BaseModule import BaseModule
from opentera.services.ServiceOpenTera import ServiceOpenTera
from opentera.redis.RedisVars import RedisVars
from opentera.services.ServiceAccessManager import ServiceAccessManager

from flask import Flask
from flask_babel import Babel
import redis
import uuid


class FakeFlaskModule(BaseModule):
    def __init__(self,  config: ConfigManager, flask_app):
        BaseModule.__init__(self, 'FakeFlaskModule', config)

        # Will allow for user api to work
        self.config.server_config = {'hostname': '127.0.0.1', 'port': 40075}

        self.flask_app = flask_app
        self.api = CustomAPI(self.flask_app, version='1.0.0', title='DashboardsService API',
                             description='FakeDashboardsService API Documentation', doc='/doc', prefix='/api',
                             authorizations=authorizations)

        self.babel = Babel(self.flask_app)

        flask_app.debug = False
        flask_app.testing = True
        flask_app.secret_key = str(uuid.uuid4())  # Normally service UUID
        flask_app.config.update({'SESSION_TYPE': 'redis'})
        redis_url = redis.from_url('redis://%(username)s:%(password)s@%(hostname)s:%(port)s/%(db)s'
                                   % self.config.redis_config)

        flask_app.config.update({'SESSION_REDIS': redis_url})
        flask_app.config.update({'BABEL_DEFAULT_LOCALE': 'fr'})
        flask_app.config.update({'SESSION_COOKIE_SECURE': True})
        self.recrutement_api_namespace = self.api.namespace('', description='RecrutementService API')

        self.setup_fake_recrutement_api(flask_app)

    def setup_fake_recrutement_api(self, flask_app):
        from FlaskModule import FlaskModule
        with flask_app.app_context():
            # Setup Fake Service API
            kwargs = {'flaskModule': self,
                      'test': True}
            FlaskModule.init_user_api(self, None, self.recrutement_api_namespace, kwargs)


class FakeDashboardsService(ServiceOpenTera):
    """
        The only thing we want here is a way to simulate communication with the base server.
        We will simulate the service API with the database.
    """
    service_token = str()

    def __init__(self, db=None):
        self.flask_app = Flask('FakeDashboardsService')

        # OpenTera server informations
        self.backend_hostname = '127.0.0.1'
        self.backend_port = 40075
        self.server_url = 'https://' + self.backend_hostname + ':' + str(self.backend_port)

        self.config_man = ConfigManager()
        self.config_man.create_defaults()
        import Globals
        Globals.service = self
        self.db_manager = DBManager(self.flask_app, test=True)
        # Cheating on db (reusing already opened from test)
        if db is not None:
            self.db_manager.db = db
            self.db_manager.create_defaults(test=True)
        else:
            self.db_manager.open_local({}, echo=False)

        self.test_client = self.flask_app.test_client()

        print('Resetting OpenTera database')
        self.reset_opentera_test_db()

        # Create service on OpenTera (using user API)
        print('Creating service : DashboardsService')
        json_data = {
            'service': {
                "id_service": 0,
                "service_clientendpoint": "/dashboards",
                "service_enabled": True,
                "service_endpoint": "/",
                "service_hostname": "127.0.0.1",
                "service_name": "Dashboard Services",
                "service_port": 5055,
                "service_key": "DashboardsService",
                "service_endpoint_participant": "/participant",
                "service_endpoint_user": "/user",
                "service_endpoint_device": "/device"
            }
        }
        r = self.post_to_opentera_as_user('/api/user/services', json_data, 'admin', 'admin')
        if r.status_code != 200:
            print('Error creating service')
            exit(1)

        with self.flask_app.app_context():
            # Update redis vars and basic token
            self.setup_service_access_manager()

            # Get service UUID
            service_info = self.redisGet(RedisVars.RedisVar_ServicePrefixKey +
                                         Globals.config_man.service_config['name'])

            import json
            service_info = json.loads(service_info)
            if 'service_uuid' not in service_info:
                exit(1)

            Globals.config_man.service_config['ServiceUUID'] = service_info['service_uuid']

            # Redis variables & db must be initialized before
            ServiceOpenTera.__init__(self, self.config_man, service_info)

            # Will contain list of users by service role: super_admin, admin, manager, user and no access
            self.users = {}
            self.init_service()

            # Setup modules
            self.flask_module = FakeFlaskModule(self.config_man, self.flask_app)

    def init_service(self):
        print('Initializing service...')
        # Get users tokens
        response = self.get_from_opentera_as_user('/api/user/login', {}, 'admin', 'admin')
        if response.status_code != 200:
            print("Unable to query super admin token")
            exit(1)

        self.users['superadmin'] = response.json()['user_token']

        response = self.get_from_opentera_as_user('/api/user/login', {}, 'user4', 'user4')
        if response.status_code != 200:
            print("Unable to query no access user token")
            exit(1)

        self.users['noaccess'] = response.json()['user_token']

        response = self.get_from_opentera_as_user('/api/user/login', {}, 'user', 'user')
        if response.status_code != 200:
            print("Unable to query user token")
            exit(1)

        self.users['user'] = response.json()['user_token']

        response = self.get_from_opentera_as_user('/api/user/login', {}, 'user3', 'user3')
        if response.status_code != 200:
            print("Unable to query manager user token")
            exit(1)

        self.users['projectadmin'] = response.json()['user_token']

        response = self.get_from_opentera_as_user('/api/user/login', {}, 'siteadmin', 'siteadmin')
        if response.status_code != 200:
            print("Unable to query admin user token")
            exit(1)

        self.users['siteadmin'] = response.json()['user_token']

    def setup_service_access_manager(self):
        self.redis = redis.Redis(host=self.config_man.redis_config['hostname'],
                                 port=self.config_man.redis_config['port'],
                                 db=self.config_man.redis_config['db'],
                                 username=self.config_man.redis_config['username'],
                                 password=self.config_man.redis_config['password'],
                                 client_name=self.__class__.__name__)

        # Initialize service from redis
        # User token key (dynamic)
        ServiceAccessManager.api_user_token_key = 'test_api_user_token_key'
        self.redis.set(RedisVars.RedisVar_UserTokenAPIKey,
                       ServiceAccessManager.api_user_token_key)

        # Participant token key (dynamic)
        ServiceAccessManager.api_participant_token_key = 'test_api_participant_token_key'
        self.redis.set(RedisVars.RedisVar_ParticipantTokenAPIKey,
                       ServiceAccessManager.api_participant_token_key)

        # Service Token Key (dynamic)
        ServiceAccessManager.api_service_token_key = 'test_api_service_token_key'
        self.redis.set(RedisVars.RedisVar_ServiceTokenAPIKey, ServiceAccessManager.api_service_token_key)
        ServiceAccessManager.config_man = self.config_man

    def post_to_opentera_as_user(self, api_url: str, json_data: dict, username: str, password: str) \
            -> requests.Response:
        # Synchronous call to OpenTera
        headers = {'Authorization': _basic_auth_str(username, password)}
        answer = requests.post(self.server_url + api_url, headers=headers, json=json_data, verify=False)
        return answer

    def get_from_opentera_as_user(self, api_url: str, params: dict, username: str, password: str) \
            -> requests.Response:
        # Synchronous call to OpenTera
        headers = {'Authorization': _basic_auth_str(username, password)}
        answer = requests.get(self.server_url + api_url, headers=headers, params=params, verify=False)
        return answer

    def reset_opentera_test_db(self):
        return requests.get(self.server_url + '/api/test/database/reset', verify=False)

