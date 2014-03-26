/*
 Navicat Premium Data Transfer

 Source Server         : helper 2
 Source Server Type    : SQLite
 Source Server Version : 3007011
 Source Database       : main

 Target Server Type    : SQLite
 Target Server Version : 3007011
 File Encoding         : utf-8

 Date: 12/09/2013 11:40:16 AM
*/

PRAGMA foreign_keys = false;

-- ----------------------------
--  Table structure for "android_metadata"
-- ----------------------------
DROP TABLE IF EXISTS "android_metadata";
CREATE TABLE android_metadata (locale TEXT);

-- ----------------------------
--  Table structure for "cp_car"
-- ----------------------------
DROP TABLE IF EXISTS "cp_car";
CREATE TABLE `cp_car` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_name` VARCHAR , `cp_plate_number` VARCHAR , `cp_maturity_date` INTEGER , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_company"
-- ----------------------------
DROP TABLE IF EXISTS "cp_company";
CREATE TABLE `cp_company` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_on_position` INTEGER , `cp_income` INTEGER , `cp_industry` VARCHAR , `cp_name` VARCHAR , `cp_post` VARCHAR , `cp_post_description` VARCHAR , `cp_address_name` VARCHAR , `cp_longitude` VARCHAR , `cp_latitude` VARCHAR , `cp_zoom` INTEGER , `cp_invain` INTEGER , `cp_zip` VARCHAR , `cp_worker_amount` INTEGER , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_contacts"
-- ----------------------------
DROP TABLE IF EXISTS "cp_contacts";
CREATE TABLE `cp_contacts` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_name` VARCHAR , `cp_sex` INTEGER DEFAULT 0 , `cp_phone_number` VARCHAR , `cp_birthday` VARCHAR , `cp_clues` INTEGER , `cp_refer_contact` VARCHAR , `cp_weixin` VARCHAR , `cp_im` VARCHAR , `cp_email` VARCHAR , `cp_blood_type` INTEGER DEFAULT 0 , `cp_height` VARCHAR , `cp_weight` VARCHAR , `cp_hobby` VARCHAR , `cp_hometown` VARCHAR , `cp_picture_name` INTEGER DEFAULT 0 , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_family"
-- ----------------------------
DROP TABLE IF EXISTS "cp_family";
CREATE TABLE `cp_family` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_car` INTEGER DEFAULT 0 , `cp_estate` INTEGER DEFAULT 0 , `cp_address_name` VARCHAR , `cp_longitude` VARCHAR , `cp_latitude` VARCHAR , `cp_zoom` INTEGER , `cp_invain` INTEGER , `cp_marriage_status` INTEGER DEFAULT 0 , `cp_spouse_name` VARCHAR , `cp_spouse_phone` VARCHAR , `cp_spouse_birthday` VARCHAR , `cp_member_status` INTEGER , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_family_member"
-- ----------------------------
DROP TABLE IF EXISTS "cp_family_member";
CREATE TABLE `cp_family_member` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_name` VARCHAR , `cp_sex` INTEGER DEFAULT 0 , `cp_birthday` VARCHAR , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_file"
-- ----------------------------
DROP TABLE IF EXISTS "cp_file";
CREATE TABLE `cp_file` (`cp_uuid` VARCHAR , `cp_r_uuid` VARCHAR , `cp_path` VARCHAR , `cp_url` VARCHAR , `cp_type` INTEGER DEFAULT 1 , `cp_md5` VARCHAR , `cp_timestamp` INTEGER , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_insurance_policy"
-- ----------------------------
DROP TABLE IF EXISTS "cp_insurance_policy";
CREATE TABLE `cp_insurance_policy` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_date_begin` INTEGER , `cp_date_end` INTEGER , `cp_name` VARCHAR , `cp_my_policy` INTEGER , `cp_description` VARCHAR , `cp_pay_type` INTEGER DEFAULT 0 , `cp_pay_amount` INTEGER , `cp_pay_way` INTEGER DEFAULT 0 , `cp_remind_date` INTEGER , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_meeting"
-- ----------------------------
DROP TABLE IF EXISTS "cp_meeting";
CREATE TABLE `cp_meeting` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_date` INTEGER , `cp_description` VARCHAR , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_organization"
-- ----------------------------
DROP TABLE IF EXISTS "cp_organization";
CREATE TABLE `cp_organization` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_zengyuan` INTEGER , `cp_graduated` VARCHAR , `cp_education` INTEGER DEFAULT 0 , `cp_working_conditions` INTEGER DEFAULT 0 , `cp_to_beijing_date` INTEGER , `cp_into_class_date` INTEGER , `cp_meeting` INTEGER , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_other"
-- ----------------------------
DROP TABLE IF EXISTS "cp_other";
CREATE TABLE `cp_other` (`cp_uuid` VARCHAR , `cp_timestamp` INTEGER , `cp_travel_insurance` INTEGER DEFAULT 0 , `cp_group_insurance` INTEGER DEFAULT 0 , `cp_car_insurance` INTEGER DEFAULT 0 , `cp_contact_uuid` VARCHAR , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "cp_trace"
-- ----------------------------
DROP TABLE IF EXISTS "cp_trace";
CREATE TABLE `cp_trace` (`cp_uuid` VARCHAR , `cp_contact_uuid` VARCHAR , `cp_date` INTEGER , `cp_stage` INTEGER , `cp_description` VARCHAR , `cp_timestamp` INTEGER , PRIMARY KEY (`cp_uuid`) );

-- ----------------------------
--  Table structure for "dbinfo"
-- ----------------------------
DROP TABLE IF EXISTS "dbinfo";
CREATE TABLE `dbinfo` (`cp_key` VARCHAR , `cp_value` VARCHAR , PRIMARY KEY (`cp_key`) );

-- ----------------------------
--  Table structure for "pushmessage"
-- ----------------------------
DROP TABLE IF EXISTS "pushmessage";
CREATE TABLE `pushmessage` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT , `cp_title` VARCHAR , `cp_content` VARCHAR , `cp_timestamp` INTEGER );

-- ----------------------------
--  Table structure for "settinginfo"
-- ----------------------------
DROP TABLE IF EXISTS "settinginfo";
CREATE TABLE `settinginfo` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT , `securityEmail` VARCHAR , `securityPhone` VARCHAR , `wifiSync` INTEGER , `balance` INTEGER , `licenseTime` INTEGER );

-- ----------------------------
--  Table structure for "t_sync_data"
-- ----------------------------
DROP TABLE IF EXISTS "t_sync_data";
CREATE TABLE `t_sync_data` (`_id` INTEGER PRIMARY KEY AUTOINCREMENT , `resourceType` VARCHAR , `uuid` VARCHAR , `action` VARCHAR , `updatedAt` INTEGER , `content` VARCHAR , `url` VARCHAR , `md5` VARCHAR , `tableName` VARCHAR );

PRAGMA foreign_keys = true;
