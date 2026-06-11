# 电商管理系统 (Mall System)

一个完整的**三端电商系统**，包含后端 API 服务、后台管理前端和微信小程序。

## 项目架构

```
┌─────────────────────────────────────────────────────────────┐
│                        用户层                                │
│  ┌─────────────────┐  ┌──────────────────┐  ┌────────────┐ │
│  │   mall-admin     │  │ mall-littleprogram│  │ 第三方客户端 │ │
│  │  (Vue3 管理后台)  │  │ (微信小程序)      │  │            │ │
│  └────────┬────────┘  └────────┬─────────┘  └──────┬─────┘ │
└───────────┼────────────────────┼────────────────────┼───────┘
            │ HTTP/JSON          │ HTTP/JSON          │
            ▼                    ▼                    ▼
┌─────────────────────────────────────────────────────────────┐
│                    API 网关 (Nginx)                           │
│              代理 /api/* → mallservice-python                 │
└────────────────────────┬────────────────────────────────────┘
                         │
                         ▼
┌─────────────────────────────────────────────────────────────┐
│              mallservice-python (Flask API)                  │
│  ┌──────────┐ ┌──────────┐ ┌──────────┐ ┌──────────────┐   │
│  │ 用户/地址 │ │ 商品/分类 │ │ 订单/优惠 │ │ 图片上传     │   │
│  │  API     │ │  API     │ │ 券 API   │ │  API         │   │
│  └────┬─────┘ └────┬─────┘ └────┬─────┘ └──────┬───────┘   │
│       │            │            │               │           │
│  ┌────┴────────────┴────────────┴───────────────┴────┐      │
│  │              Service 业务逻辑层                     │      │
│  └────────────────────────┬──────────────────────────┘      │
│                           │                                  │
│  ┌────────────────────────┴──────────────────────────┐      │
│  │           SQLAlchemy ORM + oslo.db                  │      │
│  └────────────────────────┬──────────────────────────┘      │
└───────────────────────────┼──────────────────────────────────┘
                            │
              ┌─────────────┼─────────────┐
              ▼             ▼             ▼
┌──────────────┐  ┌──────────────┐  ┌──────────────┐
│    MySQL     │  │   MinIO      │  │    Redis     │
│  (主数据库)   │  │ (对象存储)    │  │   (缓存)     │
└──────────────┘  └──────────────┘  └──────────────┘
```

## 子项目

| 子项目 | 技术栈 | 说明 |
|--------|--------|------|
| [mallservice-python](./mallservice-python) | Python Flask + SQLAlchemy + MySQL | 后端 API 服务，提供所有业务接口 |
| [mall-admin](./mall-admin) | Vue 3 + Element Plus + Vite | 后台管理前端，管理员操作界面 |
| [mall-littleprogram](./mall-littleprogram) | 微信小程序 + TDesign | 面向用户的微信小程序 |

### mallservice-python — 后端 API 服务

- **框架**: Flask 1.1 + Flask-RESTX (Swagger 文档)
- **ORM**: SQLAlchemy 1.3 + oslo.db
- **数据库**: MySQL (PyMySQL)
- **缓存**: Redis + oslo.cache
- **认证**: JWT (HS256, 24h 过期)
- **对象存储**: boto3 (S3 协议，兼容 MinIO/阿里云OSS/腾讯云COS/AWS S3)
- **任务调度**: APScheduler
- **部署**: Gunicorn + Docker
- **监听端口**: `8560`

**API 模块**:

| 模块 | 路由前缀 | 功能 |
|------|---------|------|
| 用户 | `/v1/user` | 微信登录、用户管理 |
| 地址 | `/v1/address` | 用户地址 CRUD |
| 商品分类 | `/v1/goodscatalog` | 分类树管理 |
| 商品 | `/v1/goods` | SPU/SKU/规格管理 |
| 管理员 | `/v1/admin` | 登录/角色/菜单/权限 |
| 系统设置 | `/v1/admin/setting` | 基础配置、存储配置 |
| 图片上传 | `/v1/upload` | 图片上传(预签名/代理上传) |

### mall-admin — 后台管理前端

- **框架**: Vue 3 (Composition API + `<script setup>`)
- **构建**: Vite 2
- **UI**: Element Plus 2
- **状态管理**: Vuex 4
- **路由**: Vue Router 4 (Hash 模式)
- **CSS**: Windi CSS (原子化)
- **HTTP**: Axios
- **富文本**: wangEditor 5
- **部署**: 多阶段 Docker 构建 (Node build → Nginx serve)

**功能模块**:

| 模块 | 路径 | 功能 |
|------|------|------|
| 仪表盘 | `/` | 数据概览 |
| 商品管理 | `/goods/list`, `/goods/add` | 商品列表、添加/编辑商品 |
| 分类管理 | `/category/list` | 商品分类管理 |
| 订单管理 | `/order/list` | 订单列表与处理 |
| 用户管理 | `/user/list` | 用户列表 |
| 优惠券 | `/coupon/list` | 优惠券管理 |
| 团购 | `/groupon/*` | 团购活动管理 |
| 分销 | `/agent/list` | 分销员管理 |
| 系统设置 | `/setting/base`, `/setting/objectsto`, `/setting/role` | 基础配置、存储配置、角色权限 |

### mall-littleprogram — 微信小程序

- **框架**: 微信小程序原生
- **UI**: TDesign Miniprogram
- 包含首页、商品浏览、购物车、下单、个人中心等完整购物流程

## 快速开始

### 环境要求

- Python >= 3.8
- Node.js >= 20
- MySQL 5.7+
- Redis (可选)

### 启动后端

```bash
cd mallservice-python

# 安装依赖
pip install -r requirements.txt

# 修改 etc/mall/mall.conf 中的数据库连接
# 同步数据库表结构
mall-db-sync --config-file etc/mall/mall.conf

# 启动 API 服务
mall-api --config-file etc/mall/mall.conf
```

### 启动前端

```bash
cd mall-admin
yarn install
yarn dev
```

前端默认代理 `/api/*` 请求到 `http://localhost:8560`。

### MinIO 对象存储

```bash
cd mallservice-python
docker-compose -f docker-compose.minio.yml up -d
```

控制台: `http://<host>:9001`，默认账号 `admin` / `password123`

### 默认管理员账号

- 用户名: `admin`
- 密码: `admin123`

## 技术栈一览

### 后端

| 类别 | 技术 |
|------|------|
| 语言 | Python 3.8+ |
| Web 框架 | Flask 1.1 + Flask-RESTX |
| ORM | SQLAlchemy 1.3 + oslo.db |
| 数据库 | MySQL (PyMySQL) + SQLite (开发) |
| 认证 | JWT (PyJWT) |
| 缓存 | Redis + oslo.cache |
| 对象存储 | boto3 (S3 协议) |
| 任务调度 | APScheduler |
| 日志 | oslo.log |
| 配置 | oslo.config |
| WSGI | Gunicorn |

### 前端

| 类别 | 技术 |
|------|------|
| 框架 | Vue 3 |
| 构建 | Vite 2 |
| UI | Element Plus 2 |
| 状态管理 | Vuex 4 |
| 路由 | Vue Router 4 |
| HTTP | Axios |
| CSS | Windi CSS |
| 富文本 | wangEditor 5 |

### 小程序

| 类别 | 技术 |
|------|------|
| 框架 | 微信小程序原生 |
| UI | TDesign Miniprogram |
