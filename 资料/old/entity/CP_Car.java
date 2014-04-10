package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 车辆Entity
 */
@DatabaseTable
public class CP_Car {

	public CP_Car() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 车辆名称 */
	@DatabaseField
	private String cp_name;
	/** 车牌号 */
	@DatabaseField
	private String cp_plate_number;
	/** 到期日 */
	@DatabaseField
	private Integer cp_maturity_date;
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

	public String getCp_plate_number() {
		return cp_plate_number;
	}

	public void setCp_plate_number(String cp_plate_number) {
		this.cp_plate_number = cp_plate_number;
	}

	public Integer getCp_maturity_date() {
		return cp_maturity_date;
	}

	public void setCp_maturity_date(Integer cp_maturity_date) {
		this.cp_maturity_date = cp_maturity_date;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
