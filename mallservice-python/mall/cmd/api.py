"""API服务入口"""
import os
import sys

# 确保项目根目录在sys.path中
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.dirname(__file__))))

from oslo_config import cfg
from oslo_log import log as logging

# 注册配置选项
import mall.conf.common
import mall.conf.core
import mall.conf.api
import mall.conf.db

CONF = cfg.CONF

# 注册各组件的配置选项
mall.conf.common.register_opts(CONF)
mall.conf.core.register_opts(CONF)
mall.conf.api.register_opts(CONF)
mall.conf.db.register_opts(CONF)

# 配置日志
logging.register_options(CONF)

# 默认配置
CONF(args=[], default_config_files=[])

LOG = logging.getLogger(__name__)


def init_database():
    """初始化数据库表结构和种子数据"""
    # 导入所有模型，确保它们注册到 BASE.metadata
    from mall.db.models.base import BASE
    from mall.db.engines.mysql import get_engine
    import mall.db.models.Goods.model  # noqa: 确保表注册
    import mall.db.models.GoodsCatalog.model  # noqa
    import mall.db.models.User.model  # noqa
    import mall.db.models.Task.model  # noqa

    engine = get_engine()
    # 创建所有表
    BASE.metadata.create_all(engine)
    LOG.info("数据库表结构初始化完成")

    # 初始化种子数据
    from mall.db.models.Goods.sql import GoodsCategoryDao, seed_default_goods
    GoodsCategoryDao.seed_default_categories()
    seed_default_goods()
    LOG.info("种子数据初始化完成")


def main():
    """启动API服务"""
    from mall import app

    # 初始化数据库
    init_database()

    # 启动Flask应用
    app.run(
        host='0.0.0.0',
        port=5000,
        debug=True,
    )


if __name__ == '__main__':
    main()
