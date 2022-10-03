#import "AppAttestSpec.h"
#import "RTNAppAttest.h"
#import <DeviceCheck/DeviceCheck.h>
#import <CommonCrypto/CommonDigest.h>

typedef void (^FailureHandleBlock)(NSString *errorDescription); // Rejector wrapper - RN does not support multiple callback invocations


@implementation RTNAppAttest

RCT_EXPORT_MODULE(RTNAppAttest)

- (NSData *)doSha256:(NSData *)dataIn {
    NSMutableData *macOut = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(dataIn.bytes, (CC_LONG)dataIn.length, (unsigned char *)macOut.mutableBytes);
    return macOut;
}

RCT_REMAP_METHOD(isSupported,
                withResolver:(RCTPromiseResolveBlock) resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
    FailureHandleBlock failureHandle = ^void(NSString *errorDescription) {
      reject(nil, [NSString stringWithFormat:@"%@ (DeviceCheck API unsupported in simulator)", errorDescription], nil);
    };
    
    if (@available(iOS 14.0, *)) {
        DCAppAttestService *appAttest = [DCAppAttestService sharedService];
        NSNumber *isSupported = [NSNumber numberWithBool:[appAttest isSupported]];
        resolve(isSupported);
    } else {
        // Fallback on earlier versions
        failureHandle(@"Platform uncompatible");
    }
}

RCT_REMAP_METHOD(generateKey,
                generateKeyWithResolver:(RCTPromiseResolveBlock) resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
    FailureHandleBlock failureHandle = ^void(NSString *errorDescription) {
      reject(nil, [NSString stringWithFormat:@"%@ (App Attest: key generation unsuccessful)", errorDescription], nil);
    };
    
    if (@available(iOS 14.0, *)) {
        DCAppAttestService *appAttest = [DCAppAttestService sharedService];
        [appAttest generateKeyWithCompletionHandler:^(NSString * _Nullable keyId, NSError * _Nullable error) {
            if (error) {
                failureHandle(error.localizedDescription);
            } else {
                resolve(keyId);
            }
        }];
    } else {
        failureHandle(@"Platform incompatible");
    }
}

RCT_REMAP_METHOD(attestKey,
                withKeyId:(NSString *)keyId
                withClientDataHash:(NSString *)clientDataHash
                withResolver:(RCTPromiseResolveBlock) resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
    FailureHandleBlock failureHandle = ^void(NSString *errorDescription) {
      reject(nil, [NSString stringWithFormat:@"%@ (App Attest: key attestation unsuccessful)", errorDescription], nil);
    };
    
    
    if (@available(iOS 14.0, *)) {
        DCAppAttestService *appAttest = [DCAppAttestService sharedService];
        NSData *hash = [self doSha256:[clientDataHash dataUsingEncoding:NSUTF8StringEncoding]];
        
        [appAttest attestKey:keyId clientDataHash:hash completionHandler:^(NSData * _Nullable attestationObject, NSError * _Nullable error) {
            if (error) {
                failureHandle(error.localizedDescription);
            } else {
                resolve([attestationObject base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]);
            }
        }];
    } else {
        failureHandle(@"Platform incompatible");
    }
}

RCT_REMAP_METHOD(generateAssertion,
                generateAssertionWithKeyId:(NSString *)keyId
                withClientDataHash:(NSString *)clientDataHash
                withResolver:(RCTPromiseResolveBlock) resolve
                withRejecter:(RCTPromiseRejectBlock) reject)
{
    FailureHandleBlock failureHandle = ^void(NSString *errorDescription) {
      reject(nil, [NSString stringWithFormat:@"%@ (App Attest: key attestation unsuccessful)", errorDescription], nil);
    };
    
    
    if (@available(iOS 14.0, *)) {
        DCAppAttestService *appAttest = [DCAppAttestService sharedService];
        NSData *hash = [self doSha256:[clientDataHash dataUsingEncoding:NSUTF8StringEncoding]];

        [appAttest generateAssertion:keyId clientDataHash:hash completionHandler:^(NSData * _Nullable attestationObject, NSError * _Nullable error) {
            if (error) {
                failureHandle(error.localizedDescription);
            } else {
                resolve(attestationObject);
            }
        }];
    } else {
        failureHandle(@"Platform incompatible");
    }
}




@end
