import os

from urllib.parse import quote

from flask import render_template, request
from flask.views import MethodView
from flask_babel import gettext

from FlaskModule import flask_app

class Index(MethodView):
    def __init__(self, *args, **kwargs):
        print('Index.__init__', args, kwargs)
        self.flaskModule = kwargs.get('flaskModule', None)

    def get(self):
        backend_hostname = self.flaskModule.config.backend_config['hostname']
        backend_port = self.flaskModule.config.backend_config['port']

        # Look for variables set in NGINX reverse proxy...
        if 'X_EXTERNALSERVER' in request.headers:
            backend_hostname = request.headers['X_EXTERNALSERVER']

        if 'X_EXTERNALPORT' in request.headers:
            backend_port = request.headers['X_EXTERNALPORT']

        user_name = 'Anonymous'

        # Verify if static/DashboardsViewerApp.html exists
        # send default index.html if not
        if not os.path.exists('static/DashboardsViewerApp.html'):
            return flask_app.send_static_file('default_index.html')

        return render_template('login.html',
                                backend_hostname=quote(backend_hostname),
                                backend_port=quote(backend_port))

    def post(self):
        # Do something about the post data which is json format
        login_information = request.json

        backend_hostname = self.flaskModule.config.backend_config['hostname']
        backend_port = self.flaskModule.config.backend_config['port']

        # Look for variables set in NGINX reverse proxy...
        if 'X_EXTERNALSERVER' in request.headers:
            backend_hostname = request.headers['X_EXTERNALSERVER']

        if 'X_EXTERNALPORT' in request.headers:
            backend_port = request.headers['X_EXTERNALPORT']

        user_name = 'Anonymous'

        # Verify if static/DashboardsViewerApp.html exists
        # send default index.html if not
        if not os.path.exists('static/DashboardsViewerApp.html'):
            return flask_app.send_static_file('default_index.html')

        return render_template('dashboards.html',
                                backend_hostname=quote(backend_hostname),
                                backend_port=quote(backend_port),
                                user_name=quote(user_name),
                                user_token='')
