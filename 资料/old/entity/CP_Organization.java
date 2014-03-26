package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 组织发展
 */
@DatabaseTable
public class CP_Organization {

	public CP_Organization() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 是否增员 */
	@DatabaseField
	private Integer cp_by_members;
	/** 学历 */
	@DatabaseField
	private Integer cp_education;
	/** 工作现状 */
	@DatabaseField
	private String cp_working_conditions;
	/** 来京日期 */
	@DatabaseField
	private Integer cp_to_beijing_date;
	/** 预计入班时间 */
	@DatabaseField
	private Integer cp_into_class_date;
	/** 是否参加创说会(创业说明会) */
	@DatabaseField
	private Integer cp_meeting;
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

	public Integer getCp_by_members() {
		return cp_by_members;
	}

	public void setCp_by_members(Integer cp_by_members) {
		this.cp_by_members = cp_by_members;
	}

	public Integer getCp_education() {
		return cp_education;
	}

	public void setCp_education(Integer cp_education) {
		this.cp_education = cp_education;
	}

	public String getCp_working_conditions() {
		return cp_working_conditions;
	}

	public void setCp_working_conditions(String cp_working_conditions) {
		this.cp_working_conditions = cp_working_conditions;
	}

	public Integer getCp_to_beijing_date() {
		return cp_to_beijing_date;
	}

	public void setCp_to_beijing_date(Integer cp_to_beijing_date) {
		this.cp_to_beijing_date = cp_to_beijing_date;
	}

	public Integer getCp_into_class_date() {
		return cp_into_class_date;
	}

	public void setCp_into_class_date(Integer cp_into_class_date) {
		this.cp_into_class_date = cp_into_class_date;
	}

	public Integer getCp_meeting() {
		return cp_meeting;
	}

	public void setCp_meeting(Integer cp_meeting) {
		this.cp_meeting = cp_meeting;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
