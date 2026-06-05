package edp.davinci.core.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "mes.integration")
public class MesIntegrationProperties {

    private boolean jwtEnabled = false;
    private String publicKey = "";
    private String jwksUrl = "";
    private String usernameClaim = "username";
    private int datasetCacheSeconds = 45;
    private String mockBaseUrl = "http://127.0.0.1:9090";
}
