package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 文件Entity
 */
@DatabaseTable
public class CP_File {
	public CP_File() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 关联uuid */
	@DatabaseField
	private String CP_r_uuid;
	/** 本地路径 */
	@DatabaseField
	private String cp_path;
	/** 网络路径 */
	@DatabaseField
	private String cp_url;
	/** 文件类型 */
	@DatabaseField(defaultValue = "1")
	private int cp_type;
	/** md5 */
	@DatabaseField
	private String cp_md5;
	/** 时间戳 */
	@DatabaseField
	private int cp_timestamp;

	public String getCp_uuid() {
		return cp_uuid;
	}

	public void setCp_uuid(String cp_uuid) {
		this.cp_uuid = cp_uuid;
	}

	public String getCP_r_uuid() {
		return CP_r_uuid;
	}

	public void setCP_r_uuid(String cP_r_uuid) {
		CP_r_uuid = cP_r_uuid;
	}

	public String getCp_path() {
		return cp_path;
	}

	public void setCp_path(String cp_path) {
		this.cp_path = cp_path;
	}

	public String getCp_url() {
		return cp_url;
	}

	public void setCp_url(String cp_url) {
		this.cp_url = cp_url;
	}

	public int getCp_type() {
		return cp_type;
	}

	public void setCp_type(int cp_type) {
		this.cp_type = cp_type;
	}

	public String getCp_md5() {
		return cp_md5;
	}

	public void setCp_md5(String cp_md5) {
		this.cp_md5 = cp_md5;
	}

	public int getCp_timestamp() {
		return cp_timestamp;
	}

	public void setCp_timestamp(int cp_timestamp) {
		this.cp_timestamp = cp_timestamp;
	}

}
