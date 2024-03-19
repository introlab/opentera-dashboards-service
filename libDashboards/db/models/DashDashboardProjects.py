from libDashboards.db.models.BaseModel import BaseModel
from sqlalchemy import Column, Integer, Sequence, Boolean, ForeignKey, String
from sqlalchemy.orm import relationship


class DashDashboardProjects(BaseModel):
    __tablename__ = 't_dashboards_projects'
    id_dashboard_project = Column(Integer, Sequence('id_dashboard_project_sequence'),
                                  primary_key=True, autoincrement=True)
    id_project = Column(Integer, nullable=True)
    id_dashboard = Column(Integer, ForeignKey('t_dashboards.id_dashboard', ondelete='cascade'), nullable=False)

    dashboard_project_enabled = Column(Boolean, nullable=False, default=True)
    dashboard_project_version = Column(Integer, nullable=True)  # Use a specific dashboard version for that project

    dashboard_project_dashboard = relationship("DashDashboards", back_populates="dashboard_projects")

    def to_json(self, ignore_fields=None, minimal=False, latest=True):
        if ignore_fields is None:
            ignore_fields = []

        ignore_fields.extend(['id_dashboard_project', 'id_dashboard'])

        dashboard_json = super().to_json(ignore_fields=ignore_fields)

        if not minimal:
            dashboard_json |= self.dashboard_project_dashboard.to_json(minimal=latest, latest=latest)

        # Rename keys to standardize them
        dashboard_json['dashboard_enabled'] = dashboard_json.pop('dashboard_project_enabled')
        dashboard_json['dashboard_required_version'] = dashboard_json.pop('dashboard_project_version')

        # Get the appropriate dashboard to jsonize
        if latest and not minimal:
            dashboard_json['versions'] = []
            if self.dashboard_project_version and self.dashboard_project_version > 0:
                for version in self.dashboard_project_dashboard.dashboard_versions:
                    if version.dashboard_version == self.dashboard_project_version:
                        dashboard_json['versions'] = version.to_json(minimal=True)
            else:
                if len(self.dashboard_project_dashboard.dashboard_versions) > 0:
                    dashboard_json['versions'] = (self.dashboard_project_dashboard.dashboard_versions[-1].
                                                  to_json(minimal=True))

        return dashboard_json

    @staticmethod
    def get_projects_ids_for_dashboard(dashboard_id: int, enabled_only=True):
        query = (DashDashboardProjects.query.with_entities(DashDashboardProjects.id_project)
                 .filter_by(id_dashboard=dashboard_id))
        if enabled_only:
            query = query.filter_by(dashboard_project_enabled=True)

        rows = query.all()
        proj_ids = [proj_id[0] for proj_id in rows]
        return proj_ids

    @staticmethod
    def get_dashboards_for_project(project_id: int, enabled_only=True) -> []:
        filters = {'id_project': project_id}
        if enabled_only:
            filters['dashboard_project_enabled'] = True

        ddp = DashDashboardProjects.query_with_filters(filters)

        return ddp

    @staticmethod
    def get_for_project_and_dashboard(project_id: int, dashboard_id: int):
        return DashDashboardProjects.query.filter_by(id_project=project_id, id_dashboard=dashboard_id).first()

    @staticmethod
    def create_defaults(test=False):
        from libDashboards.db.models.DashDashboards import DashDashboards
        dashboards = DashDashboards.query.all()

        if test:
            ddp = DashDashboardProjects()
            ddp.id_project = 1
            ddp.id_dashboard = dashboards[1].id_dashboard
            ddp.dashboard_project_enabled = False
            ddp.dashboard_project_version = 1
            DashDashboardProjects.insert(ddp)

            ddp = DashDashboardProjects()
            ddp.id_project = 1
            ddp.id_dashboard = dashboards[2].id_dashboard
            ddp.dashboard_project_enabled = True
            DashDashboardProjects.insert(ddp)

            ddp = DashDashboardProjects()
            ddp.id_project = 2
            ddp.id_dashboard = dashboards[1].id_dashboard
            DashDashboardProjects.insert(ddp)

            ddp = DashDashboardProjects()
            ddp.id_project = 2
            ddp.id_dashboard = dashboards[2].id_dashboard
            ddp.dashboard_project_enabled = True
            ddp.dashboard_project_version = 1
            DashDashboardProjects.insert(ddp)
