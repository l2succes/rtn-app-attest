#import "AppAttestSpec.h"
#import "RTNAppAttest.h"
#import <DeviceCheck/DCAppAttestService.h>

@implementation RTNAppAttest

RCT_EXPORT_MODULE(RTNAppAttest)

RCT_REMAP_METHOD(isSupported,
                withResolver:(RCTPromiseResolveBlock) resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
    if (@available(iOS 14.0, *)) {
        DCAppAttestService *appAttest = [DCAppAttestService sharedService];
        NSNumber *isSupported = [NSNumber numberWithBool:[appAttest isSupported]];
        resolve(isSupported);
    } else {
        // Fallback on earlier versions
        resolve(@NO);
    }
}

- (std::shared_ptr<facebook::react::TurboModule>)getTurboModule:
    (const facebook::react::ObjCTurboModule::InitParams &)params
{
    return std::make_shared<facebook::react::NativeCalculatorSpecJSI>(params);
}

@end
