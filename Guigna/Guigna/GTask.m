#import "GTask.h"

@implementation GTask

@synthesize item = _item;
@synthesize command;
@synthesize privileged;

- (id)initWithItem:(GItem *)item {
    self = [super init];
    if (self) {
        self.item = item;
    }
    return self;
}

- (GMark)mark {
    return self.item.mark;
}

- (GSystem *)system {
    return self.item.system;
}

@end
