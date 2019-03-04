<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ include file="common.jsp" %>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>学生信息列表</title>	
<script type="text/javascript">

	var url = "";

	
	//将表单数据转为json
	function form2Json(id) {
	
	    var arr = $("#" + id).serializeArray();
	    var jsonStr = "";
	
	   	jsonStr += '{';
	    for (var i = 0; i < arr.length; i++) {
	        jsonStr += '"' + arr[i].name + '":"' + arr[i].value + '",'
	    }
	    jsonStr = jsonStr.substring(0, (jsonStr.length - 1));
	    jsonStr += '}'
	
	    var json = JSON.parse(jsonStr);
	    return json;
	}

	$(function(){

		//点击搜索
		$("#search_btn").click(function() {
		    $('#dg').datagrid({ 
		    	queryParams: form2Json("searchForm")//查询参数
		    });
	    });
		
		//点击导入
		$("#import_btn").click(function() {
			var filename = $("#file").filebox("getText");
			if(filename==""){
				$.messager.alert("提示","请选择需要导入的文件！","info");
				return;
			} else{
				url = "classesServlet?opType=importFile";
				importFile();
			}
	    });
		
		//点击导出
		$("#export_btn").click(function() {
			$.messager.confirm('确认对话框', '确认下载?', function(r){
				if (r){
					url = "classesServlet?opType=exportFile&filename=classes.xls";
					exportFile();
					/* 
					$("#export_btn").attr("href",url);
					$('#export_btn').linkbutton('click');
					 */
				}
			});
	    });
		
		$("#dg").datagrid({
			idField:"id",
			url:'classes/queryByPage',
			fitColumns:true,
			striped:true,
			pagination:true,
			rownumbers:true,
			singleSelect:false,
			scrollbarSize:0,
			pageSize:30,
			//queryParams: form2Json("searchForm"),//查询参数
			//pageList:[10,20,30,40],
			columns:[[
				{field:'',checkbox:true},
				{field:'id',width:100,align:'center',title:'ID',sortable:true,hidden:false},
				{field:'name',width:100,align:'center',title:'班级名称',sortable:true}
			]],
			toolbar:[{
				text:"新增",
				iconCls:"icon-add",
				handler:function(){
					add();
				}
			},{
				text:"编辑",
				iconCls:"icon-edit",
				handler:function(){
					update();
				}
			},{
				text:"删除",
				iconCls:"icon-remove",
				handler:function(){
					remove();
				}
			}]
	
		})
		
	})
	
	$.extend($.fn.validatebox.defaults.rules, {    
	    equals: {    
	        validator: function(value,param){    
	            return value == $(param[0]).val();    
	        },
	        message: '两次输入的密码不一致！'   
	    },
	    age: {    
	        validator: function(value,param){    
	            return value>=param[0] && value<=param[1];    
	        },    
	        message: '年龄范围在{0}到{1}之间！'
	    },
	    fileType: {    
	        validator: function(value,param){    
	            return value.substring(value.lastIndexOf("."))==param[0];    
	        },    
	        message: '要求文件类型为{0}'
	    }
	});
	
	function remove() {
		var array = $("#dg").datagrid("getSelections");
		if (array==0) {
			$.messager.alert("提示","请选择要删除的选项！","info");
			return;
		}
		$.messager.confirm("提示","请确定要删除所选的【"+array.length+"】条记录吗？",function(yes){
			if(yes){
				var ids = "";
				for (var i = 0; i < array.length; i++) {
					ids += array[i].id+",";
				}
				ids = ids.substring(0,ids.length-1);
				$.ajax({
					url:"classes/deleteMore",
					type:"post",
					data:"ids="+ids,
					dataType:"json",
					success:function(result){
						if(result.state==0){
							$.messager.alert("提示",result.msg,"info");
						}else{
							$.messager.alert("提示",result.msg,"error");
						}
						//刷新表格
						$("#dg").datagrid("reload");
						//清除所有选择的行。
						$("#dg").datagrid("clearSelections");
					}
				})
			}
		})
	}
	
	//点击新增
	function add() {
		//清除所有选择的行。
		$("#dg").datagrid("clearSelections");
		$("#Form").form("reset");
		url = "classes/add";
		openDialogForm();
		$("#dd").dialog("setTitle","新增学生信息");
	}
	
	//点击编辑
	function update() {
		var array = $("#dg").datagrid("getSelections");
		if(array.length==0){
			$.messager.alert("提示","请选择要修改的选项！","info");
			return;
		}else if(array.length>1){
			$.messager.alert("提示","单次只能对一条信息进行修改！","info");
			return;
		}
		$("#Form").form("reset");
		$("#Form").form("load",array[0]);
		url = "classes/update?id="+array[0].id;
		openDialogForm();
		$("#dd").dialog("setTitle","修改学生信息");
		//$("#pwd").textbox("disable");
		$("#rpwd").textbox("disable");
	}
	
	//打开 新增、编辑 对话框窗口
	function openDialogForm() {
		$("#dd").dialog({
			modal:true,
			buttons:[{
				text:"保存",
				iconCls:"icon-save",
				handler:function(){
					save();
				}
			},{
				text:"重置",
				iconCls:"icon-reload",
				handler:function(){
					var array = $("#dg").datagrid("getSelections");
					if (array.length==0) {
						$("#Form").form("reset");
					}
					if (array.length==1) {
						$("#Form").form("load",array[0]);
					}
				}
			},{
				text:"取消",
				iconCls:"icon-cancel",
				handler:function(){
					$("#dd").dialog("close");
				}
			}]
		})
		$("#dd").dialog("open");
	}
	
	//保存
	function save() {
		$("#Form").form("submit",{
			url:url,
			success:function(result){
				
				//将传来的json字符串转换为json对象	
				//var result = eval("("+result+")");
				var result = JSON.parse(result);
				
				if(result.state==0){
					$.messager.alert("提示",result.msg,"info");
					$("#dg").datagrid("reload");
				}else{
					$.messager.alert("提示",result.msg,"error");
				}
				//关闭表单
				$("#dd").dialog("close");
			}
		})
	}
	

	//导入方法
	function importFile() {
		$("#searchForm").form("submit",{
			url:url,
			success:function(result){
				$.messager.alert("提示","导入成功","info");
				
				//刷新表格
				$("#dg").datagrid("reload");
			}
		})
	}
	
	//导出方法
	function exportFile() {
		$("#searchForm").form("submit",{
			url:url,
			success:function(result){
				
			}
		})
	}
	
</script>
    
</head>
<body>

	<div style="height: 5%;">
		<form id="searchForm" method="post" style="padding-top: 4px;" enctype="multipart/form-data">
			姓&emsp;名：<input name="qname" class="easyui-textbox" data-options="iconCls:'icon-man'">&emsp;
			帐&emsp;号：<input name="qusername" class="easyui-textbox" data-options="iconCls:'icon-man'">&emsp;
			性&emsp;别：<select name="qsex" class="easyui-combobox">
							<option value="-1">--请选择--</option>
							<option value="1">男</option>
							<option value="0">女</option>
						</select>&emsp;
			开始日期：<input name="qbeginDate" class="easyui-datebox" data-options="editable:false">&emsp;
			结束日期：<input name="qendDate" class="easyui-datebox" data-options="editable:false">
			<a id="search_btn" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-search'">搜索</a>&emsp;
			<input id="file" name="file" class="easyui-filebox" style="width:200px" data-options="buttonText: '选择文件',validType:'fileType[\'.xls\']'">
			<a id="import_btn" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-redo'">导入</a>
			<a id="export_btn" href="#" class="easyui-linkbutton" data-options="iconCls:'icon-print'">导出</a> 
		</form>
	</div>

	<div style="height: 95%;">
		<table id="dg" fit="true"></table>
	</div>
	
	<div id="dd" class="easyui-dialog" style="width: 300px;" closed="true">
		<form id="Form" method="post">
			<table style="margin: 0 auto;">
				<tr>
					<td class="right">班级名称：</td>
					<td><input name="name" class="easyui-textbox" data-options="required:true"></td>
				</tr>
			</table>
		</form>
	</div>
</table> 
</body>
</html>