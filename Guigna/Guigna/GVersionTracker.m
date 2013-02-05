#import "GVersionTracker.h"

@implementation GVersionTracker

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"VersionTracker";
        self.homepage = @"http://download.cnet.com/new-mac-software/";
        self.pageNumber = 1;
        self.itemsPerPage = 50;
        self.agent = agent;
        self.cmd = @"versiontracker";
    }
    return self;
}

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = [NSString stringWithFormat:@"http://download.cnet.com/mac/3151-20_4-0-%ld.html", self.pageNumber];
    NSArray *nodes = [self.agent nodesForURL:url XPath:@"//ul[@class=\"prodListings\"]/li"];
    for (id node in nodes) {
        NSString *name = [[node nodesForXPath:@".//div[@class=\"title\"]/a" error:nil][0] stringValue];
        NSUInteger sep = [name rangeOfString:@" " options:NSBackwardsSearch].location;
        NSString *version = [name substringFromIndex:sep+1];
        name = [name substringToIndex:sep];
        NSString *ID = [[[node nodesForXPath:@".//div[@class=\"title\"]/a" error:nil][0] attributeForName:@"href"] stringValue];
        NSString *category = [[node nodesForXPath:@".//div[@class=\"title\"]/p/a" error:nil][0] stringValue]; 
        NSString *description = [[node nodesForXPath:@".//div[@class=\"license\"]" error:nil][0] stringValue];
        NSString *homepage = [[[node nodesForXPath:@".//div[@class=\"infoPopup\"]//li/a" error:nil][0] attributeForName:@"href"] stringValue];
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.ID = ID;
        item.homepage = homepage;
        item.categories = category;
        item.description = description;
        [items addObject:item];
    }
    return items;
}

- (NSString *)home:(GItem *)item {
    return item.homepage;
}

- (NSString *)log:(GItem *)item {
    return [NSString stringWithFormat:@"http://download.cnet.com%@", item.ID];
}
@end
