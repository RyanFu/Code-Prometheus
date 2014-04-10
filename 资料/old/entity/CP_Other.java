package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 其它Entity
 */
@DatabaseTable
public class CP_Other {

	public CP_Other() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 旅行险 */
	@DatabaseField
	private Integer cp_travel_insurance;
	/** 团险 */
	@DatabaseField
	private Integer cp_group_insurance;
	/** 车险 */
	@DatabaseField
	private Integer cp_car_insurance;
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

	public Integer getCp_travel_insurance() {
		return cp_travel_insurance;
	}

	public void setCp_travel_insurance(Integer cp_travel_insurance) {
		this.cp_travel_insurance = cp_travel_insurance;
	}

	public Integer getCp_group_insurance() {
		return cp_group_insurance;
	}

	public void setCp_group_insurance(Integer cp_group_insurance) {
		this.cp_group_insurance = cp_group_insurance;
	}

	public Integer getCp_car_insurance() {
		return cp_car_insurance;
	}

	public void setCp_car_insurance(Integer cp_car_insurance) {
		this.cp_car_insurance = cp_car_insurance;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
