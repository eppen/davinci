/*
 * <<
 *  Davinci
 *  ==
 *  Copyright (C) 2016 - 2019 EDP
 *  ==
 *  Licensed under the Apache License, Version 2.0 (the "License");
 *  you may not use this file except in compliance with the License.
 *  You may obtain a copy of the License at
 *        http://www.apache.org/licenses/LICENSE-2.0
 *   Unless required by applicable law or agreed to in writing, software
 *   distributed under the License is distributed on an "AS IS" BASIS,
 *   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 *   See the License for the specific language governing permissions and
 *   limitations under the License.
 *  >>
 *
 */

package edp.davinci.dao;

import edp.davinci.dto.viewDto.*;
import edp.davinci.model.View;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;

/**
 * MyBatis mapper. XML: server/src/main/resources/mybatis/mapper/ViewMapper.xml
 * XML statements: insert, insertBatch, selectByWidgetIds, selectSimpleByWidgetIds, getViewWithProjectAndSourceByWidgetId, getViewWithProjectAndSourceById.
 */
@Component
public interface ViewMapper {

    int insert(View view);

    @Select(value = {"select id from `view` where project_id = #{projectId} and `name` = #{name}"}, databaseId = "mysql")

    @Select(value = {"select id from [view] where project_id = #{projectId} and [name] = #{name}"}, databaseId = "sqlserver")

    Long getByNameWithProjectId(@Param("name") String name, @Param("projectId") Long projectId);

    ViewWithProjectAndSource getViewWithProjectAndSourceById(@Param("id") Long id);

    ViewWithProjectAndSource getViewWithProjectAndSourceByWidgetId(@Param("widgetId") Long widgetId);

    @Delete(value = {"delete from `view` where id = #{id}"}, databaseId = "mysql")

    @Delete(value = {"delete from [view] where id = #{id}"}, databaseId = "sqlserver")

    int deleteById(Long id);

    @Select(value = {"select * from `view` where id = #{id}"}, databaseId = "mysql")

    @Select(value = {"select * from [view] where id = #{id}"}, databaseId = "sqlserver")

    View getById(Long id);

    @Select(value = {"select id, name, model, variable from `view` where id = #{id}"}, databaseId = "mysql")

    @Select(value = {"select id, name, model, variable from [view] where id = #{id}"}, databaseId = "sqlserver")

    SimpleView getSimpleViewById(Long id);

    @Update(value = {
            "update `view`",
            "set `name` = #{name,jdbcType=VARCHAR},",
            "`description` = #{description,jdbcType=VARCHAR},",
            "`project_id` = #{projectId,jdbcType=BIGINT},",
            "`source_id` = #{sourceId,jdbcType=BIGINT},",
            "`sql` = #{sql,jdbcType=LONGVARCHAR},",
            "`model` = #{model,jdbcType=LONGVARCHAR},",
            "`variable` = #{variable,jdbcType=LONGVARCHAR},",
            "`config` = #{config,jdbcType=LONGVARCHAR},",
            "`update_by` = #{updateBy,jdbcType=BIGINT},",
            "`update_time` = #{updateTime,jdbcType=TIMESTAMP}",
            "where id = #{id,jdbcType=BIGINT}"
    }, databaseId = "mysql")

    @Update(value = {"update [view]", "set [name] = #{name,jdbcType=VARCHAR},", "[description] = #{description,jdbcType=VARCHAR},", "[project_id] = #{projectId,jdbcType=BIGINT},", "[source_id] = #{sourceId,jdbcType=BIGINT},", "[sql] = #{sql,jdbcType=LONGVARCHAR},", "[model] = #{model,jdbcType=LONGVARCHAR},", "[variable] = #{variable,jdbcType=LONGVARCHAR},", "[config] = #{config,jdbcType=LONGVARCHAR},", "[update_by] = #{updateBy,jdbcType=BIGINT},", "[update_time] = #{updateTime,jdbcType=TIMESTAMP}", "where id = #{id,jdbcType=BIGINT}"}, databaseId = "sqlserver")

    int update(View view);

    @Select(value = {"select * from `view` where source_id = #{sourceId}"}, databaseId = "mysql")

    @Select(value = {"select * from [view] where source_id = #{sourceId}"}, databaseId = "sqlserver")

    List<View> getBySourceId(@Param("sourceId") Long sourceId);

    @Select(value = {
            "select v.*,",
            "s.id as 'source.id', s.`name` as 'source.name' from `view` v ",
            "left join source s on s.id = v.source_id ",
            "where v.id = #{id}"
    }, databaseId = "mysql")

    @Select(value = {"select v.*,", "s.id as 'source.id', s.[name] as 'source.name' from [view] v ", "left join source s on s.id = v.source_id ", "where v.id = #{id}"}, databaseId = "sqlserver")

    ViewWithSourceBaseInfo getViewWithSourceBaseInfo(@Param("id") Long id);

    @Select(value = {
            "select v.id, v.`name`, v.`description`, s.name as 'sourceName'",
            "from `view` v ",
            "left join source s on s.id = v.source_id ",
            "where v.project_id = #{projectId}"
    }, databaseId = "mysql")

    @Select(value = {"select v.id, v.[name], v.[description], s.name as 'sourceName'", "from [view] v ", "left join source s on s.id = v.source_id ", "where v.project_id = #{projectId}"}, databaseId = "sqlserver")

    List<ViewBaseInfo> getViewBaseInfoByProject(@Param("projectId") Long projectId);

    int insertBatch(@Param("list") List<View> sourceList);

    @Delete(value = {"delete from `view` where project_id = #{projectId}"}, databaseId = "mysql")

    @Delete(value = {"delete from [view] where project_id = #{projectId}"}, databaseId = "sqlserver")

    int deleteByProject(@Param("projectId") Long projectId);

    @Select(value = {
            "SELECT ",
            "	v.*,",
            "	s.`id` 'source.id',",
            "	s.`name` 'source.name',",
            "	s.`description` 'source.description',",
            "	s.`config` 'source.config',",
            "	s.`project_id` 'source.projectId',",
            "	s.`type` 'source.type'",
            "FROM `view` v",
            "	LEFT JOIN project p on p.id = v.project_id",
            "	LEFT JOIN source s on s.id = v.source_id",
            "WHERE v.id = #{id}"
    }, databaseId = "mysql")

    @Select(value = {"SELECT ", "	v.*,", "	s.[id] 'source.id',", "	s.[name] 'source.name',", "	s.[description] 'source.description',", "	s.[config] 'source.config',", "	s.[project_id] 'source.projectId',", "	s.[type] 'source.type'", "FROM [view] v", "	LEFT JOIN project p on p.id = v.project_id", "	LEFT JOIN source s on s.id = v.source_id", "WHERE v.id = #{id}"}, databaseId = "sqlserver")

    ViewWithSource getViewWithSource(Long id);

    Set<View> selectByWidgetIds(@Param("widgetIds") Set<Long> widgetIds);

    Set<SimpleView> selectSimpleByWidgetIds(@Param("widgetIds") Set<Long> widgetIds);
}