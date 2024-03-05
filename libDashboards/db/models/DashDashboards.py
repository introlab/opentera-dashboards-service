from libDashboards.db.models.BaseModel import BaseModel
from sqlalchemy import Column, Integer, Sequence, String, func, select
from sqlalchemy.orm import relationship
import uuid


class DashDashboards(BaseModel):
    __tablename__ = 't_dashboards'
    id_dashboard = Column(Integer, Sequence('id_dashboard_sequence'), primary_key=True, autoincrement=True)

    dashboard_uuid = Column(String(36), nullable=False)
    dashboard_name = Column(String, nullable=False)
    dashboard_description = Column(String, nullable=True)   # Dashboard user-visible description

    dashboard_versions = relationship("DashDashboardVersions", back_populates="dashboard_version_dashboard",
                                      order_by="DashDashboardVersions.dashboard_version", viewonly=True)
    dashboard_sites = relationship("DashDashboardSites", back_populates="dashboard_site_dashboard")
    dashboard_projects = relationship("DashDashboardProjects", back_populates="dashboard_project_dashboard")

    def to_json(self, ignore_fields=None, minimal=False, latest=True):
        if ignore_fields is None:
            ignore_fields = []

        dashboard_json = super().to_json(ignore_fields=ignore_fields)

        if not minimal:
            if latest:  # Only get latest version
                dashboard_json['versions'] = [self.dashboard_versions[-1].to_json(minimal=True)]
            else:   # Append all versions
                dashboard_json['versions'] = [version.to_json(minimal=True) for version in self.dashboard_versions]

        return dashboard_json

    @staticmethod
    def get_by_uuid(dashboard_uuid: str):
        query = DashDashboards.query.filter_by(dashboard_uuid=dashboard_uuid)
        return query.first()

    @staticmethod
    def get_dashboards_globals() -> []:
        from libDashboards.db.models.DashDashboardProjects import DashDashboardProjects
        from libDashboards.db.models.DashDashboardSites import DashDashboardSites
        query = (DashDashboards.query.join(DashDashboards.dashboard_sites, isouter=True).
                 join(DashDashboards.dashboard_projects, isouter=True).
                 filter(DashDashboardProjects.id_project == None).
                 filter(DashDashboardSites.id_site == None))

        # query = DashDashboards.query.filter_by(id_project=None, id_site=None)
        #
        # if latest:
        #     subquery = select(func.max(DashDashboards.dashboard_version).label("latest_version"),
        #                       DashDashboards.dashboard_uuid).group_by(DashDashboards.dashboard_uuid).subquery()
        #     query = (query.filter(DashDashboards.dashboard_version == subquery.c.latest_version).
        #              filter(DashDashboards.dashboard_uuid == subquery.c.dashboard_uuid))
        #
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
            # dashboard.id_site = 1
            dashboard.dashboard_name = 'Site Global'
            dashboard.dashboard_description = 'Test dashboard for global site overview'
            DashDashboards.insert(dashboard)

            # ... for project...
            dashboard = DashDashboards()
            # dashboard.id_project = 1
            dashboard.dashboard_name = 'Project - Global'
            dashboard.dashboard_description = 'Test dashboard for global project overview'
            DashDashboards.insert(dashboard)

            dashboard = DashDashboards()
            # dashboard.id_project = 1
            dashboard.dashboard_name = 'Project - Alerts'
            dashboard.dashboard_description = 'Test dashboard for project alerts'
            DashDashboards.insert(dashboard)

            # ... and globals
            dashboard = DashDashboards()
            dashboard.dashboard_name = 'System Dashboard'
            dashboard.dashboard_description = 'Global system dashboard'
            DashDashboards.insert(dashboard)
