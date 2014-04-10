package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 儿女Entity
 */
@DatabaseTable
public class CP_Family_Member {

	public CP_Family_Member() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 姓名 */
	@DatabaseField
	private String cp_name;
	/** 性别 */
	@DatabaseField
	private Integer cp_sex;
	/** 时间 */
	@DatabaseField
	private Integer cp_birthday;
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

	public String getCp_name() {
		return cp_name;
	}

	public void setCp_name(String cp_name) {
		this.cp_name = cp_name;
	}

	public Integer getCp_sex() {
		return cp_sex;
	}

	public void setCp_sex(Integer cp_sex) {
		this.cp_sex = cp_sex;
	}

	public Integer getCp_birthday() {
		return cp_birthday;
	}

	public void setCp_birthday(Integer cp_birthday) {
		this.cp_birthday = cp_birthday;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
