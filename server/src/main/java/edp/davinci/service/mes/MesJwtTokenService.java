package edp.davinci.service.mes;

import com.alibaba.druid.util.StringUtils;
import com.alibaba.fastjson.JSONObject;
import edp.core.exception.ServerException;
import edp.davinci.core.config.MesIntegrationProperties;
import io.jsonwebtoken.Claims;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.Jwts;
import io.jsonwebtoken.SignatureException;
import lombok.Data;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.security.KeyFactory;
import java.security.PublicKey;
import java.security.spec.X509EncodedKeySpec;
import java.util.Base64;

@Component
public class MesJwtTokenService {

    @Autowired
    private MesIntegrationProperties properties;

    public MesTokenClaims parseAndValidate(String token) throws ServerException {
        if (!properties.isJwtEnabled()) {
            throw new ServerException("MES JWT integration is disabled");
        }
        if (StringUtils.isEmpty(token)) {
            throw new ServerException("MES token is required");
        }
        String trimmed = token.trim();
        if (trimmed.startsWith("Bearer ")) {
            trimmed = trimmed.substring(7).trim();
        }
        try {
            String username;
            if (!StringUtils.isEmpty(properties.getPublicKey())) {
                PublicKey publicKey = loadPublicKey(properties.getPublicKey());
                Claims claims = Jwts.parser().setSigningKey(publicKey).parseClaimsJws(trimmed).getBody();
                username = resolveUsername(claims);
            } else {
                username = resolveUsernameFromPayload(trimmed);
            }
            MesTokenClaims tc = new MesTokenClaims();
            tc.setUsername(username);
            if (StringUtils.isEmpty(tc.getUsername())) {
                throw new ServerException("Invalid MES token: missing username");
            }
            return tc;
        } catch (ExpiredJwtException e) {
            throw new ServerException("MES token expired");
        } catch (SignatureException e) {
            throw new ServerException("Invalid MES token signature");
        } catch (ServerException e) {
            throw e;
        } catch (Exception e) {
            throw new ServerException("Invalid MES token");
        }
    }

    private String resolveUsername(Claims claims) {
        String usernameClaim = properties.getUsernameClaim();
        String username = claims.get(usernameClaim, String.class);
        if (StringUtils.isEmpty(username)) {
            username = claims.getSubject();
        }
        if (StringUtils.isEmpty(username)) {
            username = claims.get("sub", String.class);
        }
        return username;
    }

    private String resolveUsernameFromPayload(String token) throws ServerException {
        String[] parts = token.split("\\.");
        if (parts.length < 2) {
            throw new ServerException("Invalid MES token format");
        }
        String payloadJson = new String(Base64.getUrlDecoder().decode(parts[1]));
        JSONObject payload = JSONObject.parseObject(payloadJson);
        String usernameClaim = properties.getUsernameClaim();
        String username = payload.getString(usernameClaim);
        if (StringUtils.isEmpty(username)) {
            username = payload.getString("sub");
        }
        return username;
    }

    private PublicKey loadPublicKey(String pem) throws Exception {
        String normalized = pem
                .replace("-----BEGIN PUBLIC KEY-----", "")
                .replace("-----END PUBLIC KEY-----", "")
                .replaceAll("\\s", "");
        byte[] decoded = Base64.getDecoder().decode(normalized);
        X509EncodedKeySpec spec = new X509EncodedKeySpec(decoded);
        return KeyFactory.getInstance("RSA").generatePublic(spec);
    }

    @Data
    public static class MesTokenClaims {
        private String username;
    }
}
