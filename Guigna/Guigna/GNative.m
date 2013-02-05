#import "GNative.h"

@implementation GNative

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = @"Native Installers";
        self.homepage = @"https://github.com/gui-dos/Guigna/wiki";
        self.pageNumber = 1;
        self.itemsPerPage = 250;
        self.agent = agent;
        self.cmd = @"installer";
    }
    return self;
}

- (NSArray *)items {
    NSMutableArray *items = [NSMutableArray array];
    NSString *url = @"https://docs.google.com/spreadsheet/ccc?key=0AryutUy3rKnHdHp3MFdabGh6aFVnYnpnUi1mY2E2N0E";
    NSArray *nodes = [self.agent nodesForURL:url XPath:@"//table[@id=\"tblMain\"]//tr"];
    for (id node in nodes) {
        if ([[[node attributeForName:@"class"] stringValue] isEqualToString:@"rShim"])
            continue;
        NSArray *columns = [node nodesForXPath:@"./td" error:nil];
        NSString *name = [columns[1] stringValue];
        NSString *version = [columns[2] stringValue];
        NSString *homepage = [columns[4] stringValue];
        NSString *URL = [columns[5] stringValue];
        GItem *item = [[GItem alloc] initWithName:name
                                          version:version
                                           source:self
                                           status:GAvailableStatus];
        item.homepage = homepage;
        item.description = URL;
        item.URL = URL;
        [items addObject:item];
    }
    return items;    
}

@end
