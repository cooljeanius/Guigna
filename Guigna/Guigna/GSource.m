#import "GSource.h"

#import "GItem.h"

@implementation GSource

@synthesize name = _name;
@synthesize categories = _categories;
@synthesize status;
@synthesize mode;
@synthesize homepage;
@synthesize items = _items;
@synthesize agent =_agent;
@synthesize cmd;

- (id)initWithName:(NSString *)name agent:(GuignaAgent *)agent {
    self = [super init];
    if (self) {
        self.name = name;
        self.agent = agent;
        self.items = [NSMutableArray array];
    }
    return self;
}

- (id)initWithName:(NSString *)name {
    self = [self initWithName:name agent:nil];
    return self;
}

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [self initWithName:@"" agent:agent];
    return self;
}

- (NSString *)info:(GItem *)item {
    return [NSString stringWithFormat:@"%@ - %@\n%@", item.name, item.version, [self home:item]];
}

- (NSString *)home:(GItem *)item {
    if (item.homepage != nil)
        return item.homepage;
    else
        return self.homepage;
}

- (NSString *)log:(GItem *)item {
    return @"[Not Available]";
}

- (NSString *)contents:(GItem *)item {
    return @"[Not Available]";
}

- (NSString *)cat:(GItem *)item {
    return @"[Not Available]";
}

- (NSString *)deps:(GItem *)item {
    return @"[Not Available]";
}

- (NSString *)dependents:(GItem *)item {
    return @"[Not Available]";
}


@end
