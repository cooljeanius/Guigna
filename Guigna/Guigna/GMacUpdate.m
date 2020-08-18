#import "GMacUpdate.h"

@implementation GMacUpdate

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"MacUpdate";
        self.homepage = @"http://www.macupdate.com";
        self.pageNumber = 1;
        self.itemsPerPage = 40;
        self.agent = agent;
        self.cmd = @"macupdate";
    }
    return self;
}

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = [NSString stringWithFormat:@"http://www.macupdate.com/explore/mac/recent/%ld", (self.pageNumber-1)*40];
    NSArray *nodes = [self.agent nodesForURL:url XPath:@"//div[@class=\"appinfo\"]"];
    for (id node in nodes) {
        NSString *name = [[node nodesForXPath:@"a" error:nil][0] stringValue];
        NSUInteger sep = [name rangeOfString:@" " options:NSBackwardsSearch].location;
        NSString *version = @"";
        if (sep != NSNotFound) {
            version = [name substringFromIndex:sep+1];
            name = [name substringToIndex:sep];
        }
        NSString *description = [[[node nodesForXPath:@"span" error:nil][0] stringValue] substringFromIndex:2];
        NSString *ID = [[[node nodesForXPath:@"a" error:nil][0] attributeForName:@"href"] stringValue];
        ID = [ID componentsSeparatedByString:@"/"][3];
        // NSString *category = 
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.ID = ID;
        // item.categories = category;
        item.description = description;
        [items addObject:item];
    }
    return items;    
}

- (NSString *)home:(GItem *)item {
    NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat:@"http://www.macupdate.com/app/mac/%@", item.ID] XPath:@"//ul[@id=\"infodl\"]/li/a[@target=\"devsite\"]"];
    // Old:
    // NSString *home = [[[[[[nodes objectAtIndex:0] attributeForName:@"href"] stringValue] componentsSeparatedByString:@"/"] objectAtIndex:3] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    // TODO: redirect
    NSString *home = [NSString stringWithFormat:@"http://www.macupdate.com%@", [[[nodes[0] attributeForName:@"href"] stringValue] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    return home;
}

- (NSString *)log:(GItem *)item {
    return [NSString stringWithFormat:@"http://www.macupdate.com/app/mac/%@", item.ID];
}

@end
