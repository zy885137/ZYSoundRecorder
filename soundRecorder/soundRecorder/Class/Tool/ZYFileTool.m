//
//  ZYFileTool.m
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import "ZYFileTool.h"

@implementation ZYFileTool

+ (NSString *)cacheDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
}

+ (NSString *)createPathWithChildPath:(NSString *)childPath {
    NSString *path = [[self cacheDirectory] stringByAppendingPathComponent:childPath];
    BOOL isDirExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    if (!isDirExist) {
        BOOL isCreatDir = [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (!isCreatDir) {
            NSLog(@"create folder failed");
            return nil;
        }
    }
    return path;
}

@end
