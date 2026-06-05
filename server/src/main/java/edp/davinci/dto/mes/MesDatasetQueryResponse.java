package edp.davinci.dto.mes;

import lombok.Data;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Data
public class MesDatasetQueryResponse {

    private List<MesDatasetColumn> columns = new ArrayList<>();
    private List<Map<String, Object>> rows = new ArrayList<>();
    private MesDatasetMeta meta = new MesDatasetMeta();
}
