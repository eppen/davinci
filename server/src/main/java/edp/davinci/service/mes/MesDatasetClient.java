package edp.davinci.service.mes;

import com.alibaba.druid.util.StringUtils;
import com.alibaba.fastjson.JSONObject;
import edp.core.exception.ServerException;
import edp.davinci.dto.mes.MesDatasetQueryRequest;
import edp.davinci.dto.mes.MesDatasetQueryResponse;
import edp.davinci.model.Source;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Slf4j
@Component
public class MesDatasetClient {

    @Autowired
    private RestTemplate restTemplate;

    public MesDatasetQueryResponse query(Source source, String datasetCode, MesDatasetQueryRequest request, String forwardToken)
            throws ServerException {
        JSONObject config = parseConfig(source);
        String baseUrl = config.getString("url");
        if (StringUtils.isEmpty(baseUrl)) {
            baseUrl = config.getString("baseUrl");
        }
        if (StringUtils.isEmpty(baseUrl)) {
            throw new ServerException("MES API baseUrl is not configured");
        }
        if (StringUtils.isEmpty(datasetCode)) {
            datasetCode = config.getString("datasetCode");
        }
        if (StringUtils.isEmpty(datasetCode)) {
            throw new ServerException("MES datasetCode is required");
        }
        String url = trimTrailingSlash(baseUrl) + "/api/mes/dataset/" + datasetCode + "/query";
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        String authType = config.getString("authType");
        if ("forward-mes-token".equalsIgnoreCase(authType) && !StringUtils.isEmpty(forwardToken)) {
            headers.set(HttpHeaders.AUTHORIZATION, forwardToken.startsWith("Bearer ") ? forwardToken : "Bearer " + forwardToken);
        } else if (!StringUtils.isEmpty(config.getString("bearerToken"))) {
            String token = config.getString("bearerToken");
            headers.set(HttpHeaders.AUTHORIZATION, token.startsWith("Bearer ") ? token : "Bearer " + token);
        }
        int timeoutMs = config.getIntValue("timeoutMs");
        if (timeoutMs <= 0) {
            timeoutMs = 30000;
        }
        try {
            HttpEntity<MesDatasetQueryRequest> entity = new HttpEntity<>(request, headers);
            ResponseEntity<String> response = restTemplate.exchange(url, HttpMethod.POST, entity, String.class);
            if (!response.getStatusCode().is2xxSuccessful() || response.getBody() == null) {
                throw new ServerException("MES dataset query failed: HTTP " + response.getStatusCodeValue());
            }
            return JSONObject.parseObject(response.getBody(), MesDatasetQueryResponse.class);
        } catch (ServerException e) {
            throw e;
        } catch (Exception e) {
            log.error("MES dataset query error: {}", e.getMessage(), e);
            throw new ServerException("MES dataset query failed: " + e.getMessage());
        }
    }

    public boolean testConnection(JSONObject config) {
        try {
            String baseUrl = config.getString("url");
            if (StringUtils.isEmpty(baseUrl)) {
                baseUrl = config.getString("baseUrl");
            }
            if (StringUtils.isEmpty(baseUrl)) {
                return false;
            }
            String datasetCode = config.getString("datasetCode");
            if (StringUtils.isEmpty(datasetCode)) {
                datasetCode = "output_shift";
            }
            Source source = new Source();
            source.setConfig(config.toJSONString());
            MesDatasetQueryRequest req = new MesDatasetQueryRequest();
            req.getParams().put("plant", "P01");
            query(source, datasetCode, req, null);
            return true;
        } catch (Exception e) {
            log.warn("MES API test connection failed: {}", e.getMessage());
            return false;
        }
    }

    public static JSONObject parseConfig(Source source) throws ServerException {
        if (source == null || StringUtils.isEmpty(source.getConfig())) {
            throw new ServerException("MES API source config is empty");
        }
        try {
            return JSONObject.parseObject(source.getConfig());
        } catch (Exception e) {
            throw new ServerException("Invalid MES API source config");
        }
    }

    private String trimTrailingSlash(String baseUrl) {
        if (baseUrl.endsWith("/")) {
            return baseUrl.substring(0, baseUrl.length() - 1);
        }
        return baseUrl;
    }
}
