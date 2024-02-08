from ConfigManager import ConfigManager
from libDashboards.db import DBManager


# Configuration manager
config_man = ConfigManager()

# Database manager
db_man = None

# Redis client & keys
redis_client = None

# Service
service = None
