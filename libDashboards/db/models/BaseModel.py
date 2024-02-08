from opentera.db.Base import BaseMixin
from sqlalchemy.ext.declarative import declarative_base


class DashboardsBaseMixin(BaseMixin):

    @classmethod
    def get_by_id(cls, id_obj: int):
        id_field = cls.get_primary_key_name()
        data = cls.query_with_filters({id_field: id_obj})
        if data:
            return data[0]
        return None

    @classmethod
    def get_by_name(cls, name: str):
        name_field = cls.get_model_name() + '_name'
        data = cls.query_with_filters({name_field: name})
        if data:
            return data[0]
        return None


# Declarative base, inherit from Base for all models
BaseModel = declarative_base(cls=DashboardsBaseMixin)
