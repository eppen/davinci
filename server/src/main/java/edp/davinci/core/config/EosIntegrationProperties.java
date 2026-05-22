package edp.davinci.core.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;

@Data
@Component
@ConfigurationProperties(prefix = "eos.integration")
public class EosIntegrationProperties {

    private boolean enabled = false;
    private String ticketSecret = "";
    private String appCode = "davinci";
    private List<String> allowedApps = new ArrayList<>();

    public boolean isAppAllowed(String app) {
        if (allowedApps == null || allowedApps.isEmpty()) {
            return appCode.equals(app);
        }
        return allowedApps.contains(app);
    }
}
