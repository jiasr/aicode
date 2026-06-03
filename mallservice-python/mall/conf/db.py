import os
from oslo_config import cfg
from oslo_db import options


def register_opts(conf):
    # 使用项目目录下的数据库文件
    project_dir = os.path.dirname(os.path.dirname(os.path.dirname(__file__)))
    db_path = os.path.join(project_dir, 'mall.db')
    options.set_defaults(conf, connection=f'sqlite:///{db_path}')
