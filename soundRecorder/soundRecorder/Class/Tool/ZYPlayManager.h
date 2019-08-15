//
//  ZYPlayManager.h
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol ZYPlayManagerDelegate <NSObject>

/// 音频播放完成
- (void)voiceDidPlayFinished;

@end

@interface ZYPlayManager : NSObject

@property (nonatomic, weak) id <ZYPlayManagerDelegate> delegate;

+ (instancetype)shareManager;

- (void)startPlayRecorder:(NSURL *)url;

- (void)stopPlayRecorder:(NSURL *)url;

- (void)pause;

@end

NS_ASSUME_NONNULL_END
