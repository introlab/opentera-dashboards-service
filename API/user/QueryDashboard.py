from flask import request
from flask_restx import Resource, inputs
from sqlalchemy import exc, inspect

from FlaskModule import user_api_ns as api
from libDashboards.db.models.DashDashboards import DashDashboards
from opentera.services.ServiceAccessManager import ServiceAccessManager, current_login_type, LoginType, \
    current_user_client
from flask_babel import gettext


# Parser definition(s)
# GET
get_parser = api.parser()
get_parser.add_argument('uuid', type=str, help='Specific dashboard uuid to query information for.')
get_parser.add_argument('id_site', type=int, help='ID of the site to query all dashboards for')
get_parser.add_argument('id_project', type=int, help='ID of the project to query all dashboards for')
get_parser.add_argument('globals', type=inputs.boolean, help='Query globals dashboards')

get_parser.add_argument('all_versions', type=inputs.boolean, help='Return all versions of the dashboard(s)')
get_parser.add_argument('list', type=inputs.boolean, help='Return minimal information (to display in a list, for '
                                                          'example)')

# POST
post_schema = api.schema_model('criteria', {'properties': DashDashboards.get_json_schema(), 'type': 'object',
                                            'location': 'json'})

# DELETE
delete_parser = api.parser()
delete_parser.add_argument('id', type=int, help='ID to delete')


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
        if 'uuid' in request_args:
            dashboard = DashDashboards.get_dashboard_by_uuid(request_args['uuid'])
            if not dashboard:
                return gettext('Forbidden'), 403  # Explicitely vague for security purpose

            if dashboard.id_site:
                site_role = current_user_client.get_role_for_site(dashboard.id_site)
                if site_role == 'Undefined':
                    return gettext('Forbidden'), 403
            if dashboard.id_project:
                project_role = current_user_client.get_role_for_project(dashboard.id_project)
                if project_role == 'Undefined':
                    return gettext('Forbidden'), 403

            if not dashboard.id_project and not dashboard.id_site:
                # Global dashboard - only for super admins
                if not current_user_client.user_superadmin:
                    return gettext('Forbidden'), 403
            dashboards = [dashboard]

        elif 'id_site' in request_args:
            site_role = current_user_client.get_role_for_site(request_args['id_site'])
            if site_role == 'Undefined':
                return gettext('Forbidden'), 403
            dashboards = DashDashboards.get_dashboards_for_site(request_args['id_site'])

        elif 'id_project' in request_args:
            project_role = current_user_client.get_role_for_project(request_args['id_project'])
            if project_role == 'Undefined':
                return gettext('Forbidden'), 403
            dashboards = DashDashboards.get_dashboards_for_project(request_args['id_project'])

        elif request_args['globals']:
            if not current_user_client.user_superadmin:
                return gettext('Forbidden'), 403
            dashboards = DashDashboards.get_dashboards_globals()
        else:
            return gettext('Must specify at least one id parameter or "globals"')

        # Convert to json and return
        dashboards_json = [dash.to_json(request_args['list']) for dash in dashboards]
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
