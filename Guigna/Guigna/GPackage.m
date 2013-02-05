#import "GPackage.h"
#import "GSystem.h"

@implementation GPackage

@synthesize variants;
@synthesize markedVariants;


- (id)initWithName:(NSString *)name
           version:(NSString *)version
            system:(GSystem *)system
            status:(GStatus)status {
    self = [super initWithName:name
            version:version
            source:(GSource *)system
            status:status];
    self.system = system;
    return self;
}

- (NSString *)key {
    return [self.system keyForPackage:self];  
}

@end
