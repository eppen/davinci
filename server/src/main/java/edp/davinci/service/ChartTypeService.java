package edp.davinci.service;

import edp.core.exception.ServerException;
import edp.davinci.model.ChartType;
import edp.davinci.model.User;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

public interface ChartTypeService {

    List<ChartType> list(Boolean enabled);

    ChartType getByCode(String code) throws ServerException;

    ChartType create(ChartType chartType, User user) throws ServerException;

    ChartType update(ChartType chartType, User user) throws ServerException;

    boolean delete(Long id, User user) throws ServerException;
}
