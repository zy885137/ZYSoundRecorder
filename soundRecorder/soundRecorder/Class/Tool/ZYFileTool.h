//
//  ZYFileTool.h
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface ZYFileTool : NSObject

+ (NSString *)cacheDirectory;

+ (NSString *)createPathWithChildPath:(NSString *)childPath;

@end

NS_ASSUME_NONNULL_END
