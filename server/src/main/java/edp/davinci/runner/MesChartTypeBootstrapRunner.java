package edp.davinci.runner;

import edp.davinci.dao.ChartTypeMapper;
import edp.davinci.model.ChartType;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.core.annotation.Order;
import org.springframework.stereotype.Component;

import java.util.Date;

@Order(11)
@Component
@Slf4j
public class MesChartTypeBootstrapRunner implements ApplicationRunner {

    @Autowired
    private ChartTypeMapper chartTypeMapper;

    @Override
    public void run(ApplicationArguments args) {
        try {
            seedIfAbsent("mes-output-card", buildOutputCard());
            seedIfAbsent("mes-oee-gauge", buildOeeGauge());
            seedIfAbsent("mes-yield-trend", buildYieldTrend());
            seedIfAbsent("mes-pareto-bar", buildParetoBar());
            seedIfAbsent("mes-equip-status", buildEquipStatus());
            seedIfAbsent("mes-wip-table", buildWipTable());
        } catch (Exception e) {
            log.warn("MES chart type bootstrap skipped: {}", e.getMessage());
        }
    }

    private void seedIfAbsent(String code, ChartType ct) {
        if (chartTypeMapper.getByCode(code) != null) {
            return;
        }
        Date now = new Date();
        ct.setCreateTime(now);
        ct.setUpdateTime(now);
        chartTypeMapper.insert(ct);
        log.info("Seeded MES chart type: {}", code);
    }

    private ChartType base(String code, String name, String title, String icon, int chartId,
                           String coordinate, String rules, String configSchema, String optionTemplate) {
        ChartType ct = new ChartType();
        ct.setCode(code);
        ct.setName(name);
        ct.setTitle(title);
        ct.setIcon(icon);
        ct.setCategory("mes");
        ct.setRenderer("echarts");
        ct.setConfigSchema(configSchema);
        ct.setDataSchema("{\"id\":" + chartId + ",\"coordinate\":\"" + coordinate + "\",\"rules\":" + rules
                + ",\"data\":{\"cols\":{\"title\":\"列\",\"type\":\"category\"},\"rows\":{\"title\":\"行\",\"type\":\"category\"}"
                + ",\"metrics\":{\"title\":\"指标\",\"type\":\"value\"},\"filters\":{\"title\":\"筛选\",\"type\":\"all\"}}}");
        ct.setOptionTemplate(optionTemplate);
        ct.setVersion(1);
        ct.setBuiltin(true);
        ct.setEnabled(true);
        return ct;
    }

    private ChartType buildOutputCard() {
        String style = "[{\"key\":\"unit\",\"title\":\"单位\",\"component\":\"input\",\"default\":\"件\"}"
                + ",{\"key\":\"title\",\"title\":\"标题\",\"component\":\"input\",\"default\":\"当班产量\"}]";
        String option = "{\"graphic\":[{\"type\":\"text\",\"left\":\"center\",\"top\":\"40%\""
                + ",\"style\":{\"text\":\"{{metrics[0].value}}{{style.unit}}\",\"fontSize\":36,\"fontWeight\":\"bold\""
                + ",\"fill\":\"#333\",\"textAlign\":\"center\"}},{\"type\":\"text\",\"left\":\"center\",\"top\":\"60%\""
                + ",\"style\":{\"text\":\"{{style.title}}\",\"fontSize\":14,\"fill\":\"#666\",\"textAlign\":\"center\"}}]}";
        return base("mes-output-card", "mes-output-card", "产量卡片", "icon-calendar1", 901, "other",
                "[{\"dimension\":[0,1],\"metric\":[1,1]}]", style, option);
    }

    private ChartType buildOeeGauge() {
        String style = "[{\"key\":\"min\",\"title\":\"最小值\",\"component\":\"number\",\"default\":0}"
                + ",{\"key\":\"max\",\"title\":\"最大值\",\"component\":\"number\",\"default\":100}"
                + ",{\"key\":\"unit\",\"title\":\"单位\",\"component\":\"input\",\"default\":\"%\"}]";
        String option = "{\"series\":[{\"type\":\"gauge\",\"min\":\"{{style.min}}\",\"max\":\"{{style.max}}\""
                + ",\"detail\":{\"formatter\":\"{value}{{style.unit}}\"}"
                + ",\"data\":[{\"value\":\"{{metrics[0].value}}\",\"name\":\"{{metrics[0].name}}\"}]}]}";
        return base("mes-oee-gauge", "mes-oee-gauge", "OEE 仪表盘", "icon-gauge", 902, "other",
                "[{\"dimension\":[0,1],\"metric\":[1,1]}]", style, option);
    }

    private ChartType buildYieldTrend() {
        String style = "[{\"key\":\"smooth\",\"title\":\"平滑曲线\",\"component\":\"switch\",\"default\":true}]";
        String option = "{\"xAxis\":{\"type\":\"category\",\"data\":\"{{colValues}}\"}"
                + ",\"yAxis\":{\"type\":\"value\"}"
                + ",\"series\":[{\"type\":\"line\",\"smooth\":\"{{style.smooth}}\",\"data\":\"{{metricValues}}\"}]}";
        return base("mes-yield-trend", "mes-yield-trend", "良率趋势", "icon-chart-line", 903, "cartesian",
                "[{\"dimension\":[1,1],\"metric\":[1,9999]}]", style, option);
    }

    private ChartType buildParetoBar() {
        String style = "[{\"key\":\"showLine\",\"title\":\"显示累计线\",\"component\":\"switch\",\"default\":true}]";
        String option = "{\"xAxis\":{\"type\":\"category\",\"data\":\"{{colValues}}\"}"
                + ",\"yAxis\":[{\"type\":\"value\"},{\"type\":\"value\",\"max\":100}]"
                + ",\"series\":[{\"type\":\"bar\",\"data\":\"{{metricValues}}\"}"
                + ",{\"type\":\"line\",\"yAxisIndex\":1,\"data\":\"{{metricValues2}}\"}]}";
        return base("mes-pareto-bar", "mes-pareto-bar", "不良 Pareto", "icon-chart-bar", 904, "cartesian",
                "[{\"dimension\":[1,1],\"metric\":[1,2]}]", style, option);
    }

    private ChartType buildEquipStatus() {
        String style = "[{\"key\":\"okColor\",\"title\":\"正常色\",\"component\":\"color\",\"default\":\"#52c41a\"}"
                + ",{\"key\":\"warnColor\",\"title\":\"警告色\",\"component\":\"color\",\"default\":\"#faad14\"}"
                + ",{\"key\":\"errorColor\",\"title\":\"故障色\",\"component\":\"color\",\"default\":\"#f5222d\"}]";
        String option = "{\"xAxis\":{\"type\":\"category\",\"data\":\"{{colValues}}\"}"
                + ",\"yAxis\":{\"type\":\"category\",\"data\":\"{{metricValues}}\"}"
                + ",\"series\":[{\"type\":\"scatter\",\"symbolSize\":40"
                + ",\"data\":[[0,0,1],[1,0,2],[2,0,0]]}]}";
        return base("mes-equip-status", "mes-equip-status", "设备状态矩阵", "icon-scatter-chart", 905, "cartesian",
                "[{\"dimension\":[1,1],\"metric\":[1,1]}]", style, option);
    }

    private ChartType buildWipTable() {
        ChartType ct = new ChartType();
        ct.setCode("mes-wip-table");
        ct.setName("mes-wip-table");
        ct.setTitle("在制工单表");
        ct.setIcon("icon-table");
        ct.setCategory("mes");
        ct.setRenderer("table");
        ct.setConfigSchema("[]");
        ct.setDataSchema("{\"id\":1,\"coordinate\":\"other\",\"rules\":[{\"dimension\":[0,9999],\"metric\":[0,9999]}]"
                + ",\"data\":{\"cols\":{\"title\":\"列\",\"type\":\"category\"},\"rows\":{\"title\":\"行\",\"type\":\"category\"}"
                + ",\"metrics\":{\"title\":\"指标\",\"type\":\"value\"},\"filters\":{\"title\":\"筛选\",\"type\":\"all\"}}}");
        ct.setOptionTemplate(null);
        ct.setVersion(1);
        ct.setBuiltin(true);
        ct.setEnabled(true);
        return ct;
    }
}
