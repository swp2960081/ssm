package com.entor.util;

import java.util.List;

public class Pager<T> {
	
	/**
	 * 当前页码
	 */
	private int sp;
	/**
	 * 每页记录数
	 */
	private int pageSize;
	/**
	 * 总记录数
	 */
	private int totals;
	/**
	 * 总页数
	 */
	private int pageCounts;
	
	/**
	 * 封装数据
	 */
	private List<T> list;
	
	public Pager(int totals,String currentPage,String pageSize) {
		//总记录数
		this.totals = totals;
		
		//每页记录数
		try {
			this.pageSize = Integer.parseInt(pageSize);
		} catch (Exception e) {
			this.pageSize = 20;
		}
		
		//总页数
		this.pageCounts = this.totals/this.pageSize;
		if (this.totals%this.pageSize!=0) {
			this.pageCounts++;
		}
		
		//当前页码
		try {
			this.sp = Integer.parseInt(currentPage);
		} catch (Exception e) {
			this.sp = 1;
		}
		if (this.sp>this.pageCounts) {
			this.sp=this.pageCounts;
		}
		if (this.sp<1) {
			this.sp=1;
		}
		
	}
	
	public Pager() {
		super();
	}







	public int getSp() {
		return sp;
	}
	public void setSp(int sp) {
		this.sp = sp;
	}
	public int getPageSize() {
		return pageSize;
	}
	public void setPageSize(int pageSize) {
		this.pageSize = pageSize;
	}
	public int getTotals() {
		return totals;
	}
	public void setTotals(int totals) {
		this.totals = totals;
	}
	public int getPageCounts() {
		return pageCounts;
	}
	public void setPageCounts(int pageCounts) {
		this.pageCounts = pageCounts;
	}

	public List<T> getList() {
		return list;
	}

	public void setList(List<T> list) {
		this.list = list;
	}
	
	
	
}
