package edp.davinci.controller;

import edp.core.annotation.AuthIgnore;
import edp.davinci.dto.mes.MesDatasetColumn;
import edp.davinci.dto.mes.MesDatasetMeta;
import edp.davinci.dto.mes.MesDatasetQueryRequest;
import edp.davinci.dto.mes.MesDatasetQueryResponse;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 开发用 MES Dataset Mock，与 docs/mes-dataset-api.openapi.yaml 契约一致。
 * 生产环境由 MES 提供真实实现；Davinci 配置 baseUrl 指向 MES 或本机 Mock。
 */
@Api(tags = "mes-dataset-mock")
@RestController
@RequestMapping(value = "/api/mes/dataset", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
public class MesDatasetMockController {

    @AuthIgnore
    @ApiOperation(value = "mock dataset query")
    @PostMapping(value = "/{datasetCode}/query", consumes = MediaType.APPLICATION_JSON_VALUE)
    public MesDatasetQueryResponse query(@PathVariable String datasetCode,
                                         @RequestBody(required = false) MesDatasetQueryRequest request) {
        Map<String, Object> params = request != null && request.getParams() != null
                ? request.getParams() : new HashMap<>();
        String plant = String.valueOf(params.getOrDefault("plant", "P01"));
        String line = String.valueOf(params.getOrDefault("line", "L03"));
        String shift = String.valueOf(params.getOrDefault("shift", "A"));

        MesDatasetQueryResponse response = new MesDatasetQueryResponse();
        List<MesDatasetColumn> columns = new ArrayList<>();
        List<Map<String, Object>> rows = new ArrayList<>();

        if ("output_shift".equals(datasetCode)) {
            columns.add(column("line_code", "string", "dimension"));
            columns.add(column("shift", "string", "dimension"));
            columns.add(column("output_qty", "number", "metric"));
            columns.add(column("plan_qty", "number", "metric"));
            Map<String, Object> row = new HashMap<>();
            row.put("line_code", line);
            row.put("shift", shift);
            row.put("output_qty", 1280);
            row.put("plan_qty", 1500);
            rows.add(row);
        } else if ("yield_trend".equals(datasetCode)) {
            columns.add(column("date", "string", "dimension"));
            columns.add(column("yield_rate", "number", "metric"));
            for (int i = 0; i < 7; i++) {
                Map<String, Object> row = new HashMap<>();
                row.put("date", "2026-06-0" + (i + 1));
                row.put("yield_rate", 95.5 + i * 0.3);
                rows.add(row);
            }
        } else if ("oee_shift".equals(datasetCode)) {
            columns.add(column("line_code", "string", "dimension"));
            columns.add(column("oee", "number", "metric"));
            Map<String, Object> row = new HashMap<>();
            row.put("line_code", line);
            row.put("oee", 82.5);
            rows.add(row);
        } else if ("defect_pareto".equals(datasetCode)) {
            columns.add(column("defect_name", "string", "dimension"));
            columns.add(column("defect_qty", "number", "metric"));
            columns.add(column("cumulative_pct", "number", "metric"));
            String[] defects = {"划伤", "气泡", "尺寸偏差", "色差", "脏污"};
            int[] qtys = {120, 85, 60, 40, 25};
            double[] pcts = {35.3, 60.3, 78.0, 89.7, 100.0};
            for (int i = 0; i < defects.length; i++) {
                Map<String, Object> row = new HashMap<>();
                row.put("defect_name", defects[i]);
                row.put("defect_qty", qtys[i]);
                row.put("cumulative_pct", pcts[i]);
                rows.add(row);
            }
        } else if ("equip_status".equals(datasetCode)) {
            columns.add(column("equip_code", "string", "dimension"));
            columns.add(column("status_code", "number", "metric"));
            String[] equips = {"EQ-01", "EQ-02", "EQ-03", "EQ-04"};
            int[] statuses = {0, 1, 2, 0};
            for (int i = 0; i < equips.length; i++) {
                Map<String, Object> row = new HashMap<>();
                row.put("equip_code", equips[i]);
                row.put("status_code", statuses[i]);
                rows.add(row);
            }
        } else if ("wip_orders".equals(datasetCode)) {
            columns.add(column("wo_no", "string", "dimension"));
            columns.add(column("product", "string", "dimension"));
            columns.add(column("qty", "number", "metric"));
            columns.add(column("status", "string", "dimension"));
            String[][] orders = {
                    {"WO-1001", "产品A", "200", "生产中"},
                    {"WO-1002", "产品B", "150", "待开工"},
                    {"WO-1003", "产品C", "80", "生产中"}
            };
            for (String[] o : orders) {
                Map<String, Object> row = new HashMap<>();
                row.put("wo_no", o[0]);
                row.put("product", o[1]);
                row.put("qty", Integer.parseInt(o[2]));
                row.put("status", o[3]);
                rows.add(row);
            }
        } else {
            columns.add(column("plant", "string", "dimension"));
            columns.add(column("value", "number", "metric"));
            Map<String, Object> row = new HashMap<>();
            row.put("plant", plant);
            row.put("value", 100);
            rows.add(row);
        }

        response.setColumns(columns);
        response.setRows(rows);
        MesDatasetMeta meta = new MesDatasetMeta();
        meta.setTotalCount(rows.size());
        meta.setCached(false);
        meta.setQueryTimeMs(12L);
        response.setMeta(meta);
        return response;
    }

    private MesDatasetColumn column(String name, String type, String role) {
        MesDatasetColumn c = new MesDatasetColumn();
        c.setName(name);
        c.setType(type);
        c.setRole(role);
        return c;
    }
}
