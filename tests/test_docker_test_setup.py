import requests
import unittest
import subprocess
import os
import time
import sys

class DockerTestSetupTest(unittest.TestCase):

    SERVER_URL = 'https://localhost:40100'

    def setUp(self):
        # Start docker services with docker-compose

        # Get directory of this file
        dir_path = os.path.dirname(os.path.realpath(__file__))
        # Set the path to the docker-compose file
        docker_compose_path = os.path.realpath(dir_path + '/../docker/dashboards-service-tests')
        docker_compose_args = ['docker',  'compose', '-f', 'docker_compose.yml', 'up', '-d']
        docker_process = subprocess.Popen(docker_compose_args, cwd=docker_compose_path)
        print('Started docker-compose process with PID: ' + str(docker_process.pid))
        docker_process.wait()
        print('Sleeping for 10 seconds to give the services time to start')
        time.sleep(10)
        print('Starting tests...')


    def tearDown(self):
        # Get directory of this file
        dir_path = os.path.dirname(os.path.realpath(__file__))
        # Set the path to the docker-compose file
        docker_compose_path = os.path.realpath(dir_path + '/../docker/dashboards-service-tests')
        docker_compose_args = ['docker',  'compose', '-f', 'docker_compose.yml', 'down']
        docker_process = subprocess.Popen(docker_compose_args, cwd=docker_compose_path)
        print('Stopped docker-compose process with PID: ' + str(docker_process.pid))
        docker_process.wait()

    def test_docker_test_setup(self):
        # Test that the docker test setup is working, ssl is self-signed
        response = requests.get(self.SERVER_URL + '/about', verify=False)
        self.assertEqual(response.status_code, 200)

    def test_reset_db_endpoint(self):
        # Test that the reset_db endpoint is working
        response = requests.get(self.SERVER_URL + '/api/test/database/reset', verify=False)
        self.assertEqual(response.status_code, 200)

if __name__ == '__main__':
    unittest.main()
