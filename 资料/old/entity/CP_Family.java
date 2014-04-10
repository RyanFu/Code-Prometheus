package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 家庭信息Entity
 */
@DatabaseTable
public class CP_Family {

	public CP_Family() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 车辆 */
	@DatabaseField
	private Integer cp_car;
	/** 房产 */
	@DatabaseField
	private Integer cp_estate;
	/** 家庭地址 */
	@DatabaseField
	private String cp_address_name;
	/** 经度 */
	@DatabaseField
	private String cp_longitude;
	/** 纬度 */
	@DatabaseField
	private String cp_latitude;
	/** 放大级别 */
	@DatabaseField
	private Integer cp_zoom;
	/** 是否有效 */
	@DatabaseField
	private Integer cp_invain;
	/** 婚否 */
	@DatabaseField
	private String cp_marriage_status;
	/** 爱人姓名 */
	@DatabaseField
	private String cp_wife_name;
	/** 爱人电话 */
	@DatabaseField
	private String cp_wife_phone;
	/** 爱人生日 */
	@DatabaseField
	private Integer cp_wife_birthday;
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

	public Integer getCp_car() {
		return cp_car;
	}

	public void setCp_car(Integer cp_car) {
		this.cp_car = cp_car;
	}

	public Integer getCp_estate() {
		return cp_estate;
	}

	public void setCp_estate(Integer cp_estate) {
		this.cp_estate = cp_estate;
	}

	public String getCp_address_name() {
		return cp_address_name;
	}

	public void setCp_address_name(String cp_address_name) {
		this.cp_address_name = cp_address_name;
	}

	public String getCp_longitude() {
		return cp_longitude;
	}

	public void setCp_longitude(String cp_longitude) {
		this.cp_longitude = cp_longitude;
	}

	public String getCp_latitude() {
		return cp_latitude;
	}

	public void setCp_latitude(String cp_latitude) {
		this.cp_latitude = cp_latitude;
	}

	public Integer getCp_zoom() {
		return cp_zoom;
	}

	public void setCp_zoom(Integer cp_zoom) {
		this.cp_zoom = cp_zoom;
	}

	public Integer getCp_invain() {
		return cp_invain;
	}

	public void setCp_invain(Integer cp_invain) {
		this.cp_invain = cp_invain;
	}

	public String getCp_marriage_status() {
		return cp_marriage_status;
	}

	public void setCp_marriage_status(String cp_marriage_status) {
		this.cp_marriage_status = cp_marriage_status;
	}

	public String getCp_wife_name() {
		return cp_wife_name;
	}

	public void setCp_wife_name(String cp_wife_name) {
		this.cp_wife_name = cp_wife_name;
	}

	public String getCp_wife_phone() {
		return cp_wife_phone;
	}

	public void setCp_wife_phone(String cp_wife_phone) {
		this.cp_wife_phone = cp_wife_phone;
	}

	public Integer getCp_wife_birthday() {
		return cp_wife_birthday;
	}

	public void setCp_wife_birthday(Integer cp_wife_birthday) {
		this.cp_wife_birthday = cp_wife_birthday;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
