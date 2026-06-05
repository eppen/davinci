/*
 * Phase 1: Chart Registry
 */

CREATE TABLE IF NOT EXISTS `chart_type` (
  `id`              BIGINT       NOT NULL AUTO_INCREMENT,
  `code`            VARCHAR(64)  NOT NULL COMMENT '唯一编码，如 bar / mes-oee-gauge',
  `name`            VARCHAR(64)  NOT NULL COMMENT '渲染器标识，与前端 chart name 对应',
  `title`           VARCHAR(128) NOT NULL COMMENT '显示名称',
  `category`        VARCHAR(32)  NOT NULL DEFAULT 'general' COMMENT 'general/mes/quality/equipment',
  `icon`            VARCHAR(64)  NULL COMMENT '图标 class',
  `renderer`        VARCHAR(32)  NOT NULL DEFAULT 'echarts' COMMENT 'echarts | custom:xxx',
  `config_schema`   JSON         NOT NULL COMMENT '样式 schema 或完整 style JSON',
  `data_schema`     JSON         NOT NULL COMMENT 'data + rules 等',
  `option_template` JSON         NULL COMMENT 'ECharts option 模板（Phase 2 DSL）',
  `version`         INT          NOT NULL DEFAULT 1,
  `builtin`         TINYINT(1)   NOT NULL DEFAULT 0 COMMENT '是否系统内置',
  `enabled`         TINYINT(1)   NOT NULL DEFAULT 1,
  `description`     VARCHAR(512) NULL,
  `create_by`       BIGINT       NULL,
  `create_time`     DATETIME     NULL,
  `update_by`       BIGINT       NULL,
  `update_time`     DATETIME     NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_chart_type_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
