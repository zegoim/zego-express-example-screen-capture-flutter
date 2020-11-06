//
//  SampleHandler.m
//  BroadcastExtensionFlutter
//
//  Created by Patrick Fu on 2020/10/26.
//

#import "SampleHandler.h"
#import "ZGScreenCaptureManager.h"

@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.

    // Note:
    // If you want to experience this feature, please click the [Runner] project in the project
    // navigator on the left of Xcode, find the [App Groups] column in the [Signing & Capabilities] tab of
    // both Target [Runner] and [BroadcastExtensionFlutter], click the `+` to add a custom
    // App Group ID and enable it; then fill in this App Group ID to below
    //
    // This demo has encapsulated the logic of calling the ZegoExpressEngine SDK in the [ZGScreenCaptureManager] class.
    // Please refer to it to implement [SampleHandler] class in your own project
    //
    //
    // 注意：
    // 若需要体验此功能，请点击 Xcode 左侧项目导航栏中的 [Runner] 工程项目，
    // 找到 Target [Runner] 以及 [BroadcastExtensionFlutter] 的
    // [Signing & Capabilities] 选项中的 App Groups 栏目，点击 `+` 号添加一个您自定义的 App Group ID 并启用；
    // 然后将此 ID 填写到下面替换
    //
    // 本 Demo 已将调用 ZegoExpressEngine SDK 的逻辑都封装在了 [ZGScreenCaptureManager] 类中
    // 请参考该类以在您自己的项目中实现 [SampleHandler]
    [[ZGScreenCaptureManager sharedManager] startBroadcastWithAppGroup:@"group.im.zego.express" sampleHandler:self];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
    [[ZGScreenCaptureManager sharedManager] stopBroadcast:nil];
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    [[ZGScreenCaptureManager sharedManager] handleSampleBuffer:sampleBuffer withType:sampleBufferType];
}

@end
