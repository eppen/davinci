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

@Order(10)
@Component
@Slf4j
public class ChartTypeBootstrapRunner implements ApplicationRunner {

    @Autowired
    private ChartTypeMapper chartTypeMapper;

    @Override
    public void run(ApplicationArguments args) {
        try {
            if (chartTypeMapper.count() > 0) {
                return;
            }
            log.info("Seeding builtin chart types...");
            Date now = new Date();
            Object[][] seeds = {
                    {"table", "table", "表格", "icon-table", 1, "other", "[{\"dimension\":[0,9999],\"metric\":[0,9999]}]"},
                    {"scorecard", "scorecard", "翻牌器", "icon-calendar1", 13, "other", "[{\"dimension\":[0,0],\"metric\":[1,9999]}]"},
                    {"line", "line", "折线图", "icon-chart-line", 2, "cartesian", "[{\"dimension\":1,\"metric\":[1,9999]}]"},
                    {"bar", "bar", "柱状图", "icon-chart-bar", 3, "cartesian", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"scatter", "scatter", "散点图", "icon-scatter-chart", 4, "cartesian", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"pie", "pie", "饼图", "icon-chartpie", 5, "other", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"funnel", "funnel", "漏斗图", "icon-iconloudoutu", 6, "other", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"radar", "radar", "雷达图", "icon-radarchart", 10, "other", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"sankey", "sankey", "桑基图", "icon-kongjiansangjitu", 9, "other", "[{\"dimension\":[1,2],\"metric\":[1,9999]}]"},
                    {"parallel", "parallel", "平行坐标图", "icon-parallel", 8, "other", "[{\"dimension\":[0,9999],\"metric\":[0,9999]}]"},
                    {"map", "map", "地图", "icon-china", 7, "other", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"wordCloud", "wordCloud", "词云", "icon-chartwordcloud", 11, "other", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"waterfall", "waterfall", "瀑布图", "icon-waterfall", 12, "cartesian", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"iframe", "iframe", "内嵌网页", "icon-iframe", 14, "other", "[{\"dimension\":[0,0],\"metric\":[0,0]}]"},
                    {"richText", "richText", "富文本", "icon-text", 15, "other", "[{\"dimension\":[0,0],\"metric\":[0,0]}]"},
                    {"doubleYAxis", "doubleYAxis", "双Y轴图", "icon-duplex", 16, "cartesian", "[{\"dimension\":[0,1],\"metric\":[1,9999]}]"},
                    {"gauge", "gauge", "仪表盘", "icon-gauge", 17, "other", "[{\"dimension\":[0,1],\"metric\":[1,1]}]"}
            };
            for (Object[] seed : seeds) {
                ChartType ct = new ChartType();
                ct.setCode((String) seed[0]);
                ct.setName((String) seed[1]);
                ct.setTitle((String) seed[2]);
                ct.setIcon((String) seed[3]);
                ct.setCategory("general");
                ct.setRenderer("echarts");
                ct.setConfigSchema("{}");
                int chartId = (Integer) seed[4];
                String coordinate = (String) seed[5];
                String rules = (String) seed[6];
                ct.setDataSchema("{\"id\":" + chartId + ",\"coordinate\":\"" + coordinate + "\",\"rules\":" + rules + "}");
                ct.setVersion(1);
                ct.setBuiltin(true);
                ct.setEnabled(true);
                ct.setCreateTime(now);
                ct.setUpdateTime(now);
                chartTypeMapper.insert(ct);
            }
            log.info("Seeded {} builtin chart types", seeds.length);
        } catch (Exception e) {
            log.warn("Chart type bootstrap skipped: {}", e.getMessage());
        }
    }
}
