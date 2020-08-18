#import "GMacPortsOrg.h"

@implementation GMacPortsOrg

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"MacPorts.org";
        self.homepage = @"https//build.macports.org/console";
        self.pageNumber = 1;
        self.itemsPerPage = 250;
        self.agent = agent;
        self.cmd = @"port";
    }
    return self;
}

// TODO:

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = @"http://packages.macports.org/?C=M;O=D";
    NSMutableArray *nodes = [NSMutableArray arrayWithArray:[self.agent nodesForURL:url XPath:@"//tr/td[2]/a"]];
    for (id node in nodes) {
        NSString *name = [[node attributeForName:@"href"] stringValue];
        name = [name substringToIndex:[name length]-1];
        NSString *version = @""; 
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.homepage = [NSString stringWithFormat:@"http://packages.macports.org/%@", item.name];
        [items addObject:item];
    }
    return items;    
}

// TODO:
- (NSString *)log:(GItem *)item {
    return @"http://build.macports.org/console";
}

@end
