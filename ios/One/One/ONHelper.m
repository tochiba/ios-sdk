#import "ONHelper.h"
#import "AFNetworking.h"

@implementation ONHelper

+ (void)createIcon:(UIImage *)image
        forSignals:(IRSignals*)signals
          completionHandler:(void (^)(NSHTTPURLResponse *, NSDictionary *, NSError *))completion {
    LOG_CURRENT_METHOD;

    NSURL *url = [NSURL URLWithString:ONURL_BASE];

    AFHTTPClient *httpClient = [[AFHTTPClient alloc] initWithBaseURL:url];
    NSMutableURLRequest *request = [httpClient multipartFormRequestWithMethod:@"POST"
                                                                         path:@"/apps/one/icons/"
                                                                   parameters:nil
                                                    constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
                                                        NSString *title = ((IRSignal*)[signals objectAtIndex:0]).name;
                                                        NSData *titleData = [NSData dataWithBytes:[title UTF8String]
                                                                                           length:[title lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
                                                        [formData appendPartWithFormData:titleData
                                                                                    name:@"title"];
                                                        [formData appendPartWithFileData:UIImagePNGRepresentation(image)
                                                                                    name:@"icon"
                                                                                fileName:@"icon.png"
                                                                                mimeType:@"image/png"];
                                                        NSString *json = signals.JSONRepresentation;
                                                        json           = [NSString stringWithFormat:@"irsignals=%@", json];
                                                        NSData *data = [NSData dataWithBytes:[json UTF8String]
                                                                                      length:[json lengthOfBytesUsingEncoding:NSUTF8StringEncoding]];
                                                        [formData appendPartWithFileData:data
                                                                                    name:@"query"
                                                                                fileName:@"query.json"
                                                                                mimeType:@"application/json"];
    }];

    AFJSONRequestOperation *operation =
    [AFJSONRequestOperation JSONRequestOperationWithRequest:request
                                                    success:^(NSURLRequest *req, NSHTTPURLResponse *res, id JSON) {
                                                        LOG(@"success");
                                                        completion(res, JSON, nil);
                                                    } failure:^(NSURLRequest *req, NSHTTPURLResponse *res, NSError *err, id JSON) {
                                                        LOG(@"failure");
                                                        completion(res, JSON, err);
                                                    }];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        LOG(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
    }];
    [httpClient enqueueHTTPRequestOperation:operation];
}

@end
