#import "Log.h"
#import "IRPeripheralCell.h"
#import "IRHelper.h"
#import <QuartzCore/QuartzCore.h>

@interface IRPeripheralCell ()

@end

@implementation IRPeripheralCell

- (void)awakeFromNib {
    LOG_CURRENT_METHOD;
    [super awakeFromNib];

    self.iconView.layer.cornerRadius = 6.;
    self.iconView.layer.masksToBounds = YES;
}

- (void)dealloc {
    LOG_CURRENT_METHOD;
    [_peripheral removeObserver:self
                     forKeyPath:@"peripheral"];
}

- (void)setPeripheral:(IRPeripheral *)peripheral {
    LOG( @"peripheral: %@", peripheral);

    _peripheral = peripheral;
    
    self.nameLabel.text = peripheral.customizedName;
    self.detailLabel.text = peripheral.modelNameAndRevision;

    // load image from internet
    NSString *url = _peripheral.iconURL;
    [IRHelper loadImage:url completionHandler:^(NSHTTPURLResponse *response, UIImage *image, NSError *error) {
        if (error || (response.statusCode != 200) || ! image) {
            return;
        }
        self.iconView.image = image;
    }];

    [_peripheral addObserver:self
                  forKeyPath:@"peripheral"
                     options:NSKeyValueObservingOptionNew|NSKeyValueObservingOptionOld
                     context:NULL];
}

+ (CGFloat)height {
    return 58;
}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    LOG( @"keyPath: %@", keyPath );

    dispatch_async(dispatch_get_main_queue(), ^{
        self.nameLabel.text = _peripheral.customizedName;
        self.detailLabel.text = _peripheral.modelNameAndRevision;
        [self setNeedsDisplay];
    });
}

@end