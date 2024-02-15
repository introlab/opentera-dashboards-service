from libDashboards.db.models.BaseModel import BaseModel
from sqlalchemy import Column, Integer, Sequence, String, Boolean, func, select
from sqlalchemy.orm import aliased
import uuid


class DashDashboards(BaseModel):
    __tablename__ = 't_dashboards'
    id_dashboard = Column(Integer, Sequence('id_dashboard_sequence'), primary_key=True, autoincrement=True)
    id_site = Column(Integer, nullable=True)
    id_project = Column(Integer, nullable=True)

    dashboard_uuid = Column(String(36), nullable=False)
    dashboard_name = Column(String, nullable=False)
    dashboard_enabled = Column(Boolean, nullable=False, default=True)
    dashboard_description = Column(String, nullable=True)   # Dashboard user-visible description
    dashboard_definition = Column(String, nullable=False)   # Dashboard definition string
    dashboard_version = Column(Integer, nullable=False, default=1)

    def to_json(self, ignore_fields=None, minimal=False):
        if ignore_fields is None:
            ignore_fields = []

        if minimal:
            ignore_fields.extend(['asset_definition'])

        asset_json = super().to_json(ignore_fields=ignore_fields)

        return asset_json

    @staticmethod
    def get_dashboard_by_uuid(dashboard_uuid: str, latest=True):
        query = DashDashboards.query.filter_by(dashboard_uuid=dashboard_uuid)
        if latest:
            subquery = select(func.max(DashDashboards.dashboard_version).label("latest_version"),
                              DashDashboards.dashboard_uuid).group_by(DashDashboards.dashboard_uuid).subquery()
            query = (query.filter(DashDashboards.dashboard_version == subquery.c.latest_version).
                     filter(DashDashboards.dashboard_uuid == subquery.c.dashboard_uuid))

        return query.first()

    @staticmethod
    def get_dashboards_for_site(site_id: int, latest=True) -> []:
        query = DashDashboards.query.filter_by(id_site=site_id)
        if latest:
            subquery = select(func.max(DashDashboards.dashboard_version).label("latest_version"),
                              DashDashboards.dashboard_uuid).group_by(DashDashboards.dashboard_uuid).subquery()
            query = (query.filter(DashDashboards.dashboard_version == subquery.c.latest_version).
                     filter(DashDashboards.dashboard_uuid == subquery.c.dashboard_uuid))
        return query.all()

    @staticmethod
    def get_dashboards_for_project(project_id: int, latest=True) -> []:
        query = DashDashboards.query.filter_by(id_project=project_id)
        if latest:
            subquery = select(func.max(DashDashboards.dashboard_version).label("latest_version"),
                              DashDashboards.dashboard_uuid).group_by(DashDashboards.dashboard_uuid).subquery()
            query = (query.filter(DashDashboards.dashboard_version == subquery.c.latest_version).
                     filter(DashDashboards.dashboard_uuid == subquery.c.dashboard_uuid))
        return query.all()

    @staticmethod
    def get_dashboards_globals(latest=True) -> []:
        query = DashDashboards.query.filter_by(id_project=None, id_site=None)

        if latest:
            subquery = select(func.max(DashDashboards.dashboard_version).label("latest_version"),
                              DashDashboards.dashboard_uuid).group_by(DashDashboards.dashboard_uuid).subquery()
            query = (query.filter(DashDashboards.dashboard_version == subquery.c.latest_version).
                     filter(DashDashboards.dashboard_uuid == subquery.c.dashboard_uuid))

        return query.all()

    @classmethod
    def insert(cls, dashboard):
        # Generate UUID
        if not dashboard.dashboard_uuid:
            dashboard.dashboard_uuid = str(uuid.uuid4())

        super().insert(dashboard)

    @staticmethod
    def create_defaults(test=False):
        if test:
            # Create dashboard for site...
            dashboard = DashDashboards()
            dashboard.id_site = 1
            dashboard.dashboard_name = 'Site 1 - Global'
            dashboard.dashboard_description = 'Test dashboard for global site overview'
            dashboard.dashboard_definition = '{}'
            DashDashboards.insert(dashboard)

            # ... for project...
            dashboard = DashDashboards()
            dashboard.id_project = 1
            dashboard.dashboard_name = 'Project 1 - Global'
            dashboard.dashboard_description = 'Test dashboard for global project overview'
            dashboard.dashboard_definition = '{}'
            DashDashboards.insert(dashboard)

            dashboard = DashDashboards()
            dashboard.id_project = 1
            dashboard.dashboard_name = 'Project 1 - Alerts'
            dashboard.dashboard_description = 'Test dashboard for project alerts'
            dashboard.dashboard_definition = '{}'
            DashDashboards.insert(dashboard)
            uuid = dashboard.dashboard_uuid

            dashboard = DashDashboards()
            dashboard.id_project = 1
            dashboard.dashboard_name = 'Project 1 - Alerts v2'
            dashboard.dashboard_description = 'Test dashboard for project alerts'
            dashboard.dashboard_definition = '{}'
            dashboard.dashboard_version = 2
            dashboard.dashboard_uuid = uuid
            DashDashboards.insert(dashboard)

            # ... and globals
            dashboard = DashDashboards()
            dashboard.dashboard_name = 'System Dashboard'
            dashboard.dashboard_description = 'Global system dashboard'
            dashboard.dashboard_definition = '{}'
            DashDashboards.insert(dashboard)
