//
//  ZYRecordBoxView.m
//  soundRecorder
//
//  Created by 张杨 on 2019/8/14.
//  Copyright © 2019年 张杨. All rights reserved.
//

#import "ZYRecordBoxView.h"

@interface ZYRecordBoxView()

/// 按住说话
@property (nonatomic, strong) UIButton *talkButton;
/// 用户是否取消发送消息
@property (nonatomic, assign) BOOL isCancelSendAudioMessage;

@end

@implementation ZYRecordBoxView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setBackgroundColor:HEXRGBCOLOR(0xE8EAED)];
        [self addSubview:self.talkButton];
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        longPress.minimumPressDuration = 0.1;
        [self.talkButton addGestureRecognizer:longPress];
    }
    return self;
}

- (void)longPress:(UILongPressGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        [self.talkButton setTitle:@"松开 结束" forState:UIControlStateNormal];
        [_talkButton setBackgroundColor:HEXRGBCOLOR(0xd1d1d1)];
        [self talkButtonDown:self.talkButton];
    } else if(gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [self.talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self.talkButton setBackgroundColor:HEXRGBCOLOR(0xFFFFFF)];
        /// 取消发送语音消息
        if (self.isCancelSendAudioMessage) {
            [self talkButtonUpOutside:self.talkButton];
        } else {
            [self talkButtonUpInside:self.talkButton];
        }
    } else if(gestureRecognizer.state == UIGestureRecognizerStateChanged) {
        if ([self.layer containsPoint:point]) {
            self.isCancelSendAudioMessage = NO;
            [self.talkButton setTitle:@"松开 结束" forState:UIControlStateNormal];
            [self talkButtonDragInside:self.talkButton];
        } else {
            self.isCancelSendAudioMessage = YES;
            [self.talkButton setTitle:@"松开 取消" forState:UIControlStateNormal];
            [self talkButtonDragOutside:self.talkButton];
        }
    } else if (gestureRecognizer.state == UIGestureRecognizerStateFailed) {
        NSLog(@"失败");
        [self.talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self.talkButton setBackgroundColor:HEXRGBCOLOR(0xFFFFFF)];
        [self talkButtonUpOutside:self.talkButton];
    } else if (gestureRecognizer.state == UIGestureRecognizerStateCancelled) {
        NSLog(@"取消");
        [self.talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [self.talkButton setBackgroundColor:HEXRGBCOLOR(0xFFFFFF)];
        [self talkButtonUpOutside:self.talkButton];
    }
}

- (void)talkButtonDown:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxDidStartRecordingVoice:)]) {
        [_delegate chatBoxDidStartRecordingVoice:self];
    }
}

- (void)talkButtonUpInside:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxDidStopRecordingVoice:)]) {
        [_delegate chatBoxDidStopRecordingVoice:self];
    }
}

- (void)talkButtonUpOutside:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(chatBoxDidCancelRecordingVoice:)]) {
        [_delegate chatBoxDidCancelRecordingVoice:self];
    }
}

- (void)talkButtonDragOutside:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(chatBoxDidDrag:)]) {
        [_delegate chatBoxDidDrag:NO];
    }
}

- (void)talkButtonDragInside:(UIButton *)sender {
    if ([_delegate respondsToSelector:@selector(chatBoxDidDrag:)]) {
        [_delegate chatBoxDidDrag:YES];
    }
}

- (void)talkButtonTouchCancel:(UIButton *)sender {
    
}

#pragma mark - Getter

- (UIButton *)talkButton {
    if (!_talkButton) {
        _talkButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width - 40, self.bounds.size.height - 20)];
        _talkButton.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        [_talkButton setTitle:@"按住 说话" forState:UIControlStateNormal];
        [_talkButton setBackgroundColor:HEXRGBCOLOR(0xFFFFFF)];
        [_talkButton setTitleColor:[UIColor colorWithRed:0.3 green:0.3 blue:0.3 alpha:1.0] forState:UIControlStateNormal];
        [_talkButton.titleLabel setFont:[UIFont boldSystemFontOfSize:15.0f]];
        [_talkButton.layer setMasksToBounds:YES];
        [_talkButton.layer setCornerRadius:4.0f];
        [_talkButton.layer setBorderWidth:0.5f];
        [_talkButton.layer setBorderColor:HEXRGBCOLOR(0xD7DBE3).CGColor];
    }
    return _talkButton;
}

@end
