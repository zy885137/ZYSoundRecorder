//
//  ZYPlayManager.m
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import "ZYPlayManager.h"
#import <AVFoundation/AVFoundation.h>

@interface ZYPlayManager() <AVAudioPlayerDelegate>

@property (nonatomic, strong) AVPlayer *player;

@end

@implementation ZYPlayManager

+ (instancetype)shareManager {
    static ZYPlayManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZYPlayManager alloc] init];
    });
    return _instance;
}

- (void)startPlayRecorder:(NSURL *)url {
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    self.player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
    self.player.volume = 1;
    //增加下面这行可以解决iOS10兼容性问题了
    if (@available(iOS 10.0, *)) {
        self.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    //播放状态
    [self.player.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    //播放完成
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFinished:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    //播放失败
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidFailed:) name:AVPlayerItemFailedToPlayToEndTimeNotification object:nil];
    //异常中断
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerDidStalled:) name:AVPlayerItemPlaybackStalledNotification object:nil];
}

- (void)stopPlayRecorder:(NSURL *)url {
    self.player = nil;
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)pause {
    [self.player pause];
}

#pragma mark - AVPlayerDelegate

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"status"]) {
        if (self.player.currentItem.status == AVPlayerStatusReadyToPlay) {
            NSLog(@"KVO:准备完毕，可以播放");
            [self.player play];
        } else {
            NSLog(@"KVO:失败");
            [self playerDidFinished:nil];
        }
    }
}

- (void)playerDidFinished:(NSNotification *)notice {
    NSLog(@"播放完毕");
    self.player = nil;
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    if (self.delegate && [self.delegate respondsToSelector:@selector(voiceDidPlayFinished)]) {
        [self.delegate voiceDidPlayFinished];
    }
}

- (void)playerDidFailed:(NSNotification *)notice {
     NSLog(@"播放失败");
}

- (void)playerDidStalled:(NSNotification *)notice {
     NSLog(@"播放异常中断");
}

- (void)dealloc {
    [self.player.currentItem removeObserver:self forKeyPath:@"status"];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
