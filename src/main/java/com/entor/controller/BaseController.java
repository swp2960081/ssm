package com.entor.controller;

import java.io.PrintWriter;
import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.List;
import java.util.Map;

import javax.annotation.Resource;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.propertyeditors.CustomDateEditor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.ServletRequestDataBinder;
import org.springframework.web.bind.annotation.InitBinder;
import org.springframework.web.bind.annotation.ModelAttribute;
import org.springframework.web.bind.annotation.RequestMapping;

import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONObject;
import com.entor.service.BaseService;
import com.entor.util.Pager;

@Controller
@RequestMapping("/base")
public class BaseController<T> {

	@Resource
	private BaseService<T> baseService;
	private HttpServletRequest request;
	private HttpServletResponse response;
	
	@RequestMapping("/queryByPage")
	public void queryByPage(T t,String page,String rows,Map<String, Object> map) throws Exception {
		
		PrintWriter out = response.getWriter();
		/*
		String qusername = request.getParameter("qusername");
		
		String condition = " where 1=1 ";
		if(!"".equals(qusername)&&qusername!=null){
			condition += " and username like '%"+qusername+"%' ";
		}
		
		
		UserDao dao = new UserDaoImpl();
		int totals = dao.getTotals(condition);
		Pager<User> pager = new Pager<>(totals,page,rows);
		List<User> list = dao.queryByPage(pager.getSp(), pager.getPageSize(), condition);

		map.put("qusername", qusername);
		*/
		int totals = baseService.getTotals(t.getClass());
		Pager<T> pager = new Pager<T>(totals,page,rows);
		List<T> list = baseService.queryByPage(t.getClass(), pager.getSp(), pager.getPageSize());
		JSONObject jo = new JSONObject();
		jo.put("total", totals);
		jo.put("rows", list);
		
		String json = JSON.toJSONString(jo);
		out.write(json);
		out.flush();
		out.close();
	}
	
	@RequestMapping("/update")
	public void update(T t) throws Exception {
		
		PrintWriter out = response.getWriter();
		JSONObject jo = new JSONObject();
		try {
			baseService.update(t);
			jo.put("state", 0);
			jo.put("msg", "修改成功");
		} catch (Exception e) {
			jo.put("state", -1);
			jo.put("msg", "修改失败："+ e.getMessage());
		} finally {
			out.write(JSON.toJSONString(jo));
			out.flush();
			out.close();
		}
	}
	
	@RequestMapping("/deleteMore")
	public void deleteMore(T t, String ids) throws Exception {
		
		PrintWriter out = response.getWriter();
		JSONObject jo = new JSONObject();
		try {
			baseService.deleteMore(t.getClass(), ids);
			jo.put("state", 0);
			jo.put("msg", "你成功删除了编号："+ids);
		} catch (Exception e) {
			jo.put("state", -1);
			jo.put("msg", "删除失败："+ e.getMessage());
		} finally {
			out.write(JSON.toJSONString(jo));
			out.flush();
			out.close();
		}
	}
	
	@RequestMapping("/add")
	public void add(T t) throws Exception {
		
		PrintWriter out = response.getWriter();
		JSONObject jo = new JSONObject();
		try {
			baseService.add(t);
			jo.put("state", 0);
			jo.put("msg", "新增成功！");
		} catch (Exception e) {
			jo.put("state", -1);
			jo.put("msg", "新增失败："+ e.getMessage());
		} finally {
			out.write(JSON.toJSONString(jo));
			out.flush();
			out.close();
		}
	}
	
	@RequestMapping("/queryAll")
	public void queryAll() {
		
	}
	

	@ModelAttribute
	public void initDate(HttpServletRequest request,HttpServletResponse response) {
		System.out.println("初始化参数");
		this.request = request;
		this.response = response;
		this.response.setContentType("text/html;charset=utf-8");
	}
	
	/**
	 * 处理参数为日期格式
	 * @param binder
	 */
	@InitBinder
	public void initBinder(ServletRequestDataBinder binder){
		binder.registerCustomEditor(Date.class, new CustomDateEditor(new SimpleDateFormat("yyyy-MM-dd"),true));
	}
	
	
}
