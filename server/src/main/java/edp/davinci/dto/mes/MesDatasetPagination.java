package edp.davinci.dto.mes;

import lombok.Data;

@Data
public class MesDatasetPagination {

    private Integer pageNo = 1;
    private Integer pageSize = 500;
}
