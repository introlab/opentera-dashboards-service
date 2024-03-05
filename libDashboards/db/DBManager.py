from flask_sqlalchemy import SQLAlchemy
from sqlalchemy import inspect, event
from sqlalchemy.engine.reflection import Inspector
from libDashboards.db.models.BaseModel import BaseModel

from ConfigManager import ConfigManager
from FlaskModule import flask_app
import Globals

# Alembic
from alembic.config import Config
from alembic import command

from sqlite3 import Connection as SQLite3Connection
from sqlalchemy.engine import Engine


class DBManager:
    """db_infos = {
        'user': '',
        'pw': '',
        'db': '',
        'host': '',
        'port': '',
        'type': ''
    }"""

    def __init__(self, app=flask_app, test: bool = False):
        self.db_uri = None
        self.db = SQLAlchemy()
        self.app = app
        self.test = test

    def create_defaults(self, test=False):
        with self.app.app_context():
            from libDashboards.db.models.DashDashboards import DashDashboards
            from libDashboards.db.models.DashDashboardSites import DashDashboardSites
            from libDashboards.db.models.DashDashboardProjects import DashDashboardProjects
            from libDashboards.db.models.DashDashboardVersions import DashDashboardVersions

            if DashDashboards.get_count() == 0 and test:
                print("No dashboards - creating defaults")
                DashDashboards.create_defaults(test)

            if DashDashboardVersions.get_count() == 0 and test:
                print("No dashboards versions - creating defaults")
                DashDashboardVersions.create_defaults(test)

            if DashDashboardSites.get_count() == 0 and test:
                print("No dashboards for sites - creating defaults")
                DashDashboardSites.create_defaults(test)

            if DashDashboardProjects.get_count() == 0 and test:
                print("No dashboards for projects - creating defaults")
                DashDashboardProjects.create_defaults(test)

    def open(self, db_infos, echo=False):
        self.db_uri = 'postgresql://%(user)s:%(pw)s@%(host)s:%(port)s/%(db)s' % db_infos

        self.app.config.update({
            'SQLALCHEMY_DATABASE_URI': self.db_uri,
            'SQLALCHEMY_TRACK_MODIFICATIONS': False,
            'SQLALCHEMY_ECHO': echo
        })

        # Create db engine
        self.db.init_app(self.app)
        self.db.app = self.app
        BaseModel.set_db(self.db)

        with self.app.app_context():
            # BaseModel.db().drop_all()
            BaseModel.create_all()

            inspector = Inspector.from_engine(self.db.engine)
            tables = inspector.get_table_names()

            if not tables:
                # New database - stamp with current revision version
                self.stamp_db()
            else:
                # Apply any database upgrade, if needed
                self.upgrade_db()

    def open_local(self, db_infos, echo=True):
        # self.db_uri = 'sqlite:////temp/test.db'
        self.db_uri = 'sqlite://'

        self.app.config.update({
            'SQLALCHEMY_DATABASE_URI': self.db_uri,
            'SQLALCHEMY_TRACK_MODIFICATIONS': False,
            'SQLALCHEMY_ECHO': echo
        })

        # Create db engine
        self.db.init_app(self.app)
        self.db.app = self.app
        BaseModel.set_db(self.db)

        with self.app.app_context():
            BaseModel.create_all()

            inspector = inspect(self.db.engine)
            tables = inspector.get_table_names()

            if not tables:
                # New database - stamp with current revision version
                self.stamp_db()
            else:
                # Apply any database upgrade, if needed
                self.upgrade_db()

    def init_alembic(self):
        import sys
        import os
        # determine if application is a script file or frozen exe
        if getattr(sys, 'frozen', False):
            # If the application is run as a bundle, the pyInstaller bootloader
            # extends the sys module by a flag frozen=True and sets the app
            # path into variable _MEIPASS'.
            this_file_directory = sys._MEIPASS
            # When frozen, file directory = executable directory
            root_directory = this_file_directory
        else:
            this_file_directory = os.path.dirname(os.path.abspath(__file__))
            root_directory = os.path.join(this_file_directory, '..' + os.sep + '..')

        # this_file_directory = os.path.dirname(os.path.abspath(inspect.stack()[0][1]))

        alembic_directory = os.path.join(root_directory, 'alembic')
        ini_path = os.path.join(root_directory, 'alembic.ini')

        # create Alembic config and feed it with paths
        alembic_config = Config(ini_path)
        alembic_config.set_main_option('script_location', alembic_directory)
        alembic_config.set_main_option('sqlalchemy.url', self.db_uri)

        return alembic_config

    def upgrade_db(self):
        alembic_config = self.init_alembic()

        # prepare and run the command
        revision = 'head'
        sql = False
        tag = None

        # upgrade command
        command.upgrade(alembic_config, revision, sql=sql, tag=tag)

    def stamp_db(self):
        alembic_config = self.init_alembic()

        # prepare and run the command
        revision = 'head'
        sql = False
        tag = None

        # Stamp database
        command.stamp(alembic_config, revision, sql, tag)


@event.listens_for(Engine, "connect")
def _set_sqlite_pragma(dbapi_connection, connection_record):
    if isinstance(dbapi_connection, SQLite3Connection):
        cursor = dbapi_connection.cursor()
        cursor.execute("PRAGMA foreign_keys=ON;")
        cursor.close()


if __name__ == '__main__':
    config = ConfigManager()
    config.create_defaults()
    manager = DBManager()
    manager.open_local({}, echo=True)
    manager.create_defaults(config)
