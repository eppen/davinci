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

import edp.davinci.dto.sourceDto.SourceWithProject;
import edp.davinci.model.Source;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Component;

import java.util.List;

/**
 * MyBatis mapper. XML: server/src/main/resources/mybatis/mapper/SourceMapper.xml
 * XML statements: insert, insertBatch.
 */
@Component
public interface SourceMapper {

    int insert(Source source);

    @Delete(value = {"delete from `source` where id = #{id}"}, databaseId = "mysql")

    @Delete(value = {"delete from [source] where id = #{id}"}, databaseId = "sqlserver")

    int deleteById(@Param("id") Long id);

    @Select(value = {"select * from `source` where id = #{id}"}, databaseId = "mysql")

    @Select(value = {"select * from [source] where id = #{id}"}, databaseId = "sqlserver")

    Source getById(@Param("id") Long id);

    @Update(value = {
            "update `source`",
            "set `name` = #{name,jdbcType=VARCHAR},",
            "`description` = #{description,jdbcType=VARCHAR},",
            "`type` = #{type,jdbcType=VARCHAR},",
            "`project_id` = #{projectId,jdbcType=BIGINT},",
            "`config` = #{config,jdbcType=LONGVARCHAR},",
            "`update_by` = #{updateBy,jdbcType=BIGINT},",
            "`update_time` = #{updateTime,jdbcType=TIMESTAMP}",
            "where id = #{id,jdbcType=BIGINT}"
    }, databaseId = "mysql")

    @Update(value = {"update [source]", "set [name] = #{name,jdbcType=VARCHAR},", "[description] = #{description,jdbcType=VARCHAR},", "[type] = #{type,jdbcType=VARCHAR},", "[project_id] = #{projectId,jdbcType=BIGINT},", "[config] = #{config,jdbcType=LONGVARCHAR},", "[update_by] = #{updateBy,jdbcType=BIGINT},", "[update_time] = #{updateTime,jdbcType=TIMESTAMP}", "where id = #{id,jdbcType=BIGINT}"}, databaseId = "sqlserver")

    int update(Source source);

    @Select(value = {"select id from `source` where project_id = #{projectId} and name = #{name}"}, databaseId = "mysql")

    @Select(value = {"select id from [source] where project_id = #{projectId} and name = #{name}"}, databaseId = "sqlserver")

    Long getByNameWithProjectId(@Param("name") String name, @Param("projectId") Long projectId);

    @Select(value = {"select * from `source` where project_id = #{projectId}"}, databaseId = "mysql")

    @Select(value = {"select * from [source] where project_id = #{projectId}"}, databaseId = "sqlserver")

    List<Source> getByProject(@Param("projectId") Long projectId);

    @Select(value = {
            "SELECT s.id, s.`name`, s.`type`, s.`config`,",
            "	p.id 'project.id',",
            "	p.`name` 'project.name',",
            "	p.`description` 'project.description',",
            "	p.`pic` 'project.pic',",
            "	p.`user_id` 'project.userId',",
            "	p.`org_id` 'project.orgId',",
            "	p.`visibility` 'p.visibility'",
            "FROM source s INNER JOIN project p on p.id = s.project_id",
            "where s.id = #{sourceId}"
    }, databaseId = "mysql")

    @Select(value = {"SELECT s.id, s.[name], s.[type], s.[config],", "	p.id 'project.id',", "	p.[name] 'project.name',", "	p.[description] 'project.description',", "	p.[pic] 'project.pic',", "	p.[user_id] 'project.userId',", "	p.[org_id] 'project.orgId',", "	p.[visibility] 'p.visibility'", "FROM source s INNER JOIN project p on p.id = s.project_id", "where s.id = #{sourceId}"}, databaseId = "sqlserver")

    SourceWithProject getSourceWithProjectById(@Param("sourceId") Long sourceId);

    int insertBatch(@Param("list") List<Source> sourceList);

    @Delete(value = {"delete from `source` where project_id = #{projectId}"}, databaseId = "mysql")

    @Delete(value = {"delete from [source] where project_id = #{projectId}"}, databaseId = "sqlserver")

    int deleteByProject(@Param("projectId") Long projectId);
}