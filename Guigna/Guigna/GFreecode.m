#import "GFreecode.h"

@implementation GFreecode

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"Freecode";
        self.homepage = @"http://freecode.com/";
        self.pageNumber = 1;
        self.itemsPerPage = 25;
        self.agent = agent;
        self.cmd = @"freecode";
    }
    return self;
}

// TODO: 

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = [NSString stringWithFormat:@"http://freecode.com/?page=%ld", self.pageNumber];
    NSArray *nodes = [self.agent nodesForURL:url XPath:@"//div[contains(@class,\"release\")]"];
    for (id node0 in nodes) {
        NSString *name = [[[node0 nodesForXPath:@"./h2/a" error:nil] lastObject] stringValue];
        NSUInteger sep0 = [name rangeOfString:@" " options:NSBackwardsSearch].location;
        NSString *version = [name substringFromIndex:sep0+1];
        name = [name substringToIndex:sep0];
        NSString *ID = [[[[[node0 nodesForXPath:@"./h2/a" error:nil] lastObject] attributeForName:@"href"]stringValue] lastPathComponent];
        NSArray *moreinfo = [node0 nodesForXPath:@"./h2//a[contains(@class,\"moreinfo\")]" error:nil];
        NSString *homepage;
        if ([moreinfo count] == 0) {
            homepage = self.homepage;
        } else {
            homepage = [[moreinfo[0] attributeForName:@"title"] stringValue];
            NSUInteger sep1 = [homepage rangeOfString:@" " options:NSBackwardsSearch].location;
            homepage = [homepage substringFromIndex:sep1+1];
            if (![homepage hasPrefix:@"http://"])
                homepage = [@"http://" stringByAppendingString:homepage]; 
        }
        NSArray *taglist = [node0 nodesForXPath:@"./ul/li" error:nil];
        NSMutableArray *tags = [NSMutableArray array];
        for (id node1 in taglist) {
            [tags addObject:[node1 stringValue]];
        }
        // NSString *category = 
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.ID = ID;
        item.description = [tags componentsJoinedByString:@" "];
        item.homepage = homepage;
        [items addObject:item];
    }
    return items;
}

// TODO: parse log page
- (NSString *)home:(GItem *)item {
    return item.homepage;
}

- (NSString *)log:(GItem *)item {
    return [NSString stringWithFormat:@"http://freecode.com/projects/%@", item.ID];
}

@end
