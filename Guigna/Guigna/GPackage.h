#import "GItem.h"

@interface GPackage : GItem

@property(strong) NSString *variants;
@property(strong) NSString *markedVariants;

- (id)initWithName:(NSString *)name
           version:(NSString *)version
            system:(GSystem *)system
            status:(GStatus)status;
- (NSString *) key;

@end
