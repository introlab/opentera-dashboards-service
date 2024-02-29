from opentera.services.ServiceConfigManager import ServiceConfigManager, DBConfig


class DashboardsServiceConfig:
    specific_service_config = {}

    def __init__(self):
        pass

    def validate_specific_service_config(self, config: dict):
        if 'DashboardsService' in config:
            required_fields = []
            for field in required_fields:
                if field not in config['DashboardsService']:
                    print('ERROR: DashboardsService Config - missing field :' + field)
                    return False

            # Every field is present, update configuration
            self.specific_service_config = config['DashboardsService']
            return True
        # Invalid
        return False


# Build configuration from base classes
class ConfigManager(ServiceConfigManager, DashboardsServiceConfig, DBConfig):
    def validate_config(self, config_json):
        return super().validate_config(config_json) \
               and self.validate_service_config(config_json) and self.validate_database_config(config_json) and \
               self.validate_specific_service_config(config_json)

    def create_defaults(self):
        # Default service config
        self.service_config['name'] = 'DashboardsService'
        self.service_config['hostname'] = '127.0.0.1'
        #  to see used ports
        self.service_config['port'] = 5055
        self.service_config['debug_mode'] = True

        # Default backend configuration
        self.backend_config['hostname'] = '127.0.0.1'
        self.backend_config['port'] = 40075

        # Default redis configuration
        self.redis_config['hostname'] = '127.0.0.1'
        self.redis_config['port'] = 6379
        self.redis_config['username'] = ''
        self.redis_config['password'] = ''
        self.redis_config['db'] = 0

        # Default database configuration
        self.db_config['db_type'] = 'QPSQL'
        # TODO: Set correct database name as default
        self.db_config['name'] = 'dashboards'
        self.db_config['url'] = '127.0.0.1'
        self.db_config['port'] = 5432
        self.db_config['username'] = 'opentera'
        self.db_config['password'] = 'opentera'

        #self.specific_service_config['files_directory'] = 'files'
