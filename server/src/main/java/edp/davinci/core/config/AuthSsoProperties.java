package edp.davinci.core.config;

import lombok.Data;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.stereotype.Component;

@Data
@Component
@ConfigurationProperties(prefix = "auth.sso")
public class AuthSsoProperties {

    /**
     * eos-ticket | mes-jwt | both
     */
    private String mode = "both";
}
