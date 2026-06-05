package edp.davinci.dao;

import edp.davinci.model.ChartType;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Component;

import java.util.List;

@Component
public interface ChartTypeMapper {

    int insert(ChartType chartType);

    @Select("select count(1) from chart_type")
    int count();

    @Select("select * from chart_type where id = #{id}")
    ChartType getById(@Param("id") Long id);

    @Select("select * from chart_type where code = #{code}")
    ChartType getByCode(@Param("code") String code);

    @Select({
            "<script>",
            "select * from chart_type",
            "<where>",
            "<if test='enabled != null'> and enabled = #{enabled}</if>",
            "</where>",
            "order by builtin desc, id asc",
            "</script>"
    })
    List<ChartType> list(@Param("enabled") Boolean enabled);

    @Update(value = {
            "update chart_type set",
            "`code` = #{code}, `name` = #{name}, `title` = #{title}, `category` = #{category},",
            "`icon` = #{icon}, `renderer` = #{renderer}, `config_schema` = #{configSchema},",
            "`data_schema` = #{dataSchema}, `option_template` = #{optionTemplate},",
            "`version` = #{version}, `enabled` = #{enabled}, `description` = #{description},",
            "`update_by` = #{updateBy}, `update_time` = #{updateTime}",
            "where id = #{id}"
    }, databaseId = "mysql")
    @Update(value = {
            "update chart_type set",
            "[code] = #{code}, [name] = #{name}, [title] = #{title}, [category] = #{category},",
            "[icon] = #{icon}, [renderer] = #{renderer}, [config_schema] = #{configSchema},",
            "[data_schema] = #{dataSchema}, [option_template] = #{optionTemplate},",
            "[version] = #{version}, [enabled] = #{enabled}, [description] = #{description},",
            "[update_by] = #{updateBy}, [update_time] = #{updateTime}",
            "where id = #{id}"
    }, databaseId = "sqlserver")
    int update(ChartType chartType);

    @Delete("delete from chart_type where id = #{id} and builtin = 0")
    int deleteNonBuiltinById(@Param("id") Long id);
}
