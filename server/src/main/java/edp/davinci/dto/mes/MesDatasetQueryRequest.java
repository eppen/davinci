package edp.davinci.dto.mes;

import lombok.Data;

import java.util.HashMap;
import java.util.Map;

@Data
public class MesDatasetQueryRequest {

    private Map<String, Object> params = new HashMap<>();
    private MesDatasetPagination pagination = new MesDatasetPagination();
}
