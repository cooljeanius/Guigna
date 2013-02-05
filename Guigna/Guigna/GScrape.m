#import "GScrape.h"

@implementation GScrape

@synthesize pageNumber;
@synthesize itemsPerPage;

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    self.pageNumber = 1;
    return self;
}

@end
