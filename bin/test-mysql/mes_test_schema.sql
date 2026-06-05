/*
 * MES 测试库：表 + 汇总视图（通道 B 只读 JDBC 冒烟）
 * 目标库：test @ localhost:3306
 * 与 MesDatasetMockController 试点数据集 output_shift / yield_trend 字段对齐
 */

USE `test`;

-- 清理（可重复执行）
DROP VIEW IF EXISTS `v_yield_trend`;
DROP VIEW IF EXISTS `v_output_shift`;
DROP TABLE IF EXISTS `mes_daily_yield`;
DROP TABLE IF EXISTS `mes_shift_output`;

-- 班次产出明细（模拟 MES 汇总层，非事务大表）
CREATE TABLE `mes_shift_output` (
  `id`          BIGINT       NOT NULL AUTO_INCREMENT,
  `plant`       VARCHAR(16)  NOT NULL COMMENT '工厂',
  `line_code`   VARCHAR(16)  NOT NULL COMMENT '产线',
  `shift`       CHAR(1)      NOT NULL COMMENT '班次 A/B/C',
  `biz_date`    DATE         NOT NULL COMMENT '业务日期',
  `output_qty`  INT          NOT NULL DEFAULT 0 COMMENT '实际产量',
  `plan_qty`    INT          NOT NULL DEFAULT 0 COMMENT '计划产量',
  `create_time` DATETIME     NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_shift_output_lookup` (`plant`, `line_code`, `shift`, `biz_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='MES 班次产出（测试）';

-- 日良率明细
CREATE TABLE `mes_daily_yield` (
  `id`         BIGINT       NOT NULL AUTO_INCREMENT,
  `plant`      VARCHAR(16)  NOT NULL,
  `line_code`  VARCHAR(16)  NOT NULL,
  `biz_date`   DATE         NOT NULL,
  `ok_qty`     INT          NOT NULL DEFAULT 0,
  `total_qty`  INT          NOT NULL DEFAULT 0,
  `create_time` DATETIME    NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uk_daily_yield` (`plant`, `line_code`, `biz_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COMMENT='MES 日良率（测试）';

-- 试点视图 1：班次产出（对应 Dataset output_shift）
CREATE VIEW `v_output_shift` AS
SELECT
  `plant`,
  `line_code`,
  `shift`,
  `biz_date`,
  `output_qty`,
  `plan_qty`,
  ROUND(`output_qty` / NULLIF(`plan_qty`, 0) * 100, 2) AS `achievement_rate`
FROM `mes_shift_output`;

-- 试点视图 2：良率趋势（对应 Dataset yield_trend）
CREATE VIEW `v_yield_trend` AS
SELECT
  `plant`,
  `line_code`,
  DATE_FORMAT(`biz_date`, '%Y-%m-%d') AS `date`,
  ROUND(`ok_qty` / NULLIF(`total_qty`, 0) * 100, 2) AS `yield_rate`
FROM `mes_daily_yield`;

-- 种子数据：output_shift（多工厂/产线/班次）
INSERT INTO `mes_shift_output` (`plant`, `line_code`, `shift`, `biz_date`, `output_qty`, `plan_qty`) VALUES
('P01', 'L01', 'A', '2026-06-05', 1180, 1500),
('P01', 'L01', 'B', '2026-06-05', 1320, 1500),
('P01', 'L01', 'C', '2026-06-05', 1090, 1500),
('P01', 'L02', 'A', '2026-06-05', 1450, 1600),
('P01', 'L02', 'B', '2026-06-05', 1510, 1600),
('P01', 'L03', 'A', '2026-06-05', 1280, 1500),
('P01', 'L03', 'B', '2026-06-05', 1410, 1500),
('P01', 'L03', 'C', '2026-06-05', 1205, 1500),
('P02', 'L01', 'A', '2026-06-05', 980,  1200),
('P02', 'L01', 'B', '2026-06-05', 1050, 1200);

-- 种子数据：yield_trend（近 7 天，与 Mock 趋势接近）
INSERT INTO `mes_daily_yield` (`plant`, `line_code`, `biz_date`, `ok_qty`, `total_qty`) VALUES
('P01', 'L03', '2026-06-01', 955, 1000),
('P01', 'L03', '2026-06-02', 958, 1000),
('P01', 'L03', '2026-06-03', 961, 1000),
('P01', 'L03', '2026-06-04', 964, 1000),
('P01', 'L03', '2026-06-05', 967, 1000),
('P01', 'L03', '2026-06-06', 970, 1000),
('P01', 'L03', '2026-06-07', 973, 1000);
