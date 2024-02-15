from libDashboards.db.models.BaseModel import BaseModel
from sqlalchemy import Column, Integer, Sequence, ForeignKey, JSON
from sqlalchemy.orm import relationship


class DashDashboardVersions(BaseModel):
    __tablename__ = 't_dashboards_versions'
    id_dashboard_version = Column(Integer, Sequence('id_dashboard_version_sequence'),
                                  primary_key=True, autoincrement=True)
    id_dashboard = Column(Integer, ForeignKey('t_dashboards.id_dashboard', ondelete='cascade'), nullable=False)

    dashboard_definition = Column(JSON, nullable=False)   # Dashboard definition string
    dashboard_version = Column(Integer, nullable=False)

    dashboard_version_dashboard = relationship("DashDashboards", back_populates="dashboard_versions")

    def to_json(self, ignore_fields=None, minimal=False):
        if ignore_fields is None:
            ignore_fields = []

        if minimal:
            ignore_fields.extend(['id_dashboard_version', 'id_dashboard'])

        dashboard_json = super().to_json(ignore_fields=ignore_fields)

        return dashboard_json

    @staticmethod
    def create_defaults(test=False):
        if test:
            from libDashboards.db.models.DashDashboards import DashDashboards
            dashboards = DashDashboards.query.all()

            # 2 Versions for "site" dashboard
            dashboard = DashDashboardVersions()
            dashboard.id_dashboard = dashboards[0].id_dashboard
            dashboard.dashboard_version = 1
            dashboard.dashboard_definition = '{}'
            DashDashboardVersions.insert(dashboard)

            dashboard = DashDashboardVersions()
            dashboard.id_dashboard = dashboards[0].id_dashboard
            dashboard.dashboard_version = 2
            dashboard.dashboard_definition = '{"widgets": ""}'
            DashDashboardVersions.insert(dashboard)

            # 1 version for "project global" dashboard
            dashboard = DashDashboardVersions()
            dashboard.id_dashboard = dashboards[1].id_dashboard
            dashboard.dashboard_version = 1
            dashboard.dashboard_definition = '{}'
            DashDashboardVersions.insert(dashboard)

            # 2 version for "alert" dashboard
            dashboard = DashDashboardVersions()
            dashboard.id_dashboard = dashboards[2].id_dashboard
            dashboard.dashboard_version = 1
            dashboard.dashboard_definition = '{}'
            DashDashboardVersions.insert(dashboard)

            dashboard = DashDashboardVersions()
            dashboard.id_dashboard = dashboards[2].id_dashboard
            dashboard.dashboard_version = 2
            dashboard.dashboard_definition = '{"widgets": ""}'
            DashDashboardVersions.insert(dashboard)

            # 1 version for "global" dashboard
            dashboard = DashDashboardVersions()
            dashboard.id_dashboard = dashboards[3].id_dashboard
            dashboard.dashboard_version = 1
            dashboard.dashboard_definition = '{}'
            DashDashboardVersions.insert(dashboard)
