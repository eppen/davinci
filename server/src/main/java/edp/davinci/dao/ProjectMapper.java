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

import edp.davinci.dto.organizationDto.OrganizationInfo;
import edp.davinci.dto.projectDto.ProjectDetail;
import edp.davinci.dto.projectDto.ProjectWithCreateBy;
import edp.davinci.model.Project;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;
import org.springframework.stereotype.Component;

import java.util.List;
import java.util.Set;

/**
 * MyBatis mapper. XML: server/src/main/resources/mybatis/mapper/ProjectMapper.xml
 * XML statements: insert, deleteBeforeOrgRole, getProjectsByKeywordsWithUser, getProjectsByOrgWithUser, getProjectsByUser, getFavoriteProjects, getProjectIdsByAdmin, getProjectDetail.
 */
@Component
public interface ProjectMapper {

    List<ProjectWithCreateBy> getProjectsByUser(@Param("userId") Long userId);

    List<ProjectWithCreateBy> getFavoriteProjects(@Param("userId") Long userId);

    List<ProjectWithCreateBy> getProjectsByOrgWithUser(@Param("orgId") Long orgId, @Param("userId") Long userId, @Param("keyword") String keyword);

    List<ProjectWithCreateBy> getProjectsByKeywordsWithUser(@Param("keywords") String keywords, @Param("userId") Long userId, @Param("orgList") List<OrganizationInfo> list);

    @Select(value = {"select id from project where org_id = #{orgId} and `name` = #{name}"}, databaseId = "mysql")

    @Select(value = {"select id from project where org_id = #{orgId} and [name] = #{name}"}, databaseId = "sqlserver")

    Long getByNameWithOrgId(@Param("name") String name, @Param("orgId") Long orgId);

    int insert(Project project);

    @Select({"select * from project where id = #{id}"})


    Project getById(@Param("id") Long id);

    ProjectDetail getProjectDetail(@Param("id") Long id);

    @Select({"select * from project where id = #{id} and user_id = #{userId}"})


    Project getByProject(Project project);

    @Update(value = {"update project set `name` = #{name}, description = #{description}, visibility = #{visibility}, update_time = #{updateTime}, update_by = #{updateBy}  where id = #{id}"}, databaseId = "mysql")

    @Update(value = {"update project set [name] = #{name}, description = #{description}, visibility = #{visibility}, update_time = #{updateTime}, update_by = #{updateBy}  where id = #{id}"}, databaseId = "sqlserver")

    int updateBaseInfo(Project project);

    @Update(value = {"update project set `org_id` = #{orgId} where id = #{id}"}, databaseId = "mysql")

    @Update(value = {"update project set [org_id] = #{orgId} where id = #{id}"}, databaseId = "sqlserver")

    int changeOrganization(Project project);

    @Update(value = {"update project set `is_transfer` = #{isTransfer, jdbcType=TINYINT} where id = #{id}"}, databaseId = "mysql")

    @Update(value = {"update project set [is_transfer] = #{isTransfer, jdbcType=TINYINT} where id = #{id}"}, databaseId = "sqlserver")

    int changeTransferStatus(@Param("isTransfer") Boolean isTransfer, @Param("id") Long id);

    @Delete({"delete from project where id = #{id}"})


    int deleteById(@Param("id") Long id);

    @Select({"select * from project where org_id = #{orgId}"})


    List<Project> getByOrgId(@Param("orgId") Long orgId);

    @Update({"update project set star_num = star_num + 1 where id = #{id}"})


    int starNumAdd(@Param("id") Long id);

    @Update({"update project set star_num = IF(star_num > 0,star_num - 1, 0) where id = #{id}"})


    int starNumReduce(@Param("id") Long id);

    Set<Long> getProjectIdsByAdmin(@Param("userId") Long userId);

    int deleteBeforeOrgRole(@Param("projectId") Long projectId, @Param("orgId") Long orgId);
}