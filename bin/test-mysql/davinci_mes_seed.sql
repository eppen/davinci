/*
 * Davinci 元库种子：MES 测试 JDBC Source + View
 * 目标库：davinci0.3 @ localhost:3306
 * 推荐执行：python bin/test-mysql/setup_davinci_mes_views.py
 */

USE `davinci0.3`;

-- Source: MES-Test-MySQL（指向 test 库汇总视图）
INSERT INTO `source`
  (`name`, `description`, `config`, `type`, `project_id`, `create_by`, `create_time`, `update_by`, `update_time`, `is_folder`, `index`)
SELECT
  'MES-Test-MySQL',
  'MES Phase1 测试只读库（test 库 v_output_shift / v_yield_trend）',
  '{"ext":false,"password":"","version":"","properties":[],"url":"jdbc:mysql://localhost:3306/test?useUnicode=true&characterEncoding=utf-8&useSSL=false&serverTimezone=Asia/Shanghai","username":"root","name":"mysql"}',
  'jdbc',
  1,
  1,
  NOW(),
  1,
  NOW(),
  0,
  1
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `source` WHERE `project_id` = 1 AND `name` = 'MES-Test-MySQL'
);

SET @source_id := (SELECT `id` FROM `source` WHERE `project_id` = 1 AND `name` = 'MES-Test-MySQL' LIMIT 1);

-- View 1: output_shift
INSERT INTO `view`
  (`name`, `description`, `project_id`, `source_id`, `sql`, `model`, `variable`, `create_by`, `create_time`, `update_by`, `update_time`, `is_folder`, `index`)
SELECT
  'MES v_output_shift',
  'MES 通道 B 测试视图',
  1,
  @source_id,
  'SELECT\n  line_code,\n  shift,\n  output_qty,\n  plan_qty,\n  achievement_rate\nFROM v_output_shift\nWHERE plant = $plant$\n  AND line_code = $line$\n  AND shift = $shift$',
  '{"line_code":{"sqlType":"VARCHAR","visualType":"string","modelType":"category"},"shift":{"sqlType":"CHAR","visualType":"string","modelType":"category"},"output_qty":{"sqlType":"INT","visualType":"number","modelType":"value"},"plan_qty":{"sqlType":"INT","visualType":"number","modelType":"value"},"achievement_rate":{"sqlType":"DECIMAL","visualType":"number","modelType":"value"}}',
  '[{"name":"plant","type":"query","valueType":"string","udf":false,"defaultValues":["P01"],"channel":null},{"name":"line","type":"query","valueType":"string","udf":false,"defaultValues":["L03"],"channel":null},{"name":"shift","type":"query","valueType":"string","udf":false,"defaultValues":["A"],"channel":null}]',
  1,
  NOW(),
  1,
  NOW(),
  0,
  1
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `view` WHERE `project_id` = 1 AND `name` = 'MES v_output_shift'
);

-- View 2: yield_trend
INSERT INTO `view`
  (`name`, `description`, `project_id`, `source_id`, `sql`, `model`, `variable`, `create_by`, `create_time`, `update_by`, `update_time`, `is_folder`, `index`)
SELECT
  'MES v_yield_trend',
  'MES 通道 B 测试视图',
  1,
  @source_id,
  'SELECT\n  date,\n  yield_rate\nFROM v_yield_trend\nWHERE plant = $plant$\n  AND line_code = $line$\nORDER BY date',
  '{"date":{"sqlType":"VARCHAR","visualType":"string","modelType":"category"},"yield_rate":{"sqlType":"DECIMAL","visualType":"number","modelType":"value"}}',
  '[{"name":"plant","type":"query","valueType":"string","udf":false,"defaultValues":["P01"],"channel":null},{"name":"line","type":"query","valueType":"string","udf":false,"defaultValues":["L03"],"channel":null}]',
  1,
  NOW(),
  1,
  NOW(),
  0,
  2
FROM DUAL
WHERE NOT EXISTS (
  SELECT 1 FROM `view` WHERE `project_id` = 1 AND `name` = 'MES v_yield_trend'
);
