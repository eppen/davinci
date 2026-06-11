package edp.davinci.service.impl;

import com.alibaba.druid.util.StringUtils;
import edp.core.exception.ServerException;
import edp.davinci.dao.ChartTypeMapper;
import edp.davinci.model.ChartType;
import edp.davinci.model.User;
import edp.davinci.service.ChartTypeService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.Date;
import java.util.List;

@Slf4j
@Service
public class ChartTypeServiceImpl implements ChartTypeService {

    @Autowired
    private ChartTypeMapper chartTypeMapper;

    @Override
    public List<ChartType> list(Boolean enabled) {
        return chartTypeMapper.list(enabled);
    }

    @Override
    public ChartType getByCode(String code) throws ServerException {
        if (StringUtils.isEmpty(code)) {
            throw new ServerException("Chart type code is required");
        }
        ChartType chartType = chartTypeMapper.getByCode(code);
        if (chartType == null) {
            throw new ServerException("Chart type not found");
        }
        return chartType;
    }

    @Override
    @Transactional
    public ChartType create(ChartType chartType, User user) throws ServerException {
        validate(chartType, true);
        if (chartTypeMapper.getByCode(chartType.getCode()) != null) {
            throw new ServerException("Chart type code already exists");
        }
        Date now = new Date();
        chartType.setCreateBy(user.getId());
        chartType.setCreateTime(now);
        chartType.setUpdateBy(user.getId());
        chartType.setUpdateTime(now);
        if (chartType.getVersion() == null) {
            chartType.setVersion(1);
        }
        if (chartType.getBuiltin() == null) {
            chartType.setBuiltin(false);
        }
        if (chartType.getEnabled() == null) {
            chartType.setEnabled(true);
        }
        if (chartType.getCategory() == null) {
            chartType.setCategory("general");
        }
        if (chartType.getRenderer() == null) {
            chartType.setRenderer("echarts");
        }
        if (chartType.getConfigSchema() == null) {
            chartType.setConfigSchema("{}");
        }
        if (chartType.getDataSchema() == null) {
            chartType.setDataSchema("{}");
        }
        chartTypeMapper.insert(chartType);
        return chartTypeMapper.getById(chartType.getId());
    }

    @Override
    @Transactional
    public ChartType update(ChartType chartType, User user) throws ServerException {
        if (chartType.getId() == null) {
            throw new ServerException("Chart type id is required");
        }
        ChartType existing = chartTypeMapper.getById(chartType.getId());
        if (existing == null) {
            throw new ServerException("Chart type not found");
        }
        validate(chartType, false);
        chartType.setUpdateBy(user.getId());
        chartType.setUpdateTime(new Date());
        if (Boolean.TRUE.equals(existing.getBuiltin())) {
            chartType.setCode(existing.getCode());
            chartType.setBuiltin(true);
        }
        chartTypeMapper.update(chartType);
        return chartTypeMapper.getById(chartType.getId());
    }

    @Override
    @Transactional
    public boolean delete(Long id, User user) throws ServerException {
        ChartType existing = chartTypeMapper.getById(id);
        if (existing == null) {
            throw new ServerException("Chart type not found");
        }
        if (Boolean.TRUE.equals(existing.getBuiltin())) {
            throw new ServerException("Builtin chart type cannot be deleted");
        }
        return chartTypeMapper.deleteNonBuiltinById(id) > 0;
    }

    private void validate(ChartType chartType, boolean isCreate) throws ServerException {
        if (isCreate && StringUtils.isEmpty(chartType.getCode())) {
            throw new ServerException("Chart type code is required");
        }
        if (StringUtils.isEmpty(chartType.getName())) {
            throw new ServerException("Chart type name is required");
        }
        if (StringUtils.isEmpty(chartType.getTitle())) {
            throw new ServerException("Chart type title is required");
        }
        validateJsonField(chartType.getConfigSchema(), "configSchema");
        validateJsonField(chartType.getDataSchema(), "dataSchema");
        if (!StringUtils.isEmpty(chartType.getOptionTemplate())) {
            validateJsonField(chartType.getOptionTemplate(), "optionTemplate");
        }
        if ("mes".equals(chartType.getCategory())
                && StringUtils.isEmpty(chartType.getOptionTemplate())
                && !"mes-wip-table".equals(chartType.getCode())) {
            throw new ServerException("MES chart type requires optionTemplate");
        }
    }

    private void validateJsonField(String json, String fieldName) throws ServerException {
        if (StringUtils.isEmpty(json)) {
            return;
        }
        String trimmed = json.trim();
        if (!trimmed.startsWith("{") && !trimmed.startsWith("[")) {
            throw new ServerException(fieldName + " must be valid JSON");
        }
        try {
            com.alibaba.fastjson.JSON.parse(trimmed);
        } catch (Exception e) {
            throw new ServerException(fieldName + " must be valid JSON: " + e.getMessage());
        }
    }
}
