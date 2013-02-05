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
    for (id node in nodes) {
        NSString *name = [[[node nodesForXPath:@"./h2/a" error:nil] lastObject] stringValue];
        NSUInteger sep = [name rangeOfString:@" " options:NSBackwardsSearch].location;
        NSString *version = [name substringFromIndex:sep+1];
        name = [name substringToIndex:sep];
        NSString *ID = [[[[[node nodesForXPath:@"./h2/a" error:nil] lastObject] attributeForName:@"href"]stringValue] lastPathComponent];
        NSArray *moreinfo = [node nodesForXPath:@"./h2//a[contains(@class,\"moreinfo\")]" error:nil];
        NSString *homepage;
        if ([moreinfo count] == 0)
            homepage = self.homepage;
        else {
            homepage = [[moreinfo[0] attributeForName:@"title"] stringValue];
            NSInteger sep = [homepage rangeOfString:@" " options:NSBackwardsSearch].location;
            homepage = [homepage substringFromIndex:sep+1];
            if (![homepage hasPrefix:@"http://"])
                homepage = [@"http://" stringByAppendingString:homepage]; 
        }
        NSArray *taglist = [node nodesForXPath:@"./ul/li" error:nil];
        NSMutableArray *tags = [NSMutableArray array];
        for (id node in taglist) {
            [tags addObject:[node stringValue]];
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
