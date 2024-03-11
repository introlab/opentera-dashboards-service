import os
import subprocess
import sys
import argparse
import time

import requests
from requests.auth import _basic_auth_str
from opentera.db.models.TeraSessionType import TeraSessionType

service_key = 'DashboardsService'

# TODO Change Authorization user and server_url
headers = {'Authorization': _basic_auth_str('admin', 'admin')}
#server_url = 'https://127.0.0.1:40100'
server_url = 'https://proxy:40100'

required_roles = ['dashboards_admin']


required_user_groups = ['Dashboards_admin']

def _get_service(key: str) -> dict:
    params = {
        'service_key': key
    }
    response = requests.get(url=server_url + '/api/user/services',
                            headers=headers,params=params, verify=False, timeout=5)
    if response.status_code != 200:
        print(f'Error getting service {key}')
        return {}
    return response.json()[0]

def create_user_roles_and_user_groups(service_info: dict) -> bool:

    if len(required_roles) != len(required_user_groups):
        print("Error: roles and user groups must have the same number of elements!")
        return False

    roles = []
    groups = []

    # Setup roles
    for role in required_roles:
        json_data = {
            "service_role": {
                "id_service": service_info['id_service'],
                "id_service_role": 0, #new
                "service_role_name": role
            }
        }

        response = requests.post(url=server_url + '/api/user/services/roles',
                                 headers=headers, json=json_data, verify=False, timeout=5)
        if response.status_code != 200:
            return False

        roles.append(response.json())

    # Setup groups
    for group in required_user_groups:
        json_data = {
            "user_group": {
                "id_user_group": 0, # new
                "user_group_name": group,
            }
        }
        response = requests.post(url=server_url + '/api/user/usergroups',
                                 headers=headers, json=json_data, verify=False, timeout=5)
        if response.status_code != 200:
            return False

        groups.append(response.json()[0])

     # Setup Service Roles for user group
    for group, role in zip(groups, roles):
        json_data = {
            "service_access": {
                "id_service_access": 0, #new
                "id_user_group": group['id_user_group'],
                "id_service_role": role['id_service_role']
            }
        }

        response = requests.post(url=server_url + '/api/user/services/access',
                                 headers=headers, json=json_data, verify=False, timeout=5)
        if response.status_code != 200:
            return False

    return True

if __name__ == '__main__':

    print('Staring Dashboards Service setup...')

    params = {'service_key': service_key}
    response = requests.get(url=server_url + '/api/user/services',
                            headers=headers,params=params,verify=False, timeout=30)

    if response.status_code == 200:

        if len(response.json()) == 0:
            # Create service
            print('Creating service : ', service_key)
            json_data = {
                    'service': {
                            "id_service": 0,
                            "service_clientendpoint": "/dashboards",
                            "service_enabled": True,
                            "service_endpoint": "/",
                            "service_hostname": "dashboards-service",
                            "service_name": "DashboardsService",
                            "service_port": 5055,
                            "service_key": service_key,
                            "service_endpoint_participant": "/participant",
                            "service_endpoint_user": "/user",
                            "service_endpoint_device": "/device"
                    }
            }

            response = requests.post(url=server_url + '/api/user/services',
                                     headers=headers, json=json_data, verify=False, timeout=5)
            if response.status_code != 200:
                print('Error creating service, already')
                sys.exit(-1)

            service_info = response.json()[0]

            if not create_user_roles_and_user_groups(service_info):
                sys.exit(-1)

        else:
            # service_info = response.json()[0]
            # if not create_user_roles_and_user_groups(service_info):
            #    sys.exit(-1)

            print('Service already exists, skipping...')
            sys.exit(0)

    else:
        print('Unable to communicate with server')
        sys.exit(-500)
