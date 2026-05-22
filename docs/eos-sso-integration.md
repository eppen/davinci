# EOS SSO 集成说明（Davinci 侧）

eos-gateway 已拆分为独立项目，仓库与配置见同级目录 `eos-gateway`（或你部署的 gateway 实例）。本文档仅描述 **Davinci** 如何对接。

## 架构

- **eos-gateway**：校验 EOS token、签发 `ssoTicket`、重定向到 Davinci。详见 eos-gateway 项目 `docs/integration.md`。
- **Davinci**：`POST /api/v3/login/sso-ticket` 验票并签发本系统 JWT。

## Davinci 配置 `config/application.yml`

```yaml
eos:
  integration:
    enabled: true
    ticket-secret: change-me-eos-ticket-secret  # 与 gateway 相同
    app-code: davinci
```

gateway 侧需配置 `integration.apps.davinci`（`base-url`、`allowed-redirects` 等），见 eos-gateway 的 `application.yml`。

## EOS 菜单 redirect（经 gateway）

```text
http://127.0.0.1:8088/sso/launch?token={EOS_TOKEN}&app=davinci&redirect=%2F%23%2Fprojects&embedded=1
```

## 启动顺序

1. 启动 eos-gateway（独立项目：`mvn spring-boot:run`）
2. 按项目原有方式启动 Davinci

## 用户要求

- Davinci 须预先存在与 EOS `Username` **完全一致**的 `user.username`，且 `active=true`。
