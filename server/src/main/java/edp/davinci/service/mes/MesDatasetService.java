package edp.davinci.service.mes;

import com.alibaba.druid.util.StringUtils;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import edp.core.exception.ServerException;
import edp.core.model.PaginateWithQueryColumns;
import edp.core.model.QueryColumn;
import edp.core.utils.MD5Util;
import edp.core.utils.RedisUtils;
import edp.davinci.core.config.MesIntegrationProperties;
import edp.davinci.core.enums.SourceTypeEnum;
import edp.davinci.dto.mes.MesDatasetColumn;
import edp.davinci.dto.mes.MesDatasetPagination;
import edp.davinci.dto.mes.MesDatasetQueryRequest;
import edp.davinci.dto.mes.MesDatasetQueryResponse;
import edp.davinci.dto.viewDto.ViewExecuteParam;
import edp.davinci.dto.viewDto.ViewWithSource;
import edp.davinci.model.Source;
import edp.davinci.model.SqlVariable;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.CollectionUtils;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;
import java.util.stream.Collectors;

@Slf4j
@Service
public class MesDatasetService {

    @Autowired
    private MesDatasetClient mesDatasetClient;

    @Autowired
    private RedisUtils redisUtils;

    @Autowired
    private MesIntegrationProperties mesIntegrationProperties;

    public boolean isMesApiSource(Source source) {
        return source != null && SourceTypeEnum.MES_API.getType().equals(source.getType());
    }

    public PaginateWithQueryColumns queryViewData(ViewWithSource viewWithSource, ViewExecuteParam executeParam, String forwardToken)
            throws ServerException {
        Source source = viewWithSource.getSource();
        String datasetCode = resolveDatasetCode(viewWithSource);
        MesDatasetQueryRequest request = buildRequest(viewWithSource.getVariables(), executeParam);
        String cacheKey = buildCacheKey(datasetCode, request);
        if (!Boolean.TRUE.equals(executeParam.getFlush())) {
            Object cached = redisUtils.get(cacheKey);
            if (cached instanceof PaginateWithQueryColumns) {
                log.info("MES dataset cache hit: {}", datasetCode);
                return (PaginateWithQueryColumns) cached;
            }
        }
        MesDatasetQueryResponse response = mesDatasetClient.query(source, datasetCode, request, forwardToken);
        PaginateWithQueryColumns paginate = toPaginate(response, executeParam);
        redisUtils.set(cacheKey, paginate, (long) mesIntegrationProperties.getDatasetCacheSeconds(), TimeUnit.SECONDS);
        return paginate;
    }

    public PaginateWithQueryColumns querySourcePreview(Source source, String sql, List<SqlVariable> variables, Integer limit)
            throws ServerException {
        String datasetCode = resolveDatasetCodeFromConfig(source.getConfig(), sql);
        MesDatasetQueryRequest request = new MesDatasetQueryRequest();
        request.setParams(buildParamsFromVariables(variables, null));
        if (limit != null && limit > 0) {
            request.getPagination().setPageSize(limit);
        }
        MesDatasetQueryResponse response = mesDatasetClient.query(source, datasetCode, request, null);
        ViewExecuteParam param = new ViewExecuteParam();
        param.setPageNo(1);
        param.setPageSize(request.getPagination().getPageSize());
        return toPaginate(response, param);
    }

    private String resolveDatasetCode(ViewWithSource viewWithSource) throws ServerException {
        if (!StringUtils.isEmpty(viewWithSource.getConfig())) {
            try {
                JSONObject cfg = JSONObject.parseObject(viewWithSource.getConfig());
                if (!StringUtils.isEmpty(cfg.getString("datasetCode"))) {
                    return cfg.getString("datasetCode");
                }
            } catch (Exception ignored) {
            }
        }
        return resolveDatasetCodeFromConfig(viewWithSource.getSource().getConfig(), viewWithSource.getSql());
    }

    private String resolveDatasetCodeFromConfig(String sourceConfig, String viewSql) throws ServerException {
        JSONObject config = JSONObject.parseObject(sourceConfig);
        if (!StringUtils.isEmpty(config.getString("datasetCode"))) {
            return config.getString("datasetCode");
        }
        if (!StringUtils.isEmpty(viewSql) && viewSql.trim().startsWith("{")) {
            try {
                JSONObject viewCfg = JSONObject.parseObject(viewSql);
                if (!StringUtils.isEmpty(viewCfg.getString("datasetCode"))) {
                    return viewCfg.getString("datasetCode");
                }
            } catch (Exception ignored) {
            }
        }
        throw new ServerException("MES datasetCode is not configured on Source or View");
    }

    private MesDatasetQueryRequest buildRequest(List<SqlVariable> variables, ViewExecuteParam executeParam) {
        MesDatasetQueryRequest request = new MesDatasetQueryRequest();
        request.setParams(buildParamsFromVariables(variables, executeParam));
        MesDatasetPagination pagination = new MesDatasetPagination();
        if (executeParam != null) {
            if (executeParam.getPageNo() > 0) {
                pagination.setPageNo(executeParam.getPageNo());
            }
            if (executeParam.getPageSize() > 0) {
                pagination.setPageSize(executeParam.getPageSize());
            }
        }
        request.setPagination(pagination);
        return request;
    }

    private Map<String, Object> buildParamsFromVariables(List<SqlVariable> variables, ViewExecuteParam executeParam) {
        Map<String, Object> params = new HashMap<>();
        if (!CollectionUtils.isEmpty(variables) && executeParam != null && !CollectionUtils.isEmpty(executeParam.getParams())) {
            for (int i = 0; i < variables.size() && i < executeParam.getParams().size(); i++) {
                SqlVariable variable = variables.get(i);
                Object value = executeParam.getParams().get(i);
                if (variable != null && !StringUtils.isEmpty(variable.getName())) {
                    params.put(variable.getName().replace("$", "").replace("{", "").replace("}", ""), value);
                }
            }
        }
        if (executeParam != null && !CollectionUtils.isEmpty(executeParam.getParams())) {
            List<String> keys = new ArrayList<>(params.keySet());
            int idx = 0;
            for (Object val : executeParam.getParams()) {
                if (idx < keys.size()) {
                    params.put(keys.get(idx), val);
                }
                idx++;
            }
        }
        return params;
    }

    private PaginateWithQueryColumns toPaginate(MesDatasetQueryResponse response, ViewExecuteParam executeParam) {
        PaginateWithQueryColumns paginate = new PaginateWithQueryColumns();
        List<Map<String, Object>> rows = response.getRows() != null ? response.getRows() : new ArrayList<>();
        paginate.setResultList(rows);
        if (response.getMeta() != null && response.getMeta().getTotalCount() != null) {
            paginate.setTotalCount(response.getMeta().getTotalCount());
        } else {
            paginate.setTotalCount(rows.size());
        }
        if (executeParam != null) {
            paginate.setPageNo(executeParam.getPageNo());
            paginate.setPageSize(executeParam.getPageSize());
        }
        List<QueryColumn> columns = new ArrayList<>();
        if (!CollectionUtils.isEmpty(response.getColumns())) {
            for (MesDatasetColumn col : response.getColumns()) {
                String colType = StringUtils.isEmpty(col.getType()) ? "string" : col.getType();
                columns.add(new QueryColumn(col.getName(), colType));
            }
        } else if (!rows.isEmpty()) {
            for (String k : rows.get(0).keySet()) {
                columns.add(new QueryColumn(k, "string"));
            }
        }
        paginate.setColumns(columns);
        return paginate;
    }

    private String buildCacheKey(String datasetCode, MesDatasetQueryRequest request) {
        return "mes:dataset:" + MD5Util.getMD5(datasetCode + JSON.toJSONString(request), true, 32);
    }
}
