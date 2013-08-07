#import <UIKit/UIKit.h>
#import "IRPeripheral.h"

@interface IRPeripheralCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;
+ (CGFloat)height;

@property (nonatomic, strong) IRPeripheral *peripheral;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *detailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *iconView;

@end
