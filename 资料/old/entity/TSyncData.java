package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 同步数据
 * <p>
 * 文件名: SyncData.java
 * <p>
 * 
 */
@DatabaseTable(tableName = "t_sync_data")
public class TSyncData {

	public TSyncData() {

	}

	/** 主键 */
	@DatabaseField(generatedId = true, columnName = "_id")
	private Integer id;

	/** 资源类型 */
	@DatabaseField
	private String resourceType;

	/** 资源的UUID */
	@DatabaseField
	private String uuid;

	/** 动作 */
	@DatabaseField
	private String action;

	/** 资源创建或修改的时间戳 */
	@DatabaseField
	private Integer updatedAt;

	/** 资源内容.为json编码后的文本块. */
	@DatabaseField
	private String content;

	/** 当resourceType为FILE的时候有效.指明文件的路径 */
	@DatabaseField
	private String url;

	/** 当resourceType为FILE的时候有效.指明文件的MD5值 */
	@DatabaseField
	private String md5;

	/** 表名 */
	@DatabaseField
	private String tableName;

	public Integer getId() {
		return id;
	}

	public void setId(Integer id) {
		this.id = id;
	}

	public String getResourceType() {
		return resourceType;
	}

	public void setResourceType(String resourceType) {
		this.resourceType = resourceType;
	}

	public String getUuid() {
		return uuid;
	}

	public void setUuid(String uuid) {
		this.uuid = uuid;
	}

	public String getAction() {
		return action;
	}

	public void setAction(String action) {
		this.action = action;
	}

	public Integer getUpdatedAt() {
		return updatedAt;
	}

	public void setUpdatedAt(Integer updatedAt) {
		this.updatedAt = updatedAt;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
	}

	public String getMd5() {
		return md5;
	}

	public void setMd5(String md5) {
		this.md5 = md5;
	}

	public String getTableName() {
		return tableName;
	}

	public void setTableName(String tableName) {
		this.tableName = tableName;
	}
}
