//
//  JJUserSDKDBHelper.m
//  JJUserSDK
//
//  Created by xiedong on 2020/11/20.
//

#import "JJUserSDKDBHelper.h"
#import "JJUserInfoModel.h"

NSString *_userInfoTableName = @"table_detail_info";

@implementation JJUserSDKDBHelper

//MARK: - Override
- (BOOL)databaseOnCreate:(FMDatabase *)db {
    return [self setupTables:db];
}


- (BOOL)databaseOnUpgrade:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
    BOOL result = YES;
    
    for (int i = oldVersion; i < newVersion; i++) {
        switch (i) {
            case 1:
            {
                
            }
                break;
            //一个升级的例子
            case 100:
            {
                result = [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD other_info TEXT;",_userInfoTableName]] &&
                [db executeUpdate:[NSString stringWithFormat:@"ALTER TABLE %@ ADD other_info2 TEXT;",_userInfoTableName]];
                
                if (!result) {
                    NSLog(@"[JJUserSDKDBHelper] failed to upgrade table: %@",_userInfoTableName);
                    break;
                }
            }
                break;
            default:
                break;
        }
    }
    return result;
}

- (BOOL)setupTables:(FMDatabase *)db {
    
    BOOL result = YES;
    
    if (![db tableExists:_userInfoTableName]) {
        NSString *createSQL = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (uid TEXT, nickName TEXT, sex TEXT, phone TEXT, birthday TEXT, headPic TEXT, remarks TEXT, province TEXT, city TEXT)",_userInfoTableName];
        result = [db executeUpdate:createSQL];
        
        if (!result) {
            NSLog(@"[JJUserSDKDBHelper] failed to create: %@",createSQL);
        }
    }
    return result;
}

- (BOOL)updateUserDetailInfo:(JJUserInfoModel *)infoModel {
    
    [self inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
        NSString *deleteSQL = [NSString stringWithFormat:@"DELETE FROM %@", _userInfoTableName];
        
        if ([db executeUpdate:deleteSQL]) {
            if (infoModel) {
                NSString *insertSQL = [NSString stringWithFormat:@"INSERT INTO %@ (uid, nickName, sex, phone, birthday, headPic, remarks, province, city) VALUES ('%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@', '%@')",_userInfoTableName,
                                       infoModel.uid,
                                       infoModel.nickName,
                                       infoModel.sex,
                                       infoModel.phone,
                                       infoModel.birthday,
                                       infoModel.headPic,
                                       infoModel.remarks,
                                       infoModel.province,
                                       infoModel.city];
                if (![db executeUpdate:insertSQL]) {
                    NSLog(@"[JJUserSDKDBHelper] failed to execute sql: %@",insertSQL);
                    *rollback = YES;
                }
            }
        } else {
            *rollback = YES;
        }
    }];
    
    return YES;
}

- (JJUserInfoModel *)getUserDetailInfo {
    __block JJUserInfoModel *infoMode;
    [self inDatabase:^(FMDatabase * _Nonnull db) {
        NSString *querySQL = [NSString stringWithFormat:@"SELECT * FROM %@",_userInfoTableName];
        FMResultSet *resultSet = [db executeQuery:querySQL];
        while ([resultSet next]) {
            infoMode = [[JJUserInfoModel alloc] init];
            infoMode.uid = [resultSet stringForColumn:@"uid"];
            infoMode.nickName = [resultSet stringForColumn:@"nickName"];
            infoMode.sex = [resultSet stringForColumn:@"sex"];
            infoMode.phone = [resultSet stringForColumn:@"phone"];
            infoMode.birthday = [resultSet stringForColumn:@"birthday"];
            infoMode.headPic = [resultSet stringForColumn:@"headPic"];
            infoMode.remarks = [resultSet stringForColumn:@"remarks"];
            infoMode.province = [resultSet stringForColumn:@"province"];
            infoMode.city = [resultSet stringForColumn:@"city"];
        }
        
        [resultSet close];
    }];
    return infoMode;
}

@end
