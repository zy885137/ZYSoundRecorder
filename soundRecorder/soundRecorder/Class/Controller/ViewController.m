//
//  ViewController.m
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import "ViewController.h"
#import "ZYRecordBoxView.h"
#import "ZYVoiceHud.h"
#import "ZYRecordManager.h"

@interface ViewController () <ZYRecorderBoxViewDelegate,ZYRecordManagerDelegate>

@property (nonatomic, strong) ZYRecordBoxView *recordBoxView;

@property (nonatomic, strong) ZYVoiceHud *voiceHud;

@property (nonatomic, strong) NSTimer *voiceTimer;

@property (nonatomic, copy) NSString *recordName;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.recordBoxView];
}

#pragma mark - ZYRecorderBoxViewDelegate

/// 按住说话
- (void)chatBoxDidStartRecordingVoice:(ZYRecordBoxView *)chatBox {
    self.recordName = [self currentRecordFileName];
    ZYRecordManager *recordManager = [ZYRecordManager shareManager];
    recordManager.delegate = self;
    [[ZYRecordManager shareManager] startRecordingWithFileName:self.recordName completion:^(NSError *error) {
        if (!error) {
            [self voiceDidStartRecording];
        }
    }];
}

/// 松开结束
- (void)chatBoxDidStopRecordingVoice:(ZYRecordBoxView *)chatBox {
    [[ZYRecordManager shareManager] stopRecord];
}

/// 取消说话
- (void)chatBoxDidCancelRecordingVoice:(ZYRecordBoxView *)chatBox {
    [self voiceDidCancelRecording];
    [[ZYRecordManager shareManager] removeCurrentRecordFile:self.recordName];
}

/// 是否在按钮区域内
- (void)chatBoxDidDrag:(BOOL)inside {
    [self voiceWillDragout:inside];
}

#pragma mark - ZYRecordManagerDelegate

/// 录音结束 回调
- (void)recordDidFinishedWithRecordPath:(NSString *)recordPath duration:(NSTimeInterval)duration {
    if ([recordPath isEqualToString:shortRecord]) {
        [self voiceRecordSoShort];
        [[ZYRecordManager shareManager] removeCurrentRecordFile:self.recordName];
    } else {
        NSLog(@"需要发送语音");
        [self voiceDidCancelRecording];
    }
}

#pragma mark - 语音状态变化
/// 音量改变，更新UI
- (void)voiceProgressChange {
    CGFloat progress = (1.0/160)*([ZYRecordManager shareManager].power + 160);
    self.voiceHud.progress = progress;
}

/// 音频录制开始，更新UI
- (void)voiceDidStartRecording {
    [self timerInvalidate];
    self.voiceHud.image = nil;
    self.voiceHud.hidden = NO;
    [self voiceTimer];
}

/// 音频录制取消，更新UI
- (void)voiceDidCancelRecording {
    [self timerInvalidate];
    self.voiceHud.hidden = YES;
}

/// 手指移动位置，更新UI
- (void)voiceWillDragout:(BOOL)inside {
    if (inside) {
        [_voiceTimer setFireDate:[NSDate distantPast]];
        self.voiceHud.image = [UIImage imageNamed:@"voice_1"];
    } else {
        [_voiceTimer setFireDate:[NSDate distantFuture]];
        self.voiceHud.animationImages = nil;
        self.voiceHud.image = [UIImage imageNamed:@"cancelVoice"];
    }
}

/// 音频小于1s，更新UI
- (void)voiceRecordSoShort {
    [self timerInvalidate];
    self.voiceHud.animationImages = nil;
    self.voiceHud.image = [UIImage imageNamed:@"voiceShort"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        self.voiceHud.hidden = YES;
    });
}

#pragma mark - Private

- (void)timerInvalidate {
    if (_voiceTimer) {
        [_voiceTimer invalidate];
        _voiceTimer = nil;
    }
}

- (NSString *)currentRecordFileName {
    NSTimeInterval timeInterval = [[NSDate date] timeIntervalSince1970];
    NSString *fileName = [NSString stringWithFormat:@"%ld",(long)timeInterval];
    return fileName;
}

#pragma mark - Getter

- (ZYRecordBoxView *)recordBoxView {
    if (!_recordBoxView) {
        _recordBoxView = [[ZYRecordBoxView alloc] initWithFrame:CGRectMake(0, HEIGHT_SCREEN - 64 - TABBAR_SAFE_BOTTOM_MARGIN, WIDTH_SCREEN, 64)];
        _recordBoxView.delegate = self;
    }
    return _recordBoxView;
}

- (ZYVoiceHud *)voiceHud {
    if (!_voiceHud) {
        _voiceHud = [[ZYVoiceHud alloc] initWithFrame:CGRectMake(0, 0, 155, 155)];
        _voiceHud.center = CGPointMake(WIDTH_SCREEN/2, HEIGHT_SCREEN/2);
        _voiceHud.hidden = YES;
        [self.view addSubview:_voiceHud];
    }
    return _voiceHud;
}

- (NSTimer *)voiceTimer {
    if (!_voiceTimer) {
        _voiceTimer = [NSTimer scheduledTimerWithTimeInterval:0.3f target:self selector:@selector(voiceProgressChange) userInfo:nil repeats:YES];
    }
    return _voiceTimer;
}

@end
