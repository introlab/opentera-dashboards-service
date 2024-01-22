from urllib.parse import quote
from flask.views import MethodView
from werkzeug.exceptions import NotFound
from flask_babel import gettext
from flask import render_template, request
from FlaskModule import flask_app
from opentera.services.ServiceAccessManager import ServiceAccessManager, current_user_client

class DashboardsIndex(MethodView):
    def __init__(self, *args, **kwargs):
        self.flaskModule = kwargs.get('flaskModule', None)

    # @ServiceAccessManager.token_required(allow_static_tokens=False, allow_dynamic_tokens=True)
    def get(self):
        backend_hostname = self.flaskModule.config.backend_config['hostname']
        backend_port = self.flaskModule.config.backend_config['port']

        # Look for variables set in NGINX reverse proxy...
        if 'X_EXTERNALSERVER' in request.headers:
            backend_hostname = request.headers['X_EXTERNALSERVER']

        if 'X_EXTERNALPORT' in request.headers:
            backend_port = request.headers['X_EXTERNALPORT']

        user_name = 'Anonymous'

        # Make sure we are connecting as user
        # Beware of is None comparison because current_user_client is a proxy. It is never None, even if the user is.
        if False:
            if current_user_client != None:

                user_info = current_user_client.get_user_info()
                if user_info and 'user_name' in user_info:
                    user_name = user_info['user_name']

                return render_template('dashboards.html',
                                        backend_hostname=quote(backend_hostname),
                                        backend_port=quote(backend_port),
                                        user_name=quote(user_name),
                                        user_token=current_user_client.user_token)
            else:
                return gettext('Unauthorized'), 403
        else:
            return render_template('dashboards.html',
                                    backend_hostname=quote(backend_hostname),
                                    backend_port=quote(backend_port),
                                    user_name=quote(user_name),
                                    user_token='')
