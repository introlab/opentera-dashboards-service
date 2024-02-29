import unittest
from ConfigManager import ConfigManager
import Globals as Globals
from flask.testing import FlaskClient
import random
from string import digits, ascii_lowercase, ascii_uppercase
from tests.FakeDashboardsService import FakeDashboardsService


class BaseDashboardsAPITest(unittest.TestCase):
    _config = None
    _service = None
    _db_man = None
    test_endpoint = ''
    user_token_key = ''.join(random.choice(digits + ascii_lowercase + ascii_uppercase) for _ in range(36))
    participant_token_key = ''.join(random.choice(digits + ascii_lowercase + ascii_uppercase) for _ in range(36))
    service_token_key = ''.join(random.choice(digits + ascii_lowercase + ascii_uppercase) for _ in range(36))
    device_token_key = ''.join(random.choice(digits + ascii_lowercase + ascii_uppercase) for _ in range(36))
    user_login_endpoint = '/api/user/login'
    user_logout_endpoint = '/api/user/logout'

    @classmethod
    def setUpClass(cls):
        cls._config = BaseDashboardsAPITest.getConfig()
        # Instance of Fake service API will create a new flask_app
        cls._service = FakeDashboardsService()
        cls._users = cls._service.users
        # API Need this variable to be set
        Globals.service = cls._service
        from libDashboards.db.DBManager import DBManager
        cls._db_man: DBManager = DBManager(app=cls._service.flask_app, test=True)
        # Cheating using same db as FakeService
        cls._db_man.db = cls._service.db_manager.db

        with cls._service.flask_app.app_context():
            cls._db_man.create_defaults(test=True)

    def app_context(self):
        self.assertIsNotNone(self._service)
        self.assertIsNotNone(self._service.flask_app)
        return self._service.flask_app.app_context()

    @classmethod
    def tearDownClass(cls):
        with cls._service.flask_app.app_context():
            cls._db_man.db.session.remove()

    @classmethod
    def getConfig(cls) -> ConfigManager:
        config = ConfigManager()
        config.create_defaults()
        return config

    def setUp(self):
        self.assertIsNotNone(self._service)
        self.assertIsNotNone(self._service.flask_app)
        self.test_client = self._service.flask_app.test_client()

    def tearDown(self):
        with self.app_context():
            # Make sure pending queries are rollbacked.
            self._db_man.db.session.rollback()

    def _get_with_service_token_auth(self, client: FlaskClient, token=None, params=None, endpoint=None):
        if params is None:
            params = {}
        if endpoint is None:
            endpoint = self.test_endpoint
        if token is not None:
            headers = {'Authorization': 'OpenTera ' + token}
        else:
            headers = {}

        return client.get(endpoint, headers=headers, query_string=params)

    def _get_with_user_token_auth(self, client: FlaskClient, token: str = '', params=None, endpoint=None):
        if params is None:
            params = {}
        if endpoint is None:
            endpoint = self.test_endpoint
        headers = {'Authorization': 'OpenTera ' + token}
        return client.get(endpoint, headers=headers, query_string=params)

    def _post_with_user_token_auth(self, client: FlaskClient, token: str = '', json: dict = None, params: dict = None,
                                   endpoint=None):
        if params is None:
            params = {}
        if endpoint is None:
            endpoint = self.test_endpoint
        headers = {'Authorization': 'OpenTera ' + token}
        return client.post(endpoint, headers=headers, query_string=params, json=json)

    def _delete_with_user_token_auth(self, client: FlaskClient, token: str = '', params=None, endpoint=None):
        if params is None:
            params = {}
        if endpoint is None:
            endpoint = self.test_endpoint
        headers = {'Authorization': 'OpenTera ' + token}
        return client.delete(endpoint, headers=headers, query_string=params)
