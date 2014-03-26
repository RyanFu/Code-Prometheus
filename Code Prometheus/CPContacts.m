//
//  CPContacts.m
//  Code Prometheus
//
//  Created by mirror on 13-11-23.
//  Copyright (c) 2013年 Mirror. All rights reserved.
//

#import "CPContacts.h"
#import "CPTrace.h"
#import "CPPolicy.h"
#import "CPFamily.h"
#import "CPFamilyMember.h"
#import "CPCompany.h"
#import "CPOrganization.h"
#import "CPMeeting.h"
#import "CPOther.h"
#import "CPCar.h"

@implementation CPContacts
// 表名
+(NSString *)getTableName
{
    return @"cp_contacts";
}

+(void) dbWillDelete:(NSObject *)entity{
    CPContacts* contacts = (CPContacts*)entity;
    // 删除追踪
    NSMutableArray* traces = [[CPDB getLKDBHelperByUser] search:[CPTrace class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPTrace* trace in traces) {
        [[CPDB getLKDBHelperByUser] deleteToDB:trace];
    }
    // 删除保单
    NSMutableArray* policyArray = [[CPDB getLKDBHelperByUser] search:[CPPolicy class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPPolicy* policy in policyArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:policy];
    }
    // 家庭
    NSMutableArray* familyArray = [[CPDB getLKDBHelperByUser] search:[CPFamily class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPFamily* family in familyArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:family];
    }
    // 孩子
    NSMutableArray* familyMemberArray = [[CPDB getLKDBHelperByUser] search:[CPFamilyMember class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPFamilyMember* familyMember in familyMemberArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:familyMember];
    }
    // 公司
    NSMutableArray* companyArray = [[CPDB getLKDBHelperByUser] search:[CPCompany class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPCompany* company in companyArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:company];
    }
    // 组织
    NSMutableArray* organizationArray = [[CPDB getLKDBHelperByUser] search:[CPOrganization class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPOrganization* organization in organizationArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:organization];
    }
    // 会议
    NSMutableArray* meetingArray = [[CPDB getLKDBHelperByUser] search:[CPMeeting class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPMeeting* meeting in meetingArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:meeting];
    }
    // 其他
    NSMutableArray* otherArray = [[CPDB getLKDBHelperByUser] search:[CPOther class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPOther* other in otherArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:other];
    }
    // 汽车
    NSMutableArray* carArray = [[CPDB getLKDBHelperByUser] search:[CPCar class] where:@{@"cp_contact_uuid":contacts.cp_uuid} orderBy:nil offset:0 count:-1];
    for (CPCar* car in carArray) {
        [[CPDB getLKDBHelperByUser] deleteToDB:car];
    }
}
@end
