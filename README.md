# Sensitive 管理系统

Sensitive 是一个前后端分离的后台管理系统，后端基于 Java、Spring Boot、MyBatis 和 MySQL，前端基于 Vue 3、Vite、Pinia 和 Element Plus。项目包含用户、角色、菜单、部门、岗位、字典、参数配置、通知公告、登录日志、操作日志、定时任务、服务监控、缓存监控、代码生成等常见后台能力。

## 项目结构

```text
sensitive
├── sensitive-backend    # 后端 Maven 多模块工程
│   ├── sensitive-admin      # 启动入口与接口控制器
│   ├── sensitive-common     # 通用工具、注解、常量、基础模型
│   ├── sensitive-framework  # 安全、配置、拦截器、全局处理
│   ├── sensitive-system     # 系统管理业务模块
│   ├── sensitive-quartz     # 定时任务模块
│   ├── sensitive-generator  # 代码生成模块
│   └── sql                  # 初始化 SQL 脚本
└── sensitive-front      # 前端 Vue 3 + Vite 工程
```

## 技术栈

后端：

- Java 17
- Spring Boot 4.0.6
- MyBatis
- MySQL
- Redis
- Druid
- Quartz
- Fastjson2
- PageHelper

前端：

- Vue 3
- Vite 6
- Pinia
- Vue Router
- Element Plus
- Axios
- ECharts

## 本地启动

### 1. 初始化数据库

创建 MySQL 数据库后，按需导入：

- `sensitive-backend/sql/sensitive_20260417.sql`
- `sensitive-backend/sql/quartz.sql`

数据库连接配置位于：

- `sensitive-backend/sensitive-admin/src/main/resources/application-druid.yml`

### 2. 启动 Redis

确认 Redis 已启动，并根据本地环境调整：

- `sensitive-backend/sensitive-admin/src/main/resources/application.yml`

### 3. 启动后端

```bash
cd sensitive-backend
mvn clean package
java -jar sensitive-admin/target/sensitive-admin.jar
```

开发时也可以直接运行：

```bash
cd sensitive-backend
mvn spring-boot:run -pl sensitive-admin
```

默认后端端口为 `8080`。

### 4. 启动前端

```bash
cd sensitive-front
npm install
npm run dev
```

生产构建：

```bash
npm run build:prod
```

## 常用脚本

后端脚本：

- `sensitive-backend/ry.bat`
- `sensitive-backend/ry.sh`
- `sensitive-backend/bin/package.bat`

前端脚本：

- `sensitive-front/bin/run-web.bat`
- `sensitive-front/bin/build.bat`
- `sensitive-front/bin/package.bat`



## License

项目包含前后端各自的 `LICENSE` 文件，请以仓库中的许可文件为准。

##该项目基于若依2次修改

