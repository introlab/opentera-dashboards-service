from flask import request
from flask_restx import Resource, inputs
from sqlalchemy import exc, inspect

from FlaskModule import user_api_ns as api
from libDashboards.db.models.DashDashboards import DashDashboards
from libDashboards.db.models.DashDashboardSites import DashDashboardSites
from libDashboards.db.models.DashDashboardProjects import DashDashboardProjects
from libDashboards.db.models.DashDashboardVersions import DashDashboardVersions
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
get_parser.add_argument('enabled', type=inputs.boolean, help='Return only enabled versions of the dashboard(s)')
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

    @api.doc(description='Get dashboard information. Should specify only one id or the "globals" parameter, or else '
                         'will return all accessible dashboards.',
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
            # return gettext('Must specify at least one id parameter or "globals"'), 400
            if current_user_client.user_superadmin:
                # dashboards = DashDashboards.get_all_non_globals_dashboards()
                dashboards = DashDashboards.query.order_by(DashDashboards.dashboard_name.asc()).all()
            else:
                dashboards = DashDashboards.get_dashboards(accessible_site_ids, accessible_project_ids)

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

        # Check if we have an uuid or an id_dashboard and load infos
        updating = ('dashboard_uuid' in json_dashboard or
                    ('id_dashboard' in json_dashboard and json_dashboard['id_dashboard'] > 0))

        user_info = current_user_client.get_user_info()
        accessible_project_ids = [role['id_project'] for role in user_info['projects']
                                  if role['project_role'] == 'admin']
        accessible_site_ids = [role['id_site'] for role in user_info['sites'] if role['site_role'] == 'admin']
        dashboard = None
        if updating:
            # Load dashboard
            if 'id_dashboard' in json_dashboard and json_dashboard['id_dashboard'] > 0:
                dashboard = DashDashboards.get_by_id(json_dashboard['id_dashboard'])
                if (dashboard and 'dashboard_uuid' in json_dashboard and
                        dashboard.dashboard_uuid != json_dashboard['dashboard_uuid']):
                    return gettext('Can\'t change uuid when updating with id'), 400

            if 'dashboard_uuid' in json_dashboard:
                dashboard = DashDashboards.get_by_uuid(json_dashboard['dashboard_uuid'])
                if (dashboard and 'id_dashboard' in json_dashboard and
                        dashboard.id_dashboard != json_dashboard['id_dashboard']):
                    return gettext('Can\'t change id when updating with uuid'), 400

            if not dashboard:
                return gettext('Forbidden'), 403  # Explicitly vague

            # Check access - only admins can change things...
            dashboard_sites_ids = [dash_site.id_site for dash_site in dashboard.dashboard_sites]
            dashboard_projects_ids = [dash_proj.id_project for dash_proj in dashboard.dashboard_projects]

            if dashboard_sites_ids:
                # Check that we have a match for at least one project
                if len(set(accessible_site_ids).intersection(dashboard_sites_ids)) == 0:
                    return gettext('No access to dashboard to update'), 403

            if dashboard_projects_ids:
                # Check that we have a match for at least one project
                if len(set(accessible_project_ids).intersection(dashboard_projects_ids)) == 0:
                    return gettext('No access to dashboard to update'), 403

            if not dashboard_projects_ids and not dashboard_sites_ids:
                if not current_user_client.user_superadmin:
                    return gettext('No access to dashboard to update'), 403

            # Check version - can't update an older version
            if 'dashboard_version' in json_dashboard:
                latest_version = dashboard.dashboard_versions[-1].dashboard_version
                if latest_version > int(json_dashboard['dashboard_version']):
                    return gettext('Trying to update an older dashboard version - this is not allowed.'), 400
            else:
                # Auto increment version if not present in the query field
                json_dashboard['dashboard_version'] = len(dashboard.dashboard_versions) + 1
        else:
            # New dashboard
            if 'dashboard_definition' not in json_dashboard:
                return gettext('Missing definition for new dashboard'), 400
            # Always version 1 on new dashboard
            json_dashboard['dashboard_version'] = 1

        # Check access to updated data
        dashboard_sites = None
        dashboard_sites_ids = []
        dashboard_projects = None
        dashboard_projects_ids = []
        if 'dashboard_sites' in json_dashboard:
            dashboard_sites = json_dashboard.pop('dashboard_sites')
            dashboard_sites_ids = [site['id_site'] for site in dashboard_sites]
            if len(set(accessible_site_ids).intersection(dashboard_sites_ids)) == 0 and dashboard_sites_ids:
                return gettext('No admin access to that dashboard'), 403
            for site in dashboard_sites:
                if site['id_site'] not in accessible_site_ids:
                    return gettext('At least one site isn\'t accessible'), 403

        if 'dashboard_projects' in json_dashboard:
            dashboard_projects = json_dashboard.pop('dashboard_projects')
            dashboard_projects_ids = [proj['id_project'] for proj in dashboard_projects]
            if len(set(accessible_project_ids).intersection(dashboard_projects_ids)) == 0 and dashboard_projects_ids:
                return gettext('No admin access to that dashboard'), 403
            for proj in dashboard_projects:
                if proj['id_project'] not in accessible_project_ids:
                    return gettext('At least one project isn\'t accessible'), 403

        if not updating and not dashboard_sites and not dashboard_projects:
            # Global new dashboard - only super admin can create
            if not current_user_client.user_superadmin:
                return gettext('Forbidden'), 403

        if dashboard_sites and dashboard_projects:
            return gettext('A dashboard can\'t be associated to both sites and projects'), 400

        # Pop dashboard definition and version
        dashboard_version = json_dashboard.pop('dashboard_version')
        dashboard_definition = None
        if 'dashboard_definition' in json_dashboard:
            dashboard_definition = json_dashboard.pop('dashboard_definition')

        if updating:
            # Update the dashboard
            try:
                DashDashboards.update(json_dashboard['id_dashboard'], json_dashboard)
            except exc.SQLAlchemyError as e:
                import sys
                print(sys.exc_info())
                self.module.logger.log_error(self.module.module_name,
                                             QueryDashboard.__name__,
                                             'post', 500, 'Database error', str(e))
                return gettext('Database error'), 500
        else:
            # New dashboard
            try:
                missing_fields = DashDashboards.validate_required_fields(json_dashboard)
                if missing_fields:
                    return gettext('Missing fields') + ': ' + str(missing_fields), 400

                dashboard = DashDashboards()
                dashboard.from_json(json_dashboard)
                DashDashboards.insert(dashboard)
                # Update ID for further use
                json_dashboard['id_dashboard'] = dashboard.id_dashboard

            except exc.SQLAlchemyError as e:
                import sys
                print(sys.exc_info())
                self.module.logger.log_error(self.module.module_name,
                                             DashDashboards.__name__,
                                             'post', 400, 'Database error', str(e))
                return gettext('Database error'), 400

        # Manage sites
        if dashboard_sites or dashboard_sites == []:
            # Add / update existing sites
            current_sites_ids = [site.id_site for site in dashboard.dashboard_sites]

            for site in dashboard_sites:
                # Check if already there
                if site['id_site'] in current_sites_ids:
                    # Update
                    dds = DashDashboardSites.get_for_site_and_dashboard(site['id_site'], dashboard.id_dashboard)
                    DashDashboardSites.update(dds.id_dashboard_site, site)

                else:
                    # Add
                    dds = DashDashboardSites()
                    dds.from_json(site)
                    dds.id_dashboard = dashboard.id_dashboard
                    DashDashboardSites.insert(dds)

            # Remove sites not present in the list
            to_remove_ids = set(accessible_site_ids).difference(dashboard_sites_ids)
            for remove_id in to_remove_ids:
                if remove_id in current_sites_ids:
                    dds = DashDashboardSites.get_for_site_and_dashboard(remove_id, dashboard.id_dashboard)
                    DashDashboardSites.delete(dds.id_dashboard_site)

        # Manage dashboard projects
        if dashboard_projects or dashboard_projects == []:
            # Add / update existing projects
            current_proj_ids = [proj.id_project for proj in dashboard.dashboard_projects]

            for proj in dashboard_projects:
                # Check if already there
                if proj['id_project'] in current_proj_ids:
                    # Update
                    ddp = DashDashboardProjects.get_for_project_and_dashboard(proj['id_project'],
                                                                              dashboard.id_dashboard)
                    DashDashboardProjects.update(ddp.id_dashboard_project, proj)
                else:
                    # Add
                    ddp = DashDashboardProjects()
                    ddp.from_json(proj)
                    ddp.id_dashboard = dashboard.id_dashboard
                    DashDashboardProjects.insert(ddp)

            # Remove not present in the list
            to_remove_ids = set(accessible_project_ids).difference(dashboard_projects_ids)
            for remove_id in to_remove_ids:
                if remove_id in current_proj_ids:
                    ddp = DashDashboardProjects.get_for_project_and_dashboard(remove_id, dashboard.id_dashboard)
                    DashDashboardProjects.delete(ddp.id_dashboard_project)

        # Manage versions
        if dashboard_version and dashboard_definition:
            # Check if exising version to update
            ddv = DashDashboardVersions.get_for_dashboard_and_version(json_dashboard['id_dashboard'], dashboard_version)
            try:
                if ddv:
                    # Update definition
                    DashDashboardVersions.update(ddv.id_dashboard_version,
                                                 {'dashboard_definition': dashboard_definition})
                else:
                    # Create new
                    ddv = DashDashboardVersions()
                    ddv.id_dashboard = json_dashboard['id_dashboard']
                    ddv.dashboard_version = dashboard_version
                    ddv.dashboard_definition = dashboard_definition
                    DashDashboardVersions.insert(ddv)
            except ValueError:
                # Bad json
                return gettext('Invalid version definition - json not valid'), 400
            except exc.SQLAlchemyError:
                return gettext('Unable to update dashboard version'), 400

        return DashDashboards.get_by_id(json_dashboard['id_dashboard']).to_json()

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

        if not args['id'] and not args['uuid']:
            return gettext('Missing parameter'), 400

        if args['id'] and args['uuid']:
            return gettext('Can\'t specify both id and uuid'), 400

        dashboard = None
        if args['id']:
            dashboard = DashDashboards.get_by_id(args['id'])
        elif args['uuid']:
            dashboard = DashDashboards.get_by_uuid(args['uuid'])

        if not dashboard:
            return gettext('Forbidden'), 403  # Explicitely vague for security purpose

        # Check deletion access
        user_info = current_user_client.get_user_info()
        accessible_project_ids = [role['id_project'] for role in user_info['projects']
                                  if role['project_role'] == 'admin']
        accessible_site_ids = [role['id_site'] for role in user_info['sites'] if role['site_role'] == 'admin']
        dashboard_sites_ids = [dash_site.id_site for dash_site in dashboard.dashboard_sites]
        dashboard_projects_ids = [dash_proj.id_project for dash_proj in dashboard.dashboard_projects]

        if dashboard_sites_ids:
            # Check that we have a match for at least one project
            if len(set(accessible_site_ids).intersection(dashboard_sites_ids)) == 0:
                return gettext('Forbidden'), 403

        if dashboard_projects_ids:
            # Check that we have a match for at least one project
            if len(set(accessible_project_ids).intersection(dashboard_projects_ids)) == 0:
                return gettext('Forbidden'), 403

        if not dashboard_projects_ids and not dashboard_sites_ids:
            if not current_user_client.user_superadmin:
                return gettext('Forbidden'), 403

        # Ok, we are here and we have access... so delete!
        try:
            DashDashboards.delete(id_todel=dashboard.id_dashboard)
        except exc.SQLAlchemyError as e:
            import sys
            print(sys.exc_info())
            return gettext('Database error'), 400

        return '', 200
