#import "GPkgsrcSE.h"

@implementation GPkgsrcSE

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"Pkgsrc.se";
        self.homepage = @"http://pkgsrc.se/";
        self.pageNumber = 1;
        self.itemsPerPage = 15;
        self.agent = agent;
        self.cmd = @"pkgsrc";
    }
    return self;
}

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = [NSString stringWithFormat:@"http://pkgsrc.se/?page=%ld", self.pageNumber];
    id root = [self.agent nodesForURL:url XPath:@"//div[@id=\"main\"]"][0];
    NSArray *dates = [root nodesForXPath:@"./h3" error:nil];
    NSMutableArray *names = [NSMutableArray arrayWithArray:[root nodesForXPath:@"./b" error:nil]];
    [names removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)]];
    NSMutableArray *comments = [NSMutableArray arrayWithArray:[root nodesForXPath:@"./div" error:nil]];
    [comments removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0,2)]];
    
    int i = 0;
    for (id node in names) {
        NSString *ID = [[node nodesForXPath:@"./a" error:nil][0] stringValue];
        NSInteger sep = [ID rangeOfString:@"/" options:NSBackwardsSearch].location;
        NSString *name = [ID substringFromIndex:sep+1];
        NSString *category = [ID substringToIndex:sep];
        NSString *version = [dates[i] stringValue];
        sep = [version rangeOfString:@" ("].location;
        if (sep != NSNotFound) {
            version = [version substringFromIndex:sep+2];
            version = [version substringToIndex:([version rangeOfString:@")"].location)];
        } else {
            version = [[version componentsSeparatedByString:@" "] lastObject];
        }
        NSString *description = [comments[i] stringValue];
        description = [description substringToIndex:([description rangeOfString:@"\n"].location)];
        description = [description substringFromIndex:([description rangeOfString:@": "].location)+2];
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.ID = ID;
        item.description = description;
        item.categories = category;
        [items addObject:item];
        i++;
    }
    return items;
}

- (NSString *)home:(GItem *)item {
    NSArray *links = [self.agent nodesForURL:[NSString stringWithFormat:@"http://pkgsrc.se/%@", item.ID] XPath:@"//div[@id=\"main\"]//a"];
    NSString *home = [[links[2] attributeForName:@"href"] stringValue];
    return home;
}

- (NSString *)log:(GItem *)item {
    return [NSString stringWithFormat:@"http://pkgsrc.se/%@", item.ID];
}

@end
