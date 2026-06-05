-- Phase 2: MES system chart types (SQL Server) - idempotent inserts

IF NOT EXISTS (SELECT 1 FROM chart_type WHERE code = 'mes-output-card')
BEGIN
  INSERT INTO chart_type (code, name, title, icon, category, renderer, config_schema, data_schema, option_template, version, builtin, enabled, create_time, update_time)
  VALUES ('mes-output-card', 'mes-output-card', N'产量卡片', 'icon-calendar1', 'mes', 'echarts',
    '[{"key":"unit","title":"单位","component":"input","default":"件"},{"key":"title","title":"标题","component":"input","default":"当班产量"}]',
    '{"id":901,"coordinate":"other","rules":[{"dimension":[0,1],"metric":[1,1]}],"data":{"cols":{"title":"列","type":"category"},"rows":{"title":"行","type":"category"},"metrics":{"title":"指标","type":"value"},"filters":{"title":"筛选","type":"all"}}}',
    '{"graphic":[{"type":"text","left":"center","top":"40%","style":{"text":"{{metrics[0].value}}{{style.unit}}","fontSize":36,"fontWeight":"bold","fill":"#333","textAlign":"center"}},{"type":"text","left":"center","top":"60%","style":{"text":"{{style.title}}","fontSize":14,"fill":"#666","textAlign":"center"}}]}',
    1, 1, 1, GETDATE(), GETDATE());
END

IF NOT EXISTS (SELECT 1 FROM chart_type WHERE code = 'mes-oee-gauge')
BEGIN
  INSERT INTO chart_type (code, name, title, icon, category, renderer, config_schema, data_schema, option_template, version, builtin, enabled, create_time, update_time)
  VALUES ('mes-oee-gauge', 'mes-oee-gauge', N'OEE 仪表盘', 'icon-gauge', 'mes', 'echarts',
    '[{"key":"min","title":"最小值","component":"number","default":0},{"key":"max","title":"最大值","component":"number","default":100},{"key":"unit","title":"单位","component":"input","default":"%"}]',
    '{"id":902,"coordinate":"other","rules":[{"dimension":[0,1],"metric":[1,1]}],"data":{"cols":{"title":"列","type":"category"},"rows":{"title":"行","type":"category"},"metrics":{"title":"指标","type":"value"},"filters":{"title":"筛选","type":"all"}}}',
    '{"series":[{"type":"gauge","min":"{{style.min}}","max":"{{style.max}}","detail":{"formatter":"{value}{{style.unit}}"},"data":[{"value":"{{metrics[0].value}}","name":"{{metrics[0].name}}"}]}]}',
    1, 1, 1, GETDATE(), GETDATE());
END

IF NOT EXISTS (SELECT 1 FROM chart_type WHERE code = 'mes-yield-trend')
BEGIN
  INSERT INTO chart_type (code, name, title, icon, category, renderer, config_schema, data_schema, option_template, version, builtin, enabled, create_time, update_time)
  VALUES ('mes-yield-trend', 'mes-yield-trend', N'良率趋势', 'icon-chart-line', 'mes', 'echarts',
    '[{"key":"smooth","title":"平滑曲线","component":"switch","default":true}]',
    '{"id":903,"coordinate":"cartesian","rules":[{"dimension":[1,1],"metric":[1,9999]}],"data":{"cols":{"title":"列","type":"category"},"rows":{"title":"行","type":"category"},"metrics":{"title":"指标","type":"value"},"filters":{"title":"筛选","type":"all"}}}',
    '{"xAxis":{"type":"category","data":"{{colValues}}"},"yAxis":{"type":"value"},"series":[{"type":"line","smooth":"{{style.smooth}}","data":"{{metricValues}}"}]}',
    1, 1, 1, GETDATE(), GETDATE());
END

IF NOT EXISTS (SELECT 1 FROM chart_type WHERE code = 'mes-pareto-bar')
BEGIN
  INSERT INTO chart_type (code, name, title, icon, category, renderer, config_schema, data_schema, option_template, version, builtin, enabled, create_time, update_time)
  VALUES ('mes-pareto-bar', 'mes-pareto-bar', N'不良 Pareto', 'icon-chart-bar', 'mes', 'echarts',
    '[{"key":"showLine","title":"显示累计线","component":"switch","default":true}]',
    '{"id":904,"coordinate":"cartesian","rules":[{"dimension":[1,1],"metric":[1,2]}],"data":{"cols":{"title":"列","type":"category"},"rows":{"title":"行","type":"category"},"metrics":{"title":"指标","type":"value"},"filters":{"title":"筛选","type":"all"}}}',
    '{"xAxis":{"type":"category","data":"{{colValues}}"},"yAxis":[{"type":"value"},{"type":"value","max":100}],"series":[{"type":"bar","data":"{{metricValues}}"},{"type":"line","yAxisIndex":1,"data":"{{metricValues2}}"}]}',
    1, 1, 1, GETDATE(), GETDATE());
END

IF NOT EXISTS (SELECT 1 FROM chart_type WHERE code = 'mes-equip-status')
BEGIN
  INSERT INTO chart_type (code, name, title, icon, category, renderer, config_schema, data_schema, option_template, version, builtin, enabled, create_time, update_time)
  VALUES ('mes-equip-status', 'mes-equip-status', N'设备状态矩阵', 'icon-scatter-chart', 'mes', 'echarts',
    '[{"key":"okColor","title":"正常色","component":"color","default":"#52c41a"},{"key":"warnColor","title":"警告色","component":"color","default":"#faad14"},{"key":"errorColor","title":"故障色","component":"color","default":"#f5222d"}]',
    '{"id":905,"coordinate":"cartesian","rules":[{"dimension":[1,1],"metric":[1,1]}],"data":{"cols":{"title":"列","type":"category"},"rows":{"title":"行","type":"category"},"metrics":{"title":"指标","type":"value"},"filters":{"title":"筛选","type":"all"}}}',
    '{"xAxis":{"type":"category","data":"{{colValues}}"},"yAxis":{"type":"category","data":"{{metricValues}}"},"series":[{"type":"scatter","symbolSize":40,"data":[[0,0,1],[1,0,2],[2,0,0]]}]}',
    1, 1, 1, GETDATE(), GETDATE());
END

IF NOT EXISTS (SELECT 1 FROM chart_type WHERE code = 'mes-wip-table')
BEGIN
  INSERT INTO chart_type (code, name, title, icon, category, renderer, config_schema, data_schema, option_template, version, builtin, enabled, create_time, update_time)
  VALUES ('mes-wip-table', 'mes-wip-table', N'在制工单表', 'icon-table', 'mes', 'table',
    '[]',
    '{"id":1,"coordinate":"other","rules":[{"dimension":[0,9999],"metric":[0,9999]}],"data":{"cols":{"title":"列","type":"category"},"rows":{"title":"行","type":"category"},"metrics":{"title":"指标","type":"value"},"filters":{"title":"筛选","type":"all"}}}',
    NULL,
    1, 1, 1, GETDATE(), GETDATE());
END
