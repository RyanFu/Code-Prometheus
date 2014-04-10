package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 公司Entity
 */
@DatabaseTable
public class CP_Company {

	public CP_Company() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 年收入 */
	@DatabaseField
	private Integer cp_income;
	/** 行业 */
	@DatabaseField
	private String cp_industry;
	/** 公司名称 */
	@DatabaseField
	private String cp_name;
	/** 职位 */
	@DatabaseField
	private String cp_post;
	/** 职位描述 */
	@DatabaseField
	private String cp_post_description;
	/** 公司地址 */
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
	/** 邮编 */
	@DatabaseField
	private String cp_zip;
	/** 职员数量 */
	@DatabaseField
	private Integer cp_worker_amount;
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

	public Integer getCp_income() {
		return cp_income;
	}

	public void setCp_income(Integer cp_income) {
		this.cp_income = cp_income;
	}

	public String getCp_industry() {
		return cp_industry;
	}

	public void setCp_industry(String cp_industry) {
		this.cp_industry = cp_industry;
	}

	public String getCp_name() {
		return cp_name;
	}

	public void setCp_name(String cp_name) {
		this.cp_name = cp_name;
	}

	public String getCp_post() {
		return cp_post;
	}

	public void setCp_post(String cp_post) {
		this.cp_post = cp_post;
	}

	public String getCp_post_description() {
		return cp_post_description;
	}

	public void setCp_post_description(String cp_post_description) {
		this.cp_post_description = cp_post_description;
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

	public String getCp_zip() {
		return cp_zip;
	}

	public void setCp_zip(String cp_zip) {
		this.cp_zip = cp_zip;
	}

	public Integer getCp_worker_amount() {
		return cp_worker_amount;
	}

	public void setCp_worker_amount(Integer cp_worker_amount) {
		this.cp_worker_amount = cp_worker_amount;
	}

	public String getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(String cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
