package edp.davinci.controller;

import edp.core.annotation.AuthIgnore;
import edp.core.annotation.CurrentUser;
import edp.core.enums.HttpCodeEnum;
import edp.core.exception.ServerException;
import edp.davinci.common.controller.BaseController;
import edp.davinci.core.common.Constants;
import edp.davinci.core.common.ResultMap;
import edp.davinci.model.ChartType;
import edp.davinci.model.User;
import edp.davinci.service.ChartTypeService;
import io.swagger.annotations.Api;
import io.swagger.annotations.ApiOperation;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import springfox.documentation.annotations.ApiIgnore;

import javax.servlet.http.HttpServletRequest;

@Api(value = "/chart-types", tags = "chart-types", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
@Slf4j
@RestController
@RequestMapping(value = Constants.BASE_API_PATH + "/chart-types", produces = MediaType.APPLICATION_JSON_UTF8_VALUE)
public class ChartTypeController extends BaseController {

    @Autowired
    private ChartTypeService chartTypeService;

    @AuthIgnore
    @ApiOperation(value = "list chart types")
    @GetMapping
    public ResponseEntity list(@RequestParam(value = "enabled", required = false) Boolean enabled,
                               @ApiIgnore HttpServletRequest request) {
        try {
            ResultMap resultMap = new ResultMap(tokenUtils).successAndRefreshToken(request)
                    .payloads(chartTypeService.list(enabled));
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (Exception e) {
            log.error(e.toString(), e);
            return ResponseEntity.status(HttpCodeEnum.SERVER_ERROR.getCode()).body(HttpCodeEnum.SERVER_ERROR.getMessage());
        }
    }

    @AuthIgnore
    @ApiOperation(value = "get chart type by code")
    @GetMapping("/{code}")
    public ResponseEntity getByCode(@PathVariable String code,
                                    @ApiIgnore HttpServletRequest request) {
        try {
            ResultMap resultMap = new ResultMap(tokenUtils).successAndRefreshToken(request)
                    .payload(chartTypeService.getByCode(code));
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (ServerException e) {
            ResultMap resultMap = new ResultMap(tokenUtils).failAndRefreshToken(request).message(e.getMessage());
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (Exception e) {
            log.error(e.toString(), e);
            return ResponseEntity.status(HttpCodeEnum.SERVER_ERROR.getCode()).body(HttpCodeEnum.SERVER_ERROR.getMessage());
        }
    }

    @ApiOperation(value = "create chart type")
    @PostMapping(consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity create(@RequestBody ChartType chartType,
                                 @ApiIgnore @CurrentUser User user,
                                 @ApiIgnore HttpServletRequest request) {
        try {
            ResultMap resultMap = new ResultMap(tokenUtils).successAndRefreshToken(request)
                    .payload(chartTypeService.create(chartType, user));
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (ServerException e) {
            ResultMap resultMap = new ResultMap(tokenUtils).failAndRefreshToken(request).message(e.getMessage());
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (Exception e) {
            log.error(e.toString(), e);
            return ResponseEntity.status(HttpCodeEnum.SERVER_ERROR.getCode()).body(HttpCodeEnum.SERVER_ERROR.getMessage());
        }
    }

    @ApiOperation(value = "update chart type")
    @PutMapping(value = "/{id}", consumes = MediaType.APPLICATION_JSON_VALUE)
    public ResponseEntity update(@PathVariable Long id,
                                 @RequestBody ChartType chartType,
                                 @ApiIgnore @CurrentUser User user,
                                 @ApiIgnore HttpServletRequest request) {
        if (invalidId(id)) {
            ResultMap resultMap = new ResultMap(tokenUtils).failAndRefreshToken(request).message("Invalid chart type id");
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        }
        chartType.setId(id);
        try {
            ResultMap resultMap = new ResultMap(tokenUtils).successAndRefreshToken(request)
                    .payload(chartTypeService.update(chartType, user));
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (ServerException e) {
            ResultMap resultMap = new ResultMap(tokenUtils).failAndRefreshToken(request).message(e.getMessage());
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (Exception e) {
            log.error(e.toString(), e);
            return ResponseEntity.status(HttpCodeEnum.SERVER_ERROR.getCode()).body(HttpCodeEnum.SERVER_ERROR.getMessage());
        }
    }

    @ApiOperation(value = "delete chart type")
    @DeleteMapping("/{id}")
    public ResponseEntity delete(@PathVariable Long id,
                                 @ApiIgnore @CurrentUser User user,
                                 @ApiIgnore HttpServletRequest request) {
        if (invalidId(id)) {
            ResultMap resultMap = new ResultMap(tokenUtils).failAndRefreshToken(request).message("Invalid chart type id");
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        }
        try {
            chartTypeService.delete(id, user);
            ResultMap resultMap = new ResultMap(tokenUtils).successAndRefreshToken(request);
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (ServerException e) {
            ResultMap resultMap = new ResultMap(tokenUtils).failAndRefreshToken(request).message(e.getMessage());
            return ResponseEntity.status(resultMap.getCode()).body(resultMap);
        } catch (Exception e) {
            log.error(e.toString(), e);
            return ResponseEntity.status(HttpCodeEnum.SERVER_ERROR.getCode()).body(HttpCodeEnum.SERVER_ERROR.getMessage());
        }
    }
}
