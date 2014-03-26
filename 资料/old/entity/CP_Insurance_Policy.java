package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 保单Entity
 */
@DatabaseTable
public class CP_Insurance_Policy {
	public CP_Insurance_Policy() {

	}

	/** uuid */
	@DatabaseField(id = true)
	private String cp_uuid;
	/** 时间戳 */
	@DatabaseField
	private Integer cp_timestamp;
	/** 保单生效日期 */
	@DatabaseField
	private Integer cp_date_begin;
	/** 保单结束日期 */
	@DatabaseField
	private Integer cp_date_end;
	/** 名称 */
	@DatabaseField
	private String cp_name;
	/** 我的保单 */
	@DatabaseField
	private Integer cp_my_policy;
	/** 内容 */
	@DatabaseField
	private String cp_description;
	/** 缴费方式 */
	@DatabaseField
	private Integer cp_pay_type;
	/** 缴费金额 */
	@DatabaseField
	private Integer cp_pay_amount;
	/** 付款方式 */
	@DatabaseField
	private Integer cp_pay_way;
	/** 提醒缴费 */
	@DatabaseField
	private Integer cp_remind_date;
	/** 联系人uuid */
	@DatabaseField
	private Integer cp_contact_uuid;

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

	public Integer getCp_date_begin() {
		return cp_date_begin;
	}

	public void setCp_date_begin(Integer cp_date_begin) {
		this.cp_date_begin = cp_date_begin;
	}

	public Integer getCp_date_end() {
		return cp_date_end;
	}

	public void setCp_date_end(Integer cp_date_end) {
		this.cp_date_end = cp_date_end;
	}

	public String getCp_name() {
		return cp_name;
	}

	public void setCp_name(String cp_name) {
		this.cp_name = cp_name;
	}

	public Integer getCp_my_policy() {
		return cp_my_policy;
	}

	public void setCp_my_policy(Integer cp_my_policy) {
		this.cp_my_policy = cp_my_policy;
	}

	public String getCp_description() {
		return cp_description;
	}

	public void setCp_description(String cp_description) {
		this.cp_description = cp_description;
	}

	public Integer getCp_pay_type() {
		return cp_pay_type;
	}

	public void setCp_pay_type(Integer cp_pay_type) {
		this.cp_pay_type = cp_pay_type;
	}

	public Integer getCp_pay_amount() {
		return cp_pay_amount;
	}

	public void setCp_pay_amount(Integer cp_pay_amount) {
		this.cp_pay_amount = cp_pay_amount;
	}

	public Integer getCp_pay_way() {
		return cp_pay_way;
	}

	public void setCp_pay_way(Integer cp_pay_way) {
		this.cp_pay_way = cp_pay_way;
	}

	public Integer getCp_remind_date() {
		return cp_remind_date;
	}

	public void setCp_remind_date(Integer cp_remind_date) {
		this.cp_remind_date = cp_remind_date;
	}

	public Integer getCp_contact_uuid() {
		return cp_contact_uuid;
	}

	public void setCp_contact_uuid(Integer cp_contact_uuid) {
		this.cp_contact_uuid = cp_contact_uuid;
	}

}
