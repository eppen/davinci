package edp.davinci.service.eos;

import edp.core.exception.ServerException;
import edp.davinci.core.config.EosIntegrationProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureException;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.StringUtils;

@Component
public class SsoTicketService {

    private static final String CLAIM_APP = "app";
    private static final String CLAIM_GOTO = "goto";
    private static final String CLAIM_USERNAME = "username";

    @Autowired
    private EosIntegrationProperties properties;

    public TicketClaims parseAndValidate(String ticket) throws ServerException {
        if (!properties.isEnabled()) {
            throw new ServerException("EOS SSO integration is disabled");
        }
        if (!StringUtils.hasText(properties.getTicketSecret())) {
            throw new ServerException("EOS SSO ticket secret is not configured");
        }
        if (!StringUtils.hasText(ticket)) {
            throw new ServerException("SSO ticket is required");
        }
        try {
            Claims claims = Jwts.parser()
                    .setSigningKey(properties.getTicketSecret())
                    .parseClaimsJws(ticket.trim())
                    .getBody();
            TicketClaims tc = new TicketClaims();
            tc.setUsername(claims.get(CLAIM_USERNAME, String.class));
            tc.setApp(claims.get(CLAIM_APP, String.class));
            tc.setGotoPath(claims.get(CLAIM_GOTO, String.class));
            if (!StringUtils.hasText(tc.getUsername())) {
                throw new ServerException("Invalid SSO ticket: missing username");
            }
            if (!properties.isAppAllowed(tc.getApp())) {
                throw new ServerException("Invalid SSO ticket: application not allowed");
            }
            return tc;
        } catch (ExpiredJwtException e) {
            throw new ServerException("SSO ticket expired");
        } catch (SignatureException e) {
            throw new ServerException("Invalid SSO ticket");
        } catch (ServerException e) {
            throw e;
        } catch (Exception e) {
            throw new ServerException("Invalid SSO ticket");
        }
    }

    @Data
    public static class TicketClaims {
        private String username;
        private String app;
        private String gotoPath;
    }
}
