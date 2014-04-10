package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 创说会Entity
 */
@DatabaseTable
public class CP_Meeting {

	public CP_Meeting() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 日期 */
	@DatabaseField
	private Integer cp_data;
	/** 描述 */
	@DatabaseField
	private String cp_description;
	/** 联系人uuid */
	@DatabaseField
	private String cp_contact_uuid;

	public String getCp_uuid() {
		return cp_uuid;
	}

	public void setCp_uuid(String cp_uuid) {
		this.cp_uuid = cp_uuid;
	}

	public Integer getCp_timestamp() {
		return cp_timestamp;
	}

	public void setCp_timestamp(Integer cp_timestamp) {
		this.cp_timestamp = cp_timestamp;
	}

	public Integer getCp_data() {
		return cp_data;
	}

	public void setCp_data(Integer cp_data) {
		this.cp_data = cp_data;
	}

	public String getCp_description() {
		return cp_description;
	}

	public void setCp_description(String cp_description) {
		this.cp_description = cp_description;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
