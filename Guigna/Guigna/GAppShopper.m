#import "GAppShopper.h"

@implementation GAppShopper

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"AppShopper";
        self.homepage = @"http://appshopper.com/mac/all/";
        self.pageNumber = 1;
        self.itemsPerPage = 20;
        self.agent = agent;
        self.cmd = @"appstore";
    }
    return self;
}

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = [NSString stringWithFormat:@"http://appshopper.com/mac/all/%ld", self.pageNumber];
    NSArray *nodes =[self.agent nodesForURL:url XPath:@"//ul[@class=\"appdetails\"]/li"];
    for (id node in nodes) {
        NSString *name = [[node nodesForXPath:@"h3/a" error:nil][0] stringValue];
        NSString *version = [[node nodesForXPath:@".//dd" error:nil][2] stringValue];
        version = [version substringToIndex:[version length]-1]; // trim final \n
        NSString *ID = [[[node attributeForName:@"id"] stringValue] substringFromIndex:4];
        NSString *nick = [[[[node nodesForXPath:@"a" error:nil][0] attributeForName:@"href"] stringValue] lastPathComponent];
        ID = [ID stringByAppendingFormat:@" %@", nick];
        NSString *category = [[node nodesForXPath:@"div[@class=\"category\"]" error:nil][0]stringValue];
        category = [category substringToIndex:[category length]-1]; // trim final \n
        NSString *type = [[node attributeForName:@"class"] stringValue];
        NSString *price = [[[node nodesForXPath:@".//div[@class=\"price\"]" error:nil][0] children][0] stringValue];
        NSString *cents = [[[node nodesForXPath:@".//div[@class=\"price\"]" error:nil][0] children][1] stringValue];
        if ([price isEqualToString:@""])
            price = cents;
        else if ( ![cents hasPrefix:@"Buy"])
            price = [NSString stringWithFormat:@"%@.%@", price, cents];
        // TODO:NSXML UTF8 encoding
        NSMutableString *fixedPrice = [price mutableCopy];
        [fixedPrice replaceOccurrencesOfString:@"â‚¬" withString:@"€" options:0 range:NSMakeRange(0, [fixedPrice length])];
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.ID = ID;
        item.categories = category;
        item.description = [NSString stringWithFormat:@"%@ %@", type, fixedPrice];
        [items addObject:item];
    }
    return items;

}

- (NSString *)home:(GItem *)item {
    NSArray *nodes =[self.agent nodesForURL:[@"http://itunes.apple.com/app/id" stringByAppendingString:[item.ID componentsSeparatedByString:@" "][0]] XPath:@"//div[@class=\"app-links\"]/a"];
    NSString *home = [[nodes[0] attributeForName:@"href"] stringValue];
    if ([home isEqualToString:@"http://"])
        home = [[nodes[1] attributeForName:@"href"] stringValue];
    return home;
}

- (NSString *)log:(GItem *)item {
    NSString *name = [item.ID componentsSeparatedByString:@" "][1];
    NSString *category = [[item.categories stringByReplacingOccurrencesOfString:@" " withString:@"-"] lowercaseString];
    category = [[category stringByReplacingOccurrencesOfString:@"-&-" withString:@"-"] lowercaseString]; // fix Healthcare & Fitness
    return [NSString stringWithFormat:@"http://www.appshopper.com/mac/%@/%@", category, name];
}

@end
