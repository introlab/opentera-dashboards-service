from libDashboards.db.models.BaseModel import BaseModel
from sqlalchemy import Column, Integer, Sequence, Boolean, ForeignKey, String
from sqlalchemy.orm import relationship


class DashDashboardSites(BaseModel):
    __tablename__ = 't_dashboards_sites'
    id_dashboard_site = Column(Integer, Sequence('id_dashboard_site_sequence'), primary_key=True, autoincrement=True)
    id_site = Column(Integer, nullable=True)
    id_dashboard = Column(Integer, ForeignKey('t_dashboards.id_dashboard', ondelete='cascade'), nullable=False)

    dashboard_site_enabled = Column(Boolean, nullable=False, default=True)
    dashboard_site_version = Column(Integer, nullable=True)  # Force use of a specific dashboard version for that site

    dashboard_site_dashboard = relationship("DashDashboards", back_populates="dashboard_sites")

    def to_json(self, ignore_fields=None, minimal=False, latest=True):
        if ignore_fields is None:
            ignore_fields = []

        ignore_fields.extend(['id_dashboard_site', 'id_dashboard'])

        dashboard_json = super().to_json(ignore_fields=ignore_fields)

        if not minimal:
            dashboard_json |= self.dashboard_site_dashboard.to_json(minimal=latest, latest=latest)

        # Rename keys to standardize them
        dashboard_json['dashboard_enabled'] = dashboard_json.pop('dashboard_site_enabled')
        dashboard_json['dashboard_required_version'] = dashboard_json.pop('dashboard_site_version')

        # Get the appropriate dashboard to jsonize
        if latest and not minimal:
            dashboard_json['versions'] = []
            if self.dashboard_site_version and self.dashboard_site_version > 0:
                for version in self.dashboard_site_dashboard.dashboard_versions:
                    if version.dashboard_version == self.dashboard_site_version:
                        dashboard_json['versions'] = version.to_json(minimal=True)
            else:
                if len(self.dashboard_site_dashboard.dashboard_versions) > 0:
                    dashboard_json['versions'] = (self.dashboard_site_dashboard.dashboard_versions[-1].
                                                  to_json(minimal=True))

        return dashboard_json

    @staticmethod
    def get_sites_ids_for_dashboard(dashboard_id: int, enabled_only=True):
        query = DashDashboardSites.query.with_entities(DashDashboardSites.id_site).filter_by(id_dashboard=dashboard_id)
        if enabled_only:
            query = query.filter_by(dashboard_site_enabled=True)

        rows = query.all()
        site_ids = [site_id[0] for site_id in rows]
        return site_ids

    @staticmethod
    def get_dashboards_for_site(site_id: int, enabled_only=True) -> []:
        filters = {'id_site': site_id}
        if enabled_only:
            filters['dashboard_site_enabled'] = True

        dds = DashDashboardSites.query_with_filters(filters)

        return dds

    @staticmethod
    def get_for_site_and_dashboard(site_id: int, dashboard_id: int):
        return DashDashboardSites.query.filter_by(id_site=site_id, id_dashboard=dashboard_id).first()

    @staticmethod
    def create_defaults(test=False):
        if test:
            from libDashboards.db.models.DashDashboards import DashDashboards
            dashboards = DashDashboards.query.all()

            dds = DashDashboardSites()
            dds.id_site = 1
            dds.id_dashboard = dashboards[0].id_dashboard
            dds.dashboard_site_enabled = True
            dds.dashboard_site_version = 1
            DashDashboardSites.insert(dds)

            dds = DashDashboardSites()
            dds.id_site = 2
            dds.id_dashboard = dashboards[0].id_dashboard
            dds.dashboard_site_enabled = True
            DashDashboardSites.insert(dds)
