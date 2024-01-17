create user TeraAgent with encrypted password 'tera';
create database opentera;
grant all privileges on database opentera to TeraAgent;
create database openteralogs;
grant all privileges on database openteralogs to TeraAgent;
create database openterafiles;
grant all privileges on database openterafiles to TeraAgent;
create database opentera_dashboards;
grant all privileges on database opentera_dashboards to TeraAgent;
