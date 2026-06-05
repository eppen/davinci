package edp.davinci.dto.mes;

import lombok.Data;

@Data
public class MesDatasetMeta {

    private Integer totalCount;
    private Boolean cached;
    private Long queryTimeMs;
}
