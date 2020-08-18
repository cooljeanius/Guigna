#import "GRudix.h"

@implementation GRudix

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"Rudix";
        self.homepage = @"http://www.rudix.org/";
        self.pageNumber = 1;
        self.itemsPerPage = 100;
        self.agent = agent;
        self.cmd = @"rudix";
    }
    return self;
}

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = @"http://code.google.com/p/rudix/downloads/list";
    NSArray *nodes = [self.agent nodesForURL:url XPath:@"//table[@id=\"resultstable\"]//tr"];
    for (id node in nodes) {
        NSArray *columns = [node nodesForXPath:@"./td" error:nil];
        if ([columns count] == 0)
            continue;
        NSString *URL = [[[columns[0] nodesForXPath:@"./a" error:nil][0] attributeForName:@"href"] stringValue];
        NSString *name = [columns[1] stringValue];
        NSUInteger sep = [name rangeOfString:@"-"].location;
        NSString *version = [name substringFromIndex:sep+1];
        version = [version substringToIndex:[version length]-4];
        if (![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:[version characterAtIndex:0]]) {
            NSUInteger sep2 = [version rangeOfString:@"-"].location;
            version = [version substringFromIndex:sep2+1];
            sep += sep2+1;
        }
        name = [name substringToIndex:sep];
        NSString *description = [columns[2] stringValue];
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.homepage = [NSString stringWithFormat:@"http://code.google.com/p/rudix/wiki/%@", item.name];
        item.description = description;
        item.URL = [@"http:" stringByAppendingString:URL];
        [items addObject:item];
    }
    return items;    
}

- (NSString *)log:(GItem *)item {
    return [NSString stringWithFormat:@"http://code.google.com/p/rudix/downloads/detail?name=%@", [item.URL lastPathComponent]];
}


// TODO: 
+ (NSString *)setupCmd {
    return @"cd ~/Library/Application\\ Support/Guigna ; curl -O http://rudix.googlecode.com/hg/Ports/rudix/rudix.py ; sudo python rudix.py install rudix";
}

@end
