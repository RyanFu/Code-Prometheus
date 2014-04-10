package com.mirror.insuranceassistant.entity;

import com.j256.ormlite.field.DatabaseField;
import com.j256.ormlite.table.DatabaseTable;

/**
 * 人脉Entity
 */
@DatabaseTable
public class CP_Contacts {
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
	/** 手机 */
	@DatabaseField
	private String cp_phone_number;
	/** 生日 */
	@DatabaseField
	private String cp_birthday;
	/** 线索来源 */
	@DatabaseField
	private Integer cp_clues;
	/** 被转介绍 */
	@DatabaseField
	private String cp_refer_contact;
	/** 微信 */
	@DatabaseField
	private String cp_weixin;
	/** QQ */
	@DatabaseField
	private String cp_im;
	/** 邮箱 */
	@DatabaseField
	private String cp_email;
	/** 血型 */
	@DatabaseField
	private Integer cp_blood_type;
	/** 身高 */
	@DatabaseField
	private String cp_height;
	/** 体重 */
	@DatabaseField
	private String cp_weight;
	/** 爱好 */
	@DatabaseField
	private String cp_hobby;
	/** 籍贯 */
	@DatabaseField
	private String cp_hometown;
	/** 头像文件名 */
	@DatabaseField
	private Integer cp_picture_name;

	public CP_Contacts() {
	}

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

	public String getCp_phone_number() {
		return cp_phone_number;
	}

	public void setCp_phone_number(String cp_phone_number) {
		this.cp_phone_number = cp_phone_number;
	}

	public String getCp_birthday() {
		return cp_birthday;
	}

	public void setCp_birthday(String cp_birthday) {
		this.cp_birthday = cp_birthday;
	}

	public Integer getCp_clues() {
		return cp_clues;
	}

	public void setCp_clues(Integer cp_clues) {
		this.cp_clues = cp_clues;
	}

	public String getCp_refer_contact() {
		return cp_refer_contact;
	}

	public void setCp_refer_contact(String cp_refer_contact) {
		this.cp_refer_contact = cp_refer_contact;
	}

	public String getCp_weixin() {
		return cp_weixin;
	}

	public void setCp_weixin(String cp_weixin) {
		this.cp_weixin = cp_weixin;
	}

	public String getCp_im() {
		return cp_im;
	}

	public void setCp_im(String cp_im) {
		this.cp_im = cp_im;
	}

	public String getCp_email() {
		return cp_email;
	}

	public void setCp_email(String cp_email) {
		this.cp_email = cp_email;
	}

	public Integer getCp_blood_type() {
		return cp_blood_type;
	}

	public void setCp_blood_type(Integer cp_blood_type) {
		this.cp_blood_type = cp_blood_type;
	}

	public String getCp_height() {
		return cp_height;
	}

	public void setCp_height(String cp_height) {
		this.cp_height = cp_height;
	}

	public String getCp_weight() {
		return cp_weight;
	}

	public void setCp_weight(String cp_weight) {
		this.cp_weight = cp_weight;
	}

	public String getCp_hobby() {
		return cp_hobby;
	}

	public void setCp_hobby(String cp_hobby) {
		this.cp_hobby = cp_hobby;
	}

	public String getCp_hometown() {
		return cp_hometown;
	}

	public void setCp_hometown(String cp_hometown) {
		this.cp_hometown = cp_hometown;
	}

	public Integer getCp_picture_name() {
		return cp_picture_name;
	}

	public void setCp_picture_name(Integer cp_picture_name) {
		this.cp_picture_name = cp_picture_name;
	}
}
