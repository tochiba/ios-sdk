#import "Log.h"
#import "IRPeripheral.h"
#import "IRKit.h"
#import "IRHelper.h"
#import "IRPeripheralWriteOperationQueue.h"
#import "IRPeripheralWriteOperation.h"
#import "IRConst.h"
#import "IRHTTPClient.h"
#import "Reachability.h"

@interface IRPeripheral ()

@property (nonatomic) IRPeripheralWriteOperationQueue *writeQueue;
@property (nonatomic) Reachability* reachability;

@end

@implementation IRPeripheral

- (id) init {
    LOG_CURRENT_METHOD;
    self = [super init];
    if ( ! self ) {
        return nil;
    }
    _writeQueue       = nil;

    _name             = nil;
    _customizedName   = nil;
    _foundDate        = [NSDate date];
    _clientkey        = nil;

    // from HTTP response Server header
    // eg: "Server: IRKit/1.3.0.73.ge6e8514"
    // "IRKit" is modelName
    // "1.3.0.73.ge6e8514" is version
    _modelName        = nil;
    _version          = nil;

    return self;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
}

- (BOOL)hasKey {
    return _clientkey ? YES : NO;
}

- (void)setName:(NSString *)name {
    LOG_CURRENT_METHOD;
    _name = name;

    [self startReachability];
}

- (NSString*) hostname {
    return [NSString stringWithFormat:@"%@.local", _name];
}

- (BOOL)isReachableViaWifi {
    return _reachability.isReachableViaWiFi;
}

- (void)getKeyWithCompletion:(void (^)())successfulCompletion {
    LOG_CURRENT_METHOD;

    [IRHTTPClient getKeyFromHost:_name withCompletion:^(NSHTTPURLResponse *res, NSString* key, NSError *err) {
        LOG( @"res: %@, key: %@, err: %@", res, key, err );
        if (key) {
            _clientkey = key;
            NSDictionary* hostInfo = [IRHTTPClient hostInfoFromResponse:res];
            if (hostInfo) {
                _modelName = hostInfo[ @"modelName" ];
                _version   = hostInfo[ @"version" ];
            }
            successfulCompletion();
        }
    }];
}

- (void)getModelNameAndVersionWithCompletion:(void (^)())successfulCompletion {
    LOG_CURRENT_METHOD;

    // GET /message only to see Server header
    [IRHTTPClient getMessageFromHost:_name
                      withCompletion:^(NSHTTPURLResponse *res, NSDictionary *message, NSError *error) {
                          NSDictionary* hostInfo = [IRHTTPClient hostInfoFromResponse:res];
                          if (hostInfo) {
                              _modelName = hostInfo[ @"modelName" ];
                              _version   = hostInfo[ @"version" ];
                          }
                          successfulCompletion();
                      }];
}

- (NSComparisonResult) compareByFirstFoundDate: (IRPeripheral*) otherPeripheral {
    return [self.foundDate compare: otherPeripheral.foundDate];
}

- (NSString*) modelNameAndRevision {
    LOG_CURRENT_METHOD;
    if ( ! _modelName || ! _version ) {
        return @"unknown";
    }
    return [@[_modelName, _version] componentsJoinedByString:@"/"];
}

- (NSString*)iconURL {
    return [NSString stringWithFormat:@"%@/static/images/model/%@.png", STATICENDPOINT_BASE, _modelName ? _modelName : @"IRKit" ];
}

- (NSDictionary*) asDictionary {
    return @{
             @"name":      _name      ? _name      : [NSNull null],
             @"foundDate": _foundDate ? [NSNumber numberWithDouble:[_foundDate timeIntervalSince1970]] : [NSNull null],
             @"clientkey": _clientkey ? _clientkey : [NSNull null],
             @"modelName": _modelName ? _modelName : [NSNull null],
             @"version":   _version   ? _version   : [NSNull null]
             };
}

#pragma mark - Private methods

- (void) startReachability {
    LOG_CURRENT_METHOD;

    if (_name) {
        if (_reachability) {
            [_reachability stopNotifier];
        }
        _reachability = [Reachability reachabilityWithHostname:self.hostname];
        // we start notifying but don't observe on notifications
        [_reachability startNotifier];
    }
}

#pragma mark - NSKeyedArchiving

- (void)encodeWithCoder:(NSCoder*)coder {
    [coder encodeObject:_name           forKey:@"name"];
    [coder encodeObject:_customizedName forKey:@"customizedName"];
    [coder encodeObject:_foundDate      forKey:@"foundDate"];
    [coder encodeObject:_clientkey      forKey:@"clientkey"];
    [coder encodeObject:_modelName      forKey:@"modelName"];
    [coder encodeObject:_version        forKey:@"version"];
}

- (id)initWithCoder:(NSCoder*)coder {
    LOG_CURRENT_METHOD;
    self = [self init];
    if (! self) {
        return nil;
    }
    _name             = [coder decodeObjectForKey:@"name"];
    _customizedName   = [coder decodeObjectForKey:@"customizedName"];
    _foundDate        = [coder decodeObjectForKey:@"foundDate"];
    _clientkey        = [coder decodeObjectForKey:@"clientkey"];
    _modelName        = [coder decodeObjectForKey:@"modelName"];
    _version          = [coder decodeObjectForKey:@"version"];

    [self startReachability];

    return self;
}

@end
