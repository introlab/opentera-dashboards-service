import os
import subprocess
import sys
import argparse
import time
from datetime import datetime, timedelta
import requests
from requests.auth import _basic_auth_str
from opentera.db.models.TeraSessionType import TeraSessionType
from typing import List
from io import BytesIO
import json

service_key = 'DashboardsService'

# TODO Change Authorization user and server_url
headers = {'Authorization': _basic_auth_str('admin', 'admin')}
#server_url = 'https://127.0.0.1:40100'
server_url = 'https://proxy:40100'

# Number of participants to create
NB_PARTICIPANTS = 10

# Number of sessions to create per participant
NB_SESSIONS_PER_PARTICIPANT = 5

# Number of assets to create per session
NB_ASSETS_PER_SESSION = 5


def login():
        # Login
        params = {'with_websocket': False}
        response = requests.get(url=server_url + '/api/user/login', headers=headers, params=params, verify=False, timeout=5)
        if response.status_code == 200:
            return response.json()
        return None


def create_assets(service_info: dict, sessions: List[dict]) -> list:

    assets = []

    for session_info in sessions:

        #Get all assets for session
        params = {
            'id_session': session_info['id_session']
        }


        response = requests.get(url=server_url + '/api/user/assets', headers=headers, params=params, verify=False, timeout=5)
        if response.status_code == 200:
            existing_assets = response.json()
            for asset in existing_assets:
                assets.append(asset)

            if len(existing_assets) < NB_ASSETS_PER_SESSION:
                # Add assets if needed
                for i in range(len(existing_assets), NB_ASSETS_PER_SESSION):
                    # Call the FileTransferService API to create the asset
                    payload={'file_asset': json.dumps({"id_session": session_info['id_session'], 'asset_name': f'filename_{i}.dat'})}

                    # Generate random 1Mb of data in ram
                    data = os.urandom(1024*1024)
                    # Make it readable wity byteio
                    
                    data = BytesIO(data)
                    
                    files=[
                        ('file',(f'filename_{i}.dat',data,'application/octet-stream'))
                    ]

                    login_info: dict = login()

                    if login_info is not None:

                        # Must use token to use filetransfer
                        token_headers = {'Authorization': 'OpenTera ' + login_info['user_token']}

                        # Call the API
                        response = requests.post(url=server_url + '/file/api/assets', headers=token_headers, files=files, 
                                                data=payload, verify=False, timeout=5)

                        if response.status_code == 200:
                            asset = response.json()
                            assets.append(asset)
                    
    return assets

def create_participants(service_info: dict, project_info: dict) -> list:
    
    participants = []

    # get all participants for project
    params = {
        'id_project': project_info['id_project']
    }

    response = requests.get(url=server_url + '/api/user/participants', headers=headers, params=params, verify=False, timeout=5)
    if response.status_code == 200:
        participants = response.json()
        
        for i in range(len(participants), NB_PARTICIPANTS):
            params = {
                'participant': {
                    'id_participant': 0,
                    'id_project': project_info['id_project'],
                    'participant_name': f'Participant{i}',
                    'participant_enabled': True
                }
            }
            response = requests.post(url=server_url + '/api/user/participants', headers=headers, json=params, verify=False, timeout=5)
            if response.status_code != 200:
                print('Error creating participant')
            else:
                participants.append(response.json()[0])
    
    return participants

def create_sessions(participants: list, session_type_info: dict, service_info: dict) -> list:

    sessions = []

    for participant in participants:

        # Get the number of sessions for this participant
        params = {
            'id_participant': participant['id_participant']
        }

        response = requests.get(url=server_url + '/api/user/sessions', headers=headers, params=params, verify=False, timeout=5)
        if response.status_code == 200:
            existing_sessions = response.json()
            for session in existing_sessions:
                sessions.append(session)


            # Add sessions if needed
            for i in range(len(existing_sessions), NB_SESSIONS_PER_PARTICIPANT):            
                # Go back i day from yesterday
                date = datetime.now() - timedelta(days=NB_SESSIONS_PER_PARTICIPANT - i - 1)

                params = {
                    'session': {
                        'id_session': 0,
                        'id_participant': participant['id_participant'],
                        'id_session_type': session_type_info['id_session_type'],
                        'id_creator_participant': participant['id_participant'],
                        'id_creator_service': service_info['id_service'],
                        'session_name': f'Session{i}',
                        'session_parameters': '',
                        'session_comments': 'automatic generation',
                        'session_duration': 30,
                        'session_start_datetime': date.isoformat(),
                        'session_status': 2, # 2 = Completed
                        'session_participants_ids': [participant['id_participant']]   
                    }
                }

                response = requests.post(url=server_url + '/api/user/sessions', headers=headers, json=params, verify=False, timeout=5)
                if response.status_code != 200:
                    sessions.append(response.json()[0])

    # All sessions created                
    return sessions
                
def create_events_for_sessions(sessions: list, service_info: dict) -> list:

    events = []

    for session in sessions:
        # Get the number of events in the session
        params = {
            'id_session': session['id_session']
        }
        response = requests.get(url=server_url + '/api/user/sessions/events', headers=headers, params=params, verify=False, timeout=5)
        if response.status_code == 200:
            existing_events = response.json()
            for event in existing_events:
                events.append(event)
            
            if len(existing_events) == 0:
                # Add start event

                SESSION_START = 3
                SESSION_STOP = 4
                SESSION_JOIN = 12
                SESSION_LEAVE = 13
                params = {
                    'session_event': {
                        'id_session_event': 0,
                        'id_session': session['id_session'],
                        'id_session_event_type': SESSION_START,
                        'session_event_context': 'CONTEXT_DASHBOARD',
                        'session_event_datetime': session['session_start_datetime'],
                        'session_event_text': 'STARTING SESSION'
                    }
                }
                # SESSION START (at start time)
                response = requests.post(url=server_url + '/api/user/sessions/events', headers=headers, json=params, verify=False, timeout=5)
                for event in response.json():
                    events.append(event)


                # SESSION JOIN (at start time)
                params['session_event']['id_session_event_type'] = SESSION_JOIN
                id_participant = session['id_creator_participant']    
                params['session_event']['session_event_text'] = f'JOINING SESSION {id_participant}'                               
                response = requests.post(url=server_url + '/api/user/sessions/events', headers=headers, json=params, verify=False, timeout=5)
                for event in response.json():
                    events.append(event)

                # SESSION STOP (at start time + duration)
                params['session_event']['id_session_event_type'] = SESSION_STOP
                params['session_event']['session_event_text'] = 'STOPPING SESSION'
                params['session_event']['session_event_datetime'] = (datetime.fromisoformat(session['session_start_datetime']) 
                                                                     + timedelta(seconds=session['session_duration'])).isoformat()
                
                response = requests.post(url=server_url + '/api/user/sessions/events', headers=headers, json=params, verify=False, timeout=5)
                for event in response.json():
                    events.append(event)
    return events

def get_session_type_for_service(service_info: dict) -> dict | None:

    params = {    
    }

    response = requests.get(url=server_url + '/api/user/sessiontypes', headers=headers, params=params, verify=False, timeout=5)
    if response.status_code == 200:
        for session_type in response.json():
            if session_type['session_type_name'] == 'Dashboards':
                return session_type

        print('Error getting session type Dashboards, Creating session type...')
        params = {
            'session_type': {
                'id_session_type': 0,
                'id_service': service_info['id_service'],
                'session_type_category': 1, # 1 = Service
                'session_type_color': '#AABBCC',
                'session_type_config': '',
                'session_type_name': 'Dashboards',
                'session_type_online': False
            }
        }
        response = requests.post(url=server_url + '/api/user/sessiontypes', headers=headers, json=params, verify=False, timeout=5)
        if response.status_code != 200:
            print('Error creating session type Dashboards')
            return None

        return response.json()[0]


def get_project_for_service(service_info: dict) -> dict | None:

    # Verify if project #1 exists
    params = {
        'id_project': 1
    }

    response = requests.get(url=server_url + '/api/user/projects', headers=headers, params=params, verify=False, timeout=5)
    if response.status_code == 200:
        if len(response.json()) == 0:
            for project in response.json():
                if project['id_project'] == 1:
                    return project

            print('Error getting project #1, Creating project...')
            params = {
                'project': {
                    'id_site': 1,
                    'id_project': 0,
                    'project_name': 'Dashboards',
                    'project_description': 'Dashboards project',
                    'project_enabled': True,
                }
            }
            response = requests.post(url=server_url + '/api/user/projects', headers=headers, json=params, verify=False, timeout=5)
            if response.status_code != 200:
                print('Error creating project #1')
                return None

        return response.json()[0]
        
    return None

def associate_session_type_with_site(session_type_info: dict, site_info: dict) -> dict | None:

    # Verify if session type is already associated with project
    params = {
        'session_type_site': 
            {
                'id_site': site_info['id_site'],
                'id_session_type': session_type_info['id_session_type'],
                'id_session_type_site': 0
            }
        
    }

    response = requests.post(url=server_url + '/api/user/sessiontypes/sites', headers=headers, json=params, verify=False, timeout=5)
    if response.status_code == 200:
       return response.json()[0]
    
    return None

def associate_session_type_with_project(session_type_info: dict, project_info: dict) -> dict | None:

    # Verify if session type is already associated with project
    params = {
        'session_type_project': 
            {
                'id_project': project_info['id_project'],
                'id_session_type': session_type_info['id_session_type'],
                'id_session_type_project': 0
            }
        
    }

    response = requests.post(url=server_url + '/api/user/sessiontypes/projects', headers=headers, json=params, verify=False, timeout=5)
    if response.status_code == 200:
        return response.json()[0]

    return None


if __name__ == '__main__':

    print('Staring Dashboards Service setup...')

    params = {'service_key': service_key}
    response = requests.get(url=server_url + '/api/user/services',
                            headers=headers,params=params,verify=False, timeout=30)

    if response.status_code == 200:

        if len(response.json()):
            print('Dashboards Service exists.')
            service_info: dict = response.json()[0]
            session_type_info: dict  = get_session_type_for_service(service_info)
            project_info: dict = get_project_for_service(service_info)
            site_info : dict = {
                'id_site': project_info['id_site']
            }
            session_type_site_info: dict = associate_session_type_with_site(session_type_info, site_info)
            session_type_project_info:dict  = associate_session_type_with_project(session_type_info, project_info)

            participants: List[dict] = create_participants(service_info, project_info)

            # Create sessions
            sessions: List[dict] = create_sessions(participants, session_type_info, service_info)

            # Create events
            events: List[dict] = create_events_for_sessions(sessions, service_info)

            # Create assets
            assets: List[dict] = create_assets(service_info, sessions)

    print('Done!')
