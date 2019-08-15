//
//  ZYRecordManager.h
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define shortRecord @"shortRecord"

@protocol ZYRecordManagerDelegate <NSObject>

/// 录音完成-生成音频文件
- (void)recordDidFinishedWithRecordPath:(NSString *)recordPath duration:(NSTimeInterval)duration;

@end

@interface ZYRecordManager : NSObject

@property (nonatomic, weak) id <ZYRecordManagerDelegate> delegate;

+ (instancetype)shareManager;

/// 开始录制
- (void)startRecordingWithFileName:(NSString *)fileName
                        completion:(void(^)(NSError *error))completion;
/// 结束录制
- (void)stopRecord;

/// 取消当前录制
- (void)cancelCurrentRecording;

/// 删除录音文件
- (void)removeCurrentRecordFile:(NSString *)fileName;

/// 音量
- (float)power;

@end

NS_ASSUME_NONNULL_END
