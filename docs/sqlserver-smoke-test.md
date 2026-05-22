# SQL Server 系统库冒烟测试清单

部署前请确认 `spring.datasource.url` 为 `jdbc:sqlserver://...`，且已执行 `bin/davinci.sqlserver.sql`。

## 启动

- [ ] 应用正常启动，日志中出现 `MyBatis databaseId: sqlserver`
- [ ] Druid 连接池无报错，`validation-query` 通过

## 用户

- [ ] 默认 guest 账号可登录
- [ ] 注册 / 激活 / 改密

## 组织与项目

- [ ] 创建组织、邀请成员
- [ ] 项目 CRUD、分页列表（PageHelper）

## 可视化

- [ ] 数据源 Source 增删改
- [ ] View / Widget 配置读写（含 `sql`、`config` 列）
- [ ] Dashboard / Portal 创建与排序
- [ ] Display 与大屏 Slide 创建、`copySlide`、批量 `updateBatch`

## 权限与分享

- [ ] 角色与 rel_role_* 关联保存
- [ ] 分享页访问、下载记录

## 定时任务

- [ ] cron_job 创建、启停、执行日志更新
