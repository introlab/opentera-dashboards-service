from tests.BaseDashboardsAPITest import BaseDashboardsAPITest
from libDashboards.db.models import DashDashboards
from libDashboards.db.models.DashDashboardVersions import DashDashboardVersions
from libDashboards.db.models.DashDashboardSites import DashDashboardSites
from libDashboards.db.models.DashDashboardProjects import DashDashboardProjects


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

    def test_post_and_delete_new_global(self):
        with self.app_context():
            dashboard = {}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)  # Missing "dashboard" definition

            dashboard = {'dashboard': {}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)  # Missing "dashboard definition"

            dashboard = {'dashboard': {'dashboard_definition': '{invalid=0}'}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # Forbidden since not super admin

            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)  # Missing dashboard name

            dashboard['dashboard'] = {'dashboard_definition': '{invalid=0', 'dashboard_name': 'Test Dashboard'}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)

            dashboard['dashboard']['dashboard_definition'] = '{"invalid": 0}'
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            self._check_json(response.json)

            # Try to delete
            id_to_del = response.json['id_dashboard']
            delete_params = {'id': id_to_del}
            response = self._delete_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                         params=delete_params)
            self.assertEqual(403, response.status_code)  # Global dashboard = deletable only by superadmins

            response = self._delete_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                         params=delete_params)
            self.assertEqual(200, response.status_code)

    def test_post_and_delete_update_global(self):
        with self.app_context():
            global_dashs = DashDashboards.get_dashboards_globals()
            global_dash_id = global_dashs[0].id_dashboard
            global_dash_uuid = global_dashs[0].dashboard_uuid
            global_latest_version = global_dashs[0].dashboard_versions[-1].dashboard_version
            dashboard = {'dashboard': {'id_dashboard': 4567}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # Unknown dashboard

            dashboard = {'dashboard': {'id_dashboard': global_dash_id, 'dashboard_uuid': '12345'}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)  # Can't change uuid if id

            dashboard = {'dashboard': {'id_dashboard': 11, 'dashboard_uuid': global_dash_uuid}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)  # Can't change id if uuid

            dashboard = {'dashboard': {'id_dashboard': global_dash_id}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # Can't access global dashboard

            dashboard = {'dashboard': {'id_dashboard': global_dash_id, 'dashboard_version': 0}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)  # Can't update older version

            dashboard = {'dashboard': {'id_dashboard': global_dash_id, 'dashboard_version': global_latest_version,
                                       'dashboard_name': 'Global New Name'}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)  # Was updated
            updated = DashDashboards.get_by_id(global_dash_id)
            self.assertEqual('Global New Name', updated.dashboard_name)

            dashboard = {'dashboard': {'id_dashboard': global_dash_id, 'dashboard_definition': '{"definition": 33}'}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)  # Was updated
            updated = DashDashboards.get_by_id(global_dash_id)
            self.assertEqual(global_latest_version+1, updated.dashboard_versions[-1].dashboard_version)
            self.assertEqual('{"definition": 33}', updated.dashboard_versions[-1].dashboard_definition)

            # Manually remove latest version
            DashDashboardVersions.delete(updated.dashboard_versions[-1].id_dashboard_version)

    def test_post_and_delete_new_site(self):
        with self.app_context():
            # Don't retest what was tested before...
            dashboard = {'dashboard': {'dashboard_name': 'Test Site Dashboard',
                                       'dashboard_definition': '{"bla": "bla"}',
                                       'dashboard_sites': [{'id_site': 3}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # Unavailable site for the user

            dashboard['dashboard']['dashboard_sites'] = [{'id_site': 1}]
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            self._check_json(response.json)
            updated = DashDashboards.get_by_id(response.json['id_dashboard'])
            self.assertTrue(len(updated.dashboard_sites) == 1)
            self.assertEqual(1, updated.dashboard_sites[-1].id_site)

            # Remove currently added dashboard
            id_to_del = response.json['id_dashboard']
            delete_params = {'id': id_to_del}
            response = self._delete_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                         params=delete_params)
            self.assertEqual(200, response.status_code)

    def test_post_and_delete_update_site(self):
        with self.app_context():
            # Note: Tests common for updating are done in the "global dashboard" tests
            site_dashboards = [dash.dashboard_site_dashboard for dash in DashDashboardSites.get_dashboards_for_site(1)]
            site_id_dashboard = site_dashboards[0].id_dashboard
            dashboard = {'dashboard': {'id_dashboard': site_id_dashboard}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['projectadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # Can't access this site dashboard

            dashboard = {'dashboard': {'id_dashboard': site_id_dashboard, 'dashboard_name': 'Site New Name'}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)  # Was updated
            updated = DashDashboards.get_by_id(site_id_dashboard)
            self.assertEqual('Site New Name', updated.dashboard_name)

            # Add new site to dashboard
            dashboard = {'dashboard': {'id_dashboard': site_id_dashboard,
                                       'dashboard_sites': [{'id_site': 1}, {'id_site': 2}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # No access to site 2

            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(site_id_dashboard)
            self.assertEqual(2, len(updated.dashboard_sites))
            for dds in updated.dashboard_sites:
                self.assertTrue(dds.id_site in [1, 2])

            # Try to associate both site and projects
            dashboard = {'dashboard': {'id_dashboard': site_id_dashboard,
                                       'dashboard_sites': [{'id_site': 1}],
                                       'dashboard_projects': [{'id_project': 1}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(400, response.status_code)  # No can do

            # Try to disable one site dashboard
            dashboard = {'dashboard': {'id_dashboard': site_id_dashboard,
                                       'dashboard_sites': [{'id_site': 1, 'dashboard_site_enabled': False}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(site_id_dashboard)
            for dds in updated.dashboard_sites:
                if dds.id_site == 1:
                    self.assertFalse(dds.dashboard_site_enabled)

            # Remove one site from dashboard
            dashboard = {'dashboard': {'id_dashboard': site_id_dashboard,
                                       'dashboard_sites': []}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(site_id_dashboard)
            self.assertEqual(1, len(updated.dashboard_sites))    # Site #2 not removed
            self.assertEqual(2, updated.dashboard_sites[0].id_site)
            dashboard = {'dashboard': {'id_dashboard': site_id_dashboard,
                                       'dashboard_sites': [{'id_site': 1, 'dashboard_site_enabled': True}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(site_id_dashboard)
            self.assertEqual(1, len(updated.dashboard_sites))  # Back to normal
            self.assertEqual(1, updated.dashboard_sites[0].id_site)

    def test_post_and_delete_new_project(self):
        with self.app_context():
            # Don't retest what was tested before...
            dashboard = {'dashboard': {'dashboard_name': 'Test Project Dashboard',
                                       'dashboard_definition': '{"bla": "bla"}',
                                       'dashboard_projects': [{'id_project': 3}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['projectadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # Unavailable for the user

            dashboard['dashboard']['dashboard_projects'] = [{'id_project': 1}]
            response = self._post_with_user_token_auth(self.test_client, token=self._users['projectadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            self._check_json(response.json)
            updated = DashDashboards.get_by_id(response.json['id_dashboard'])
            self.assertTrue(len(updated.dashboard_projects) == 1)
            self.assertEqual(1, updated.dashboard_projects[-1].id_project)

            # Remove currently added dashboard
            id_to_del = response.json['id_dashboard']
            delete_params = {'id': id_to_del}
            response = self._delete_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                         params=delete_params)
            self.assertEqual(200, response.status_code)

    def test_post_and_delete_update_project(self):
        with self.app_context():
            # Note: Tests common for updating are done in the "global dashboard" tests
            proj_dashboards = [dash.dashboard_project_dashboard
                               for dash in DashDashboardProjects.get_dashboards_for_project(1)]
            proj_id_dashboard = proj_dashboards[0].id_dashboard
            dashboard = {'dashboard': {'id_dashboard': proj_id_dashboard}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['user'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # Can't access this dashboard

            dashboard = {'dashboard': {'id_dashboard': proj_id_dashboard, 'dashboard_name': 'Project New Name'}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['projectadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)  # Was updated
            updated = DashDashboards.get_by_id(proj_id_dashboard)
            self.assertEqual('Project New Name', updated.dashboard_name)

            # Add new project to dashboard
            dashboard = {'dashboard': {'id_dashboard': proj_id_dashboard,
                                       'dashboard_projects': [{'id_project': 1}, {'id_project': 2}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['projectadmin'],
                                                       json=dashboard)
            self.assertEqual(403, response.status_code)  # No access to site 2

            response = self._post_with_user_token_auth(self.test_client, token=self._users['siteadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(proj_id_dashboard)
            self.assertEqual(2, len(updated.dashboard_projects))
            for ddp in updated.dashboard_projects:
                self.assertTrue(ddp.id_project in [1, 2])

            # Try to force a version dashboard
            dashboard = {'dashboard': {'id_dashboard': proj_id_dashboard,
                                       'dashboard_projects': [{'id_project': 1, 'dashboard_project_version': 3}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['projectadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(proj_id_dashboard)
            for ddp in updated.dashboard_projects:
                if ddp.id_project == 1:
                    self.assertEqual(3, ddp.dashboard_project_version)

            # Remove one site from dashboard
            dashboard = {'dashboard': {'id_dashboard': proj_id_dashboard,
                                       'dashboard_projects': []}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['projectadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(proj_id_dashboard)
            self.assertEqual(1, len(updated.dashboard_projects))    # Project #2 not removed
            self.assertEqual(2, updated.dashboard_projects[0].id_project)
            dashboard = {'dashboard': {'id_dashboard': proj_id_dashboard,
                                       'dashboard_projects': [{'id_project': 1, 'dashboard_project_version': None}]}}
            response = self._post_with_user_token_auth(self.test_client, token=self._users['superadmin'],
                                                       json=dashboard)
            self.assertEqual(200, response.status_code)
            updated = DashDashboards.get_by_id(proj_id_dashboard)
            self.assertEqual(1, len(updated.dashboard_projects))  # Back to normal
            self.assertEqual(1, updated.dashboard_projects[0].id_project)

    def _check_json(self, json_data: str, minimal=False):
        self.assertTrue(json_data.__contains__('id_dashboard'))
        self.assertTrue(json_data.__contains__('dashboard_uuid'))
        self.assertTrue(json_data.__contains__('dashboard_name'))
        self.assertTrue(json_data.__contains__('dashboard_description'))
        if not minimal:
            self.assertTrue(json_data.__contains__('versions'))
        else:
            self.assertFalse(json_data.__contains__('versions'))
