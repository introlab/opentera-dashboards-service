from flask import request
from flask_restx import Resource, inputs
from sqlalchemy import exc, inspect

from FlaskModule import user_api_ns as api
from libDashboards.db.models.DashDashboards import DashDashboards
from libDashboards.db.models.DashDashboardSites import DashDashboardSites
from libDashboards.db.models.DashDashboardProjects import DashDashboardProjects
from opentera.services.ServiceAccessManager import ServiceAccessManager, current_login_type, LoginType, \
    current_user_client
from flask_babel import gettext


# Parser definition(s)
# GET
get_parser = api.parser()
get_parser.add_argument('id_dashboard', type=int, help='Specific dashboard id to query information for')
get_parser.add_argument('uuid', type=str, help='Specific dashboard uuid to query information for')
get_parser.add_argument('id_site', type=int, help='ID of the site to query all dashboards for')
get_parser.add_argument('id_project', type=int, help='ID of the project to query all dashboards for')
get_parser.add_argument('globals', type=inputs.boolean, help='Query globals dashboards')

get_parser.add_argument('all_versions', type=inputs.boolean, help='Return all versions of the dashboard(s)')
get_parser.add_argument('enabled', type=inputs.boolean, help='Return only enabled versions of the dashboard(s)',
                        default=True)
get_parser.add_argument('list', type=inputs.boolean, help='Return minimal information (to display in a list, for '
                                                          'example)')

# POST
post_schema = api.schema_model('dashboard', {'properties': DashDashboards.get_json_schema(), 'type': 'object',
                                             'location': 'json'})

# DELETE
delete_parser = api.parser()
delete_parser.add_argument('id', type=int, help='ID to delete')
delete_parser.add_argument('uuid', type=int, help='UUID to delete')


class QueryDashboard(Resource):

    def __init__(self, _api, *args, **kwargs):
        Resource.__init__(self, _api, *args, **kwargs)
        self.module = kwargs.get('flaskModule', None)
        self.test = kwargs.get('test', False)

    @api.doc(description='Get dashboard information. Should specify only one id or the "globals" parameter',
             responses={200: 'Success - returns list of dashboards',
                        400: 'Required parameter is missing',
                        403: 'Logged user doesn\'t have permission to access the requested data'},
             params={'token': 'Secret token'})
    @api.expect(get_parser)
    @ServiceAccessManager.token_required(allow_static_tokens=False, allow_dynamic_tokens=True)
    def get(self):
        if current_login_type != LoginType.USER_LOGIN:
            return gettext('Only users can use this API.'), 403

        # Parse arguments
        request_args = get_parser.parse_args(strict=False)

        dashboards = []
        user_info = current_user_client.get_user_info()
        accessible_project_ids = [role['id_project'] for role in user_info['projects']]
        accessible_site_ids = [role['id_site'] for role in user_info['sites']]
        if request_args['uuid'] or request_args['id_dashboard']:
            if request_args['uuid']:
                dashboard = DashDashboards.get_by_uuid(request_args['uuid'])
            else:
                dashboard = DashDashboards.get_by_id(request_args['id_dashboard'])
            if not dashboard:
                return gettext('Forbidden'), 403  # Explicitely vague for security purpose

            dashboard_sites_ids = DashDashboardSites.get_sites_ids_for_dashboard(
                dashboard.id_dashboard, enabled_only=request_args['enabled'])
            if dashboard_sites_ids:
                # Check that we have a match for at least one site
                if len(set(accessible_site_ids).intersection(dashboard_sites_ids)) == 0:
                    return gettext('Forbidden'), 403

            dashboard_proj_ids = DashDashboardProjects.get_projects_ids_for_dashboard(
                dashboard.id_dashboard, enabled_only=request_args['enabled'])
            if dashboard_proj_ids:
                # Check that we have a match for at least one project
                if len(set(accessible_project_ids).intersection(dashboard_proj_ids)) == 0:
                    return gettext('Forbidden'), 403

            if not dashboard_proj_ids and not dashboard_sites_ids:
                # Global dashboard - only for super admins
                if not current_user_client.user_superadmin:
                    return gettext('Forbidden'), 403

            dashboards = [dashboard]

        elif request_args['id_site']:
            if request_args['id_site'] not in accessible_site_ids:
                return gettext('Forbidden'), 403
            dashboards = DashDashboardSites.get_dashboards_for_site(request_args['id_site'],
                                                                    enabled_only=request_args['enabled'])

        elif request_args['id_project']:
            if request_args['id_project'] not in accessible_project_ids:
                return gettext('Forbidden'), 403
            dashboards = DashDashboardProjects.get_dashboards_for_project(request_args['id_project'],
                                                                          enabled_only=request_args['enabled'])

        elif request_args['globals']:
            if not current_user_client.user_superadmin:
                return gettext('Forbidden'), 403
            dashboards = DashDashboards.get_dashboards_globals()
        else:
            return gettext('Must specify at least one id parameter or "globals"'), 400

        # Convert to json and return
        dashboards_json = [dash.to_json(minimal=request_args['list'], latest=not request_args['all_versions'])
                           for dash in dashboards]
        return dashboards_json

    @api.expect(post_schema)
    @api.doc(description='Create or update a dashboard',
             responses={200: 'Success',
                        403: 'No access to this API',
                        400: 'Missing parameter in request'
                        },
             params={'token': 'Secret token'})
    @ServiceAccessManager.token_required(allow_static_tokens=False, allow_dynamic_tokens=True)
    def post(self):
        if current_login_type != LoginType.USER_LOGIN:
            return gettext('Only users can use this API.'), 403

        if 'dashboard' not in request.json:
            return gettext('Missing dashboard'), 400

        json_dashboard = request.json['dashboard']

        pass

        # Check if we have an uuid or an id_dashboard and load infos
        # updating = ('dashboard_uuid' in json_dashboard or
        #             ('id_dashboard' in json_dashboard and json_dashboard['id_dashboard'] > 0))
        #
        # if updating:
        #     # Load dashboard
        #     dashboard = None
        #     if 'id_dashboard' in json_dashboard and json_dashboard['id_dashboard'] > 0:
        #         dashboard = DashDashboards.get_by_id(json_dashboard['id_dashboard'])
        #         if 'dashboard_uuid' in json_dashboard and dashboard.dashboard_uuid != json_dashboard['dashboard_uuid']:
        #             return gettext('Can\'t change uuid when updating with id'), 400
        #         if ('dashboard_version' in json_dashboard and
        #                 dashboard.dashboard_version != json_dashboard['dashboard_version']):
        #             return gettext('Can\'t change version when updating with it'), 400
        #
        #     if 'dashboard_uuid' in json_dashboard:
        #         dashboard = DashDashboards.get_dashboard_by_uuid(json_dashboard['dashboard_uuid'], latest=True)
        #         # Check version - can't update an older version
        #         if 'dashboard_version' in json_dashboard:
        #             if dashboard.dashboard_version > int(json_dashboard['dashboard_version']):
        #                 return gettext('Trying to update an older dashboard version - this is not allowed.'), 400
        #         else:
        #             # Auto increment version
        #             json_dashboard['dashboard_version'] = dashboard.dashboard_version + 1
        #
        #         if json_dashboard['dashboard_version'] != dashboard.dashboard_version:
        #             # New version - must create a new dashboard id
        #             json_dashboard['id_dashboard'] = 0
        #         else:
        #             json_dashboard['id_dashboard'] = dashboard.id_dashboard
        #
        #     if not dashboard:
        #         return gettext('Forbidden'), 403  # Explicitly vague
        #
        #     # Check access - only admins can change things...
        #     if dashboard.id_site:
        #         site_role = current_user_client.get_role_for_site(dashboard.id_site)
        #         if site_role != 'admin':
        #             return gettext('No access to dashboard to update'), 403
        #
        #     if dashboard.id_project:
        #         project_role = current_user_client.get_role_for_project(dashboard.id_project)
        #         if project_role != 'admin':
        #             return gettext('No access to dashboard to update'), 403
        #
        #     if not dashboard.id_project and not dashboard.id_site:
        #         if not current_user_client.user_superadmin:
        #             return gettext('No access to dashboard to update'), 403
        #
        #     # Check access to updated data
        #     if 'id_site' in json_dashboard and json_dashboard['id_site'] != dashboard.id_site:
        #         site_role = current_user_client.get_role_for_site(json_dashboard['id_site'])
        #         if site_role != 'admin':
        #             return gettext('No access to dashboard site'), 403
        #
        #     if 'id_project' in json_dashboard and json_dashboard['id_project'] != dashboard.id_project:
        #         project_role = current_user_client.get_role_for_project(json_dashboard['id_project'])
        #         if project_role != 'admin':
        #             return gettext('No access to dashboard project'), 403
        #
        #     if ('id_project' not in json_dashboard and 'id_site' not in json_dashboard and
        #             (dashboard.id_site or dashboard.id_project)):
        #         if not current_user_client.user_superadmin:
        #             return gettext('No access to global dashboard'), 403
        #
        # if json_dashboard['id_dashboard'] > 0:
        #     # Update the dashboard
        #     try:
        #         DashDashboards.update(json_dashboard['id_dashboard'], json_dashboard)
        #     except exc.SQLAlchemyError as e:
        #         import sys
        #         print(sys.exc_info())
        #         self.module.logger.log_error(self.module.module_name,
        #                                      QueryDashboard.__name__,
        #                                      'post', 500, 'Database error', str(e))
        #         return gettext('Database error'), 500
        # else:
        #     # New dashboard
        #     try:
        #         new_dashboard = DashDashboards()
        #         new_dashboard.from_json(json_dashboard)
        #         DashDashboards.insert(new_dashboard)
        #         # Update ID for further use
        #         json_dashboard['id_dashboard'] = new_dashboard.id_dashboard
        #
        #     except exc.SQLAlchemyError as e:
        #         import sys
        #         print(sys.exc_info())
        #         self.module.logger.log_error(self.module.module_name,
        #                                      DashDashboards.__name__,
        #                                      'post', 400, 'Database error', str(e))
        #         return gettext('Database error'), 400
        #
        # return DashDashboards.get_by_id(json_dashboard['id_dashboard']).to_json()

    @api.expect(delete_parser, validate=True)
    @api.doc(description='Delete a dashboard',
             responses={200: 'Success - deleted',
                        400: 'Bad request',
                        403: 'Access denied'},
             params={'token': 'Secret token'})
    @ServiceAccessManager.token_required(allow_static_tokens=False, allow_dynamic_tokens=True)
    def delete(self):
        if current_login_type != LoginType.USER_LOGIN:
            return gettext('Only users can use this API.'), 403

        args = delete_parser.parse_args()

        if args['id']:
            pass
