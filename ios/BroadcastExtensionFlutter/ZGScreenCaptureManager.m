//
//  ZGScreenCaptureManager.m
//  ZegoExpressExample-iOS-OC-Broadcast
//
//  Created by Patrick Fu on 2020/9/21.
//  Copyright © 2020 Zego. All rights reserved.
//

#import "ZGScreenCaptureManager.h"
#import <ZegoExpressEngine/ZegoExpressEngine.h>

static ZGScreenCaptureManager *_sharedManager = nil;

@interface ZGScreenCaptureManager ()<ZegoEventHandler>

@property (nonatomic, copy) NSString *appGroup;
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@property (nonatomic, weak) RPBroadcastSampleHandler *sampleHandler;

// Parameters synchronized from the main App process

// for [createEngine]
@property (nonatomic, assign) unsigned int appID;
@property (nonatomic, copy) NSString *appSign;
@property (nonatomic, assign) BOOL isTestEnv;
@property (nonatomic, assign) ZegoScenario scenario;

// for [setVideoConfig]
@property (nonatomic, assign) float videoSizeWidth;
@property (nonatomic, assign) float videoSizeHeight;
@property (nonatomic, assign) int videoFPS;
@property (nonatomic, assign) int videoBitrate;

// for [loginRoom]
@property (nonatomic, copy) NSString *roomID;
@property (nonatomic, copy) NSString *userID;
@property (nonatomic, copy) NSString *userName;

// for [startPublishingStream]
@property (nonatomic, copy) NSString *streamID;

// for demo
@property (nonatomic, assign) BOOL onlyCaptureVideo;

@end


@implementation ZGScreenCaptureManager

+ (instancetype)sharedManager {
    if (!_sharedManager) {
        @synchronized (self) {
            if (!_sharedManager) {
                _sharedManager = [[self alloc] init];
            }
        }
    }
    return _sharedManager;
}

- (void)startBroadcastWithAppGroup:(NSString *)appGroup sampleHandler:(RPBroadcastSampleHandler *)sampleHandler {
    self.sampleHandler = sampleHandler;
    self.appGroup = appGroup;
    self.userDefaults = [[NSUserDefaults alloc] initWithSuiteName:_appGroup];

    // Add an observer for stop broadcast notification
    CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                    (__bridge const void *)(self),
                                    onBroadcastFinish,
                                    (CFStringRef)@"ZGFinishReplayKitBroadcastNotificationName",
                                    NULL,
                                    CFNotificationSuspensionBehaviorDeliverImmediately);

    [self syncParametersFromMainAppProcess];

    [self setEngineConfig];
    [self setupEngine];
    [self setVideoConfig];
    [self loginRoom];
    [self startPublish];
}

- (void)stopBroadcast:(void(^_Nullable)(void))completion {
    [[ZegoExpressEngine sharedEngine] stopPublishingStream];
    [[ZegoExpressEngine sharedEngine] logoutRoom:self.roomID];
    [ZegoExpressEngine destroyEngine:^{
        if (completion) {
            completion();
        }
    }];

    // Remove observer for stop broadcast notification
    CFNotificationCenterRemoveObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                       (__bridge const void *)(self),
                                       (CFStringRef)@"ZGFinishReplayKitBroadcastNotificationName",
                                       NULL);
}

- (void)handleSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {

    if (self.onlyCaptureVideo && sampleBufferType != RPSampleBufferTypeVideo) {
        // Skip audio buffer
        return;
    }

    [[ZegoExpressEngine sharedEngine] handleReplayKitSampleBuffer:sampleBuffer bufferType:sampleBufferType];
}


#pragma mark - Private methods

// Handle stop broadcast notification from main app process
static void onBroadcastFinish(CFNotificationCenterRef center, void *observer, CFStringRef name, const void *object, CFDictionaryRef userInfo) {

    // Stop broadcast
    [[ZGScreenCaptureManager sharedManager] stopBroadcast:^{
        RPBroadcastSampleHandler *handler = [ZGScreenCaptureManager sharedManager].sampleHandler;
        if (handler) {
            // Finish broadcast extension process
            [handler finishBroadcastWithError:[[NSError alloc] initWithDomain:NSCocoaErrorDomain code:0 userInfo:nil]];
        } else {
            NSLog(@"⚠️ RPBroadcastSampleHandler is null, can not stop broadcast upload extension process");
        }
    }];
}

// Set some config for engine
- (void)setEngineConfig {

    // Set ZEGO log directory with AppGroup
    NSURL *logDirURL = [[[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:self.appGroup] URLByAppendingPathComponent:@"ZegoLogsReplayKit" isDirectory:YES];
    if (![[NSFileManager defaultManager] fileExistsAtPath:logDirURL.path]) {
        [[NSFileManager defaultManager] createDirectoryAtURL:logDirURL withIntermediateDirectories:YES attributes:nil error:nil];
    }

    ZegoLogConfig *logConfig = [[ZegoLogConfig alloc] init];
    logConfig.logPath = logDirURL.path;

    ZegoEngineConfig *engineConfig = [[ZegoEngineConfig alloc] init];
    engineConfig.logConfig = logConfig;

    // Set some optimization options to reduce memory usage when publishing stream
    engineConfig.advancedConfig = @{
        @"replaykit_handle_rotation": @"false", // Specify not to process the screen rotation on the publisher side, but to process it on the player side, thereby reduce memory usage, but in this case, the player must not play this stream from the CDN but directly from the ZEGO server. If you need to play this stream from the CDN and the captured screen needs to be dynamically rotated, please comment this line of code.

        @"max_channels": @"0",                  // Specify the max number of streams to play as 0  (Because this extension only needs to publish stream)
        @"max_publish_channels": @"1"           // Specify the max number of streams to publish as 1
    };

    [ZegoExpressEngine setEngineConfig:engineConfig];
}

- (void)setupEngine {

    // Create engine
    [ZegoExpressEngine createEngineWithAppID:self.appID appSign:self.appSign isTestEnv:self.isTestEnv scenario:self.scenario eventHandler:self];

    // Init SDK ReplayKit module
    [[ZegoExpressEngine sharedEngine] prepareForReplayKit];

    // Enable hardware encoder to reduce memory usage when publishing stream
    [[ZegoExpressEngine sharedEngine] enableHardwareEncoder:YES];

}

- (void)setVideoConfig {

    // Set video config
    ZegoVideoConfig *videoConfig = [[ZegoVideoConfig alloc] init];
    videoConfig.captureResolution = CGSizeMake(self.videoSizeWidth, self.videoSizeHeight);
    videoConfig.encodeResolution = videoConfig.captureResolution;
    videoConfig.fps = self.videoFPS;
    videoConfig.bitrate = self.videoBitrate;
    [[ZegoExpressEngine sharedEngine] setVideoConfig:videoConfig];
}

- (void)loginRoom {
    [[ZegoExpressEngine sharedEngine] loginRoom:self.roomID user:[ZegoUser userWithUserID:self.userID userName:self.userName]];
}

- (void)startPublish {
    [[ZegoExpressEngine sharedEngine] startPublishingStream:self.streamID];
}

#pragma mark Helper

- (void)syncParametersFromMainAppProcess {

    // Get parameters for [createEngine]
    self.appID = [(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_APP_ID"] unsignedIntValue];
    self.appSign = (NSString *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_APP_SIGN"];
    self.isTestEnv = [(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_IS_TEST_ENV"] boolValue];
    self.scenario = (ZegoScenario)[(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_SCENARIO"] intValue];

    // Get parameters for [setVideoConfig]
    self.videoSizeWidth = [(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_VIDEO_SIZE_WIDTH"] floatValue];
    self.videoSizeHeight = [(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_VIDEO_SIZE_HEIGHT"] floatValue];
    self.videoFPS = [(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_SCREEN_CAPTURE_VIDEO_FPS"] intValue];
    self.videoBitrate = [(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_SCREEN_CAPTURE_VIDEO_BITRATE_KBPS"] intValue];

    // Get parameters for [loginRoom]
    self.userID = [self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_USER_ID"];
    self.userName = [self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_USER_NAME"];
    self.roomID = [self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_ROOM_ID"];

    // Get parameters for [startPublishingStream]
    self.streamID = [self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_STREAM_ID"];

    // Get parameters for demo
    self.onlyCaptureVideo = [(NSNumber *)[self.userDefaults valueForKey:@"ZG_SCREEN_CAPTURE_ONLY_CAPTURE_VIDEO"] boolValue];
}

#pragma mark - Zego Express Event Handler

- (void)onRoomStateUpdate:(ZegoRoomState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData roomID:(NSString *)roomID {
    NSLog(@"🚩 🚪 Room State Update, state: %d, errorCode: %d, roomID: %@", (int)state, (int)errorCode, roomID);
}

- (void)onPublisherStateUpdate:(ZegoPublisherState)state errorCode:(int)errorCode extendedData:(NSDictionary *)extendedData streamID:(NSString *)streamID {
    NSLog(@"🚩 📤 Publisher State Update, state: %d, errorCode: %d, streamID: %@", (int)state, (int)errorCode, streamID);
}

- (void)onPublisherVideoSizeChanged:(CGSize)size channel:(ZegoPublishChannel)channel {
    NSLog(@"🚩 📐 Publisher Video Size Changed, width: %.f, height: %.f", size.width, size.height);
}

- (void)onPublisherQualityUpdate:(ZegoPublishStreamQuality *)quality streamID:(NSString *)streamID {
    NSLog(@"🚩 📈 Publisher Quality Update, fps:%.2f, bitrate:%.2f, level:%d, streamID: %@", quality.videoSendFPS, quality.videoKBPS, (int)quality.level, streamID);
}

@end
