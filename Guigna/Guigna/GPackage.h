#import "GItem.h"

@interface GPackage : GItem

@property(strong, atomic) NSString *variants;
@property(strong, atomic) NSString *markedVariants;

- (id)initWithName:(NSString *)name
           version:(NSString *)version
            system:(GSystem *)system
            status:(GStatus)status;
- (NSString *) key;

@end
