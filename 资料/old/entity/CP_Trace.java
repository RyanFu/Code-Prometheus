package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 跟进Entity
 */
@DatabaseTable
public class CP_Trace {

	public CP_Trace() {
	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 联系人uuid */
	@DatabaseField
	private String cp_contact_uuid;
	/** 时间 */
	@DatabaseField
	private int cp_date;
	/** 阶段 */
	@DatabaseField
	private int cp_stage;
	/** 描述 */
	@DatabaseField
	private String cp_description;
	/** 时间戳 */
	@DatabaseField
	private int cp_timestamp;

	public String getCp_uuid() {
		return cp_uuid;
	}

	public void setCp_uuid(String cp_uuid) {
		this.cp_uuid = cp_uuid;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

	public int getCp_date() {
		return cp_date;
	}

	public void setCp_date(int cp_date) {
		this.cp_date = cp_date;
	}

	public int getCp_stage() {
		return cp_stage;
	}

	public void setCp_stage(int cp_stage) {
		this.cp_stage = cp_stage;
	}

	public String getCp_description() {
		return cp_description;
	}

	public void setCp_description(String cp_description) {
		this.cp_description = cp_description;
	}

	public int getCp_timestamp() {
		return cp_timestamp;
	}

	public void setCp_timestamp(int cp_timestamp) {
		this.cp_timestamp = cp_timestamp;
	}

}
