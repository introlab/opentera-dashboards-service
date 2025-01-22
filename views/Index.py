import os
import json
from urllib.parse import quote
from flask import render_template, request, redirect, session
from flask.views import MethodView
from flask_babel import gettext

from FlaskModule import flask_app

class Index(MethodView):
    def __init__(self, *args, **kwargs):
        print('Index.__init__', args, kwargs)
        self.flaskModule = kwargs.get('flaskModule', None)
        self.service = kwargs.get('service', None)

    def get(self):
        # Get auth code
        if 'auth_code' in request.args:
            auth_code = request.args['auth_code']
            redis_auth_data = self.flaskModule.redisGet('service_auth_code_' + auth_code)
            if not redis_auth_data:
                # User has likely hit the refresh button on the browser
                # We will reload the page and get a new auth code and start the login process.
                # return gettext('Invalid auth code'), 403
                return redirect('/dashboards')
            auth_data = json.loads(redis_auth_data)
            if 'service_uuid' not in auth_data or auth_data['service_uuid'] != self.service.service_uuid:
                return gettext('Invalid auth code'), 403

            if 'user_data' not in auth_data:
                return gettext('Invalid auth data'), 400

            user_data = auth_data['user_data']
            self.flaskModule.redisDelete('service_auth_code_' + auth_code)

            backend_hostname = self.flaskModule.config.backend_config['hostname']
            backend_port = self.flaskModule.config.backend_config['port']

            # Look for variables set in NGINX reverse proxy...
            if 'X_EXTERNALSERVER' in request.headers:
                backend_hostname = request.headers['X_EXTERNALSERVER']

            if 'X_EXTERNALPORT' in request.headers:
                backend_port = request.headers['X_EXTERNALPORT']

            # Verify if static/DashboardsViewerApp.html exists
            # send default index.html if not
            if not os.path.exists('static/DashboardsViewerApp.html'):
                return flask_app.send_static_file('default_index.html')

            return render_template('dashboards.html',
                                   backend_hostname=quote(backend_hostname),
                                   backend_port=quote(backend_port),
                                   user_token=user_data['user_token'],
                                   user_name=user_data['user_fullname'])

        else:
            if self.service:
                response = self.service.get_from_opentera('/api/service/auth/code', params={'endpoint_url': '/'})
                if response.status_code == 200:
                    auth_code = response.json()['auth_code']
                    return redirect('/login?auth_code=' + auth_code + '&with_websocket=false')

        return gettext('Forbidden'), 403

        # user_name = 'Anonymous'
        #
        # # Verify if static/DashboardsViewerApp.html exists
        # # send default index.html if not
        # if not os.path.exists('static/DashboardsViewerApp.html'):
        #     return flask_app.send_static_file('default_index.html')
        #
        # return render_template('login.html',
        #                         backend_hostname=quote(backend_hostname),
        #                         backend_port=quote(backend_port))

    # def post(self):
    #     # Do something about the post data which is json format
    #     login_information = request.json
    #
    #     backend_hostname = self.flaskModule.config.backend_config['hostname']
    #     backend_port = self.flaskModule.config.backend_config['port']
    #
    #     # Look for variables set in NGINX reverse proxy...
    #     if 'X_EXTERNALSERVER' in request.headers:
    #         backend_hostname = request.headers['X_EXTERNALSERVER']
    #
    #     if 'X_EXTERNALPORT' in request.headers:
    #         backend_port = request.headers['X_EXTERNALPORT']
    #
    #     user_name = 'Anonymous'
    #
    #     # Verify if static/DashboardsViewerApp.html exists
    #     # send default index.html if not
    #     if not os.path.exists('static/DashboardsViewerApp.html'):
    #         return flask_app.send_static_file('default_index.html')
    #
    #     return render_template('dashboards.html',
    #                             backend_hostname=quote(backend_hostname),
    #                             backend_port=quote(backend_port),
    #                             user_name=quote(user_name),
    #                             user_token='')
