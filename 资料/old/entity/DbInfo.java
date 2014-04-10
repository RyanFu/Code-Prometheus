package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 数据库信息
 */
@DatabaseTable
public class DbInfo {

	@DatabaseField(id = true)
	private String cp_key;
	@DatabaseField
	private String cp_value;

	public DbInfo() {

	}

	public String getCp_key() {
		return cp_key;
	}

	public void setCp_key(String cp_key) {
		this.cp_key = cp_key;
	}

	public String getCp_value() {
		return cp_value;
	}

	public void setCp_value(String cp_value) {
		this.cp_value = cp_value;
	}

}
