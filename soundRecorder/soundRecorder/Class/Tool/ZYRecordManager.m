//
//  ZYRecordManager.m
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import "ZYRecordManager.h"
#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "ZYFileTool.h"

#define kRecoderPath        @"Chat/Recoder"
#define kMinRecordDuration  1.0

@interface ZYRecordManager() <AVAudioRecorderDelegate>

@property (nonatomic, strong) AVAudioRecorder *recorder;
@property (nonatomic, strong) NSDate *startDate;
@property (nonatomic, strong) NSDate *endDate;
@property (nonatomic, strong) NSDictionary *recordSetting;

@end

@implementation ZYRecordManager

+ (instancetype)shareManager {
    static ZYRecordManager *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[ZYRecordManager alloc] init];
    });
    return _instance;
}

- (void)startRecordingWithFileName:(NSString *)fileName completion:(void(^)(NSError *error))completion {

    if (![self canRecord]) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"无法录音" message:@"请在iPhone的“设置-隐私-麦克风”选项中，允许访问你的手机麦克风。" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:([UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        }])];
        [[[UIApplication sharedApplication] delegate].window.rootViewController presentViewController:alertController animated:YES completion:nil];
        if (completion) {
            completion([NSError errorWithDomain:NSLocalizedString(@"error", @"麦克风未授权") code:1001 userInfo:nil]);
        }
        return;
    }
    if ([self.recorder isRecording]) {
        [self cancelCurrentRecording];
        if (completion) {
            completion([NSError errorWithDomain:NSLocalizedString(@"error", @"正在录制") code:1002 userInfo:nil]);
        }
        return;
    }
    else
    {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
        NSString *filePath = [self recorderPathWithFileName:fileName];
        NSError *error;
        self.recorder = [[AVAudioRecorder alloc] initWithURL:[[NSURL alloc] initFileURLWithPath:filePath] settings:self.recordSetting error:&error];
        if (!self.recorder || error) {
            self.recorder = nil;
            if (completion) {
                error = [NSError errorWithDomain:NSLocalizedString(@"error.initRecorderFail", @"Failed to initialize AVAudioRecorder") code:1003 userInfo:nil];
                completion(error);
            }
            return;
        }
        self.startDate = [NSDate date];
        self.recorder.delegate = self;
        self.recorder.meteringEnabled = YES;
        [self.recorder recordForDuration:60.0];
        [self.recorder record];
        if (completion) {
            completion(nil);
        }
    }
}

// 终止录制
- (void)stopRecord {
    _endDate = [NSDate date];
    if ([_recorder isRecording]) {
        NSTimeInterval duration = [_endDate timeIntervalSinceDate:_startDate];
        if (duration < kMinRecordDuration) {
            if (self.delegate && [self.delegate respondsToSelector:@selector(recordDidFinishedWithRecordPath:duration:)]) {
                [self.delegate recordDidFinishedWithRecordPath:shortRecord duration:duration];
            }
            [self cancelCurrentRecording];
            NSLog(@"录音时间太短");
            return;
        }
        [self.recorder stop];
        NSLog(@"录音时长 :%f",duration);
    }
}

- (void)cancelCurrentRecording {
    if ([_recorder isRecording]) {
        [_recorder stop];
    }
    _recorder.delegate = nil;
    _recorder = nil;
}

- (void)removeCurrentRecordFile:(NSString *)fileName {
    [self cancelCurrentRecording];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *path = [self recorderPathWithFileName:fileName];
    BOOL isDirExist = [fileManager fileExistsAtPath:path];
    if (isDirExist) {
        [fileManager removeItemAtPath:path error:nil];
    }
}

- (float)power {
    [self.recorder updateMeters];
    //取得第一个通道的音频，注意音频强度范围时-160到0,声音越大power绝对值越小
    float power = [self.recorder averagePowerForChannel:0];
    return power;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag {
    NSString *recordPath = [[self.recorder url] path];
    if (!flag) {
        recordPath = nil;
    }
    _endDate = [NSDate date];
    NSTimeInterval duration = [_endDate timeIntervalSinceDate:_startDate];
    if (duration > 60.0) {
        duration = 60.0;
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(recordDidFinishedWithRecordPath:duration:)]) {
        [self.delegate recordDidFinishedWithRecordPath:recordPath duration:duration];
    }
    [self cancelCurrentRecording];
    // 录制完成 继续后台播放
    [[AVAudioSession sharedInstance] setActive:NO withOptions:AVAudioSessionSetActiveOptionNotifyOthersOnDeactivation error:nil];
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error {
    NSLog(@"audioRecorderEncodeErrorDidOccur");
}

#pragma mark - Private

- (BOOL)canRecord {
    __block BOOL bCanRecord = YES;
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    if ([audioSession respondsToSelector:@selector(requestRecordPermission:)]) {
        [audioSession performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            bCanRecord = granted;
        }];
    }
    return bCanRecord;
}
            
- (NSString *)recorderPathWithFileName:(NSString *)fileName {
    return [[ZYFileTool createPathWithChildPath:kRecoderPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.wav",fileName]];
}

#pragma mark - Getter

- (NSDictionary *)recordSetting
{
    if (!_recordSetting) {
        _recordSetting = [[NSDictionary alloc] initWithObjectsAndKeys:
                          [NSNumber numberWithFloat:8000],AVSampleRateKey, //采样率
                          [NSNumber numberWithInt:kAudioFormatLinearPCM],AVFormatIDKey,
                          [NSNumber numberWithInt:16],AVLinearPCMBitDepthKey,//采样位数 默认 16
                          [NSNumber numberWithInt:2], AVNumberOfChannelsKey,//通道的数目
                          nil];
    }
    return _recordSetting;
}

@end
