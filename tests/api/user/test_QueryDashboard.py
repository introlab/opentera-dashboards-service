from tests.BaseDashboardsAPITest import BaseDashboardsAPITest
from libDashboards.db.models import DashDashboards


class QueryDashboardTest(BaseDashboardsAPITest):
    test_endpoint = '/api/dashboards'

    def setUp(self):
        super().setUp()

        # Load list of dashboards to query / test
        self._dashboards = {}
        with self.app_context():
            dashboards = DashDashboards.query.all()
            self._dashboards["site"] = {'id': dashboards[0].id_dashboard, 'uuid': dashboards[0].dashboard_uuid}
            self._dashboards["project_global"] = {'id': dashboards[1].id_dashboard,
                                                  'uuid': dashboards[1].dashboard_uuid
                                                  }
            self._dashboards["project_alert"] = {'id': dashboards[2].id_dashboard, 'uuid': dashboards[2].dashboard_uuid}
            self._dashboards["global"] = {'id': dashboards[3].id_dashboard, 'uuid': dashboards[3].dashboard_uuid}

    def tearDown(self):
        super().tearDown()

    def test_get_with_invalid_token(self):
        with self.app_context():
            response = self._get_with_user_token_auth(self.test_client, token="invalid")
            self.assertEqual(403, response.status_code)

    def test_get_no_params(self):
        with self.app_context():
            for user in self._users:
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user])
                self.assertEqual(400, response.status_code)

    def test_get_with_bad_id(self):
        with self.app_context():
            for user in self._users:
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'id_dashboard': -1})
                self.assertEqual(403, response.status_code)

    def test_get_with_bad_uuid(self):
        with self.app_context():
            for user in self._users:
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'uuid': "0000-0000-0000-0000"})
                self.assertEqual(403, response.status_code)

    def test_get_site_dashboard_by_id(self):
        with self.app_context():
            for user in self._users:
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'id_dashboard': self._dashboards["site"]["id"]})
                if user == "noaccess":
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0])
                    self.assertEqual(self._dashboards["site"]["id"], response.json[0]['id_dashboard'])

    def test_get_site_dashboard_by_uuid(self):
        with self.app_context():
            for user in self._users:
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'uuid': self._dashboards["site"]["uuid"]})
                if user == "noaccess":
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0])
                    self.assertEqual(self._dashboards["site"]["id"], response.json[0]['id_dashboard'])

                # Test to get all versions
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'uuid': self._dashboards["site"]["uuid"],
                                                                  'all_versions': True})
                if user == "noaccess":
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0])
                    self.assertEqual(2, len(response.json[0]['versions']))
                    self.assertEqual(self._dashboards["site"]["id"], response.json[0]['id_dashboard'])

    def test_get_project_dashboard_by_id(self):
        with self.app_context():
            for user in self._users:
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'id_dashboard':
                                                                  self._dashboards["project_global"]["id"]})
                if user == "noaccess" or user == "projectadmin":  # Project admin has access to projet 1, but not 2.
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0])
                    self.assertEqual(self._dashboards["project_global"]["id"], response.json[0]['id_dashboard'])

                # Check with enabled = false
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'id_dashboard':
                                                                  self._dashboards["project_global"]["id"],
                                                                  'enabled': False})
                if user == "noaccess":  # Project admin has access to projet 1, but not 2.
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0])
                    self.assertEqual(self._dashboards["project_global"]["id"], response.json[0]['id_dashboard'])

                # Check with list = true
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'id_dashboard':
                                                                  self._dashboards["project_global"]["id"],
                                                                  'list': True})
                if user == "noaccess" or user == "projectadmin":  # Project admin has access to projet 1, but not 2.
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0], minimal=True)
                    self.assertEqual(self._dashboards["project_global"]["id"], response.json[0]['id_dashboard'])

    def test_get_project_dashboard_by_uuid(self):
        with self.app_context():
            for user in self._users:
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'uuid':
                                                                  self._dashboards["project_alert"]["uuid"]})
                if user == "noaccess":  # Project admin has access to projet 1, but not 2.
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0])
                    self.assertEqual(self._dashboards["project_alert"]["id"], response.json[0]['id_dashboard'])

                # Check with enabled = false
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'uuid':
                                                                  self._dashboards["project_alert"]["uuid"],
                                                                  'enabled': False})
                if user == "noaccess":  # Project admin has access to projet 1, but not 2.
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(1, len(response.json))
                    self._check_json(response.json[0])
                    self.assertEqual(self._dashboards["project_alert"]["id"], response.json[0]['id_dashboard'])

    def test_get_by_site_id(self):
        for user in self._users:
            response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                      params={'id_site': 1})
            if user == "noaccess":  # Project admin has access to projet 1, but not 2.
                self.assertEqual(403, response.status_code)
            else:
                self.assertEqual(200, response.status_code)
                self.assertEqual(1, len(response.json))
                self._check_json(response.json[0])
                self.assertEqual(self._dashboards["site"]["id"], response.json[0]['id_dashboard'])

    def test_get_by_project_id(self):
        for user in self._users:
            response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                      params={'id_project': 1})
            if user == "noaccess":
                self.assertEqual(403, response.status_code)
            else:
                self.assertEqual(200, response.status_code)
                self.assertEqual(1, len(response.json))
                self._check_json(response.json[0])
                self.assertEqual(self._dashboards["project_alert"]["id"], response.json[0]['id_dashboard'])

                # Check with enabled = false
                response = self._get_with_user_token_auth(self.test_client, token=self._users[user],
                                                          params={'id_project': 1, 'enabled': False})
                if user == "noaccess":
                    self.assertEqual(403, response.status_code)
                else:
                    self.assertEqual(200, response.status_code)
                    self.assertEqual(2, len(response.json))

    def _check_json(self, json_data: str, minimal=False):
        self.assertTrue(json_data.__contains__('id_dashboard'))
        self.assertTrue(json_data.__contains__('dashboard_uuid'))
        self.assertTrue(json_data.__contains__('dashboard_name'))
        self.assertTrue(json_data.__contains__('dashboard_description'))
        if not minimal:
            self.assertTrue(json_data.__contains__('versions'))
        else:
            self.assertFalse(json_data.__contains__('versions'))
