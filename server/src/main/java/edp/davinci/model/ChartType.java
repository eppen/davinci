package edp.davinci.model;

import edp.core.model.RecordInfo;
import lombok.Data;
import lombok.EqualsAndHashCode;

@Data
@EqualsAndHashCode(callSuper = true)
public class ChartType extends RecordInfo<ChartType> {

    private Long id;
    private String code;
    private String name;
    private String title;
    private String category;
    private String icon;
    private String renderer;
    private String configSchema;
    private String dataSchema;
    private String optionTemplate;
    private Integer version;
    private Boolean builtin;
    private Boolean enabled;
    private String description;
}
