#import "GFreeBSD.h"
#import "GPackage.h"

@implementation GFreeBSD

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"FreeBSD";
        self.homepage = @"http://www.freebsd.org/ports/";
        self.prefix = @"";
        self.cmd = [NSString stringWithFormat:@"%@freebsd", self.prefix];
    }
    return self;
}

- (NSArray *)list {
    [self.packagesIndex removeAllObjects];
    [self.items removeAllObjects];  
    if ([[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/Guigna/FreeBSD/INDEX" stringByExpandingTildeInPath]]) {
        NSArray *lines = [[NSString stringWithContentsOfFile:[@"~/Library/Application Support/Guigna/FreeBSD/INDEX" stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil]componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *components = [line componentsSeparatedByString:@"|"];
            NSString *name = components[0];
            NSUInteger sep = [name rangeOfString:@"-" options:NSBackwardsSearch].location;
            if (sep == NSNotFound)
                continue;
            NSString *version = [name substringFromIndex:sep+1];
            name = [name substringToIndex:sep];
            NSString *description = components[3];
            NSString *category = components[6];
            NSString *homepage = components[9];
            GPackage *package = [[GPackage alloc] initWithName:name
                                                       version:version
                                                        system:self
                                                        status:GAvailableStatus];
            package.categories = category;
            package.description = description;
            package.homepage = homepage;
            [self.items addObject:package];
            // [self.packagesIndex setObject:package forKey:[package key]];
        }
    } else { 
        id root =[self.agent nodesForURL:@"http://www.freebsd.org/ports/master-index.html" XPath:@"/*"][0];
        NSArray *names = [root nodesForXPath:@"//p/strong/a" error:nil];
        NSArray *descriptions = [root nodesForXPath:@"//p/em" error:nil];
        NSUInteger i = 0;
        for (id node in names) {
            NSString *name = [node stringValue];
            NSUInteger sep = [name rangeOfString:@"-" options:NSBackwardsSearch].location;
            NSString *version = [name substringFromIndex:sep+1];
            name = [name substringToIndex:sep];
            NSString *category = [[node attributeForName:@"href"] stringValue];
            category = [category substringToIndex:[category rangeOfString:@".html"].location];
            NSString *description = [descriptions[i] stringValue];        
            GPackage *package = [[GPackage alloc] initWithName:name
                                                       version:version
                                                        system:self
                                                        status:GAvailableStatus];
            package.categories = category;
            package.description = description;
            [self.items addObject:package];
#if 0
            [self.packagesIndex setObject:package forKey:[package key]];
#endif /* 0 */
            i++;
        }
    }
#if 0
    for (GPackage *package in self.installed) {
        ((GPackage *)[self.packagesIndex objectForKey:[package key]]).status = package.status;
    }
#endif /* 0 */
    return self.items;
}

- (NSString *)info:(GItem *)item { // TODO: Offline mode
    NSString *category = [item.categories componentsSeparatedByString:@" "][0]; // use first category when using INDEX
    NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/url.cgi?ports/%@/%@/pkg-descr", category, item.name] XPath:@"//pre"];
    if ([nodes count] == 0) {
        nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/url.cgi?ports/%@/%@/pkg-descr", category, [item.name lowercaseString]] XPath:@"//pre"];
    }
    if ([nodes count] == 0 )
        return @"[Info not reachable]";
    else
        return [nodes[0] stringValue];
}


- (NSString *)home:(GItem *)item {
    if (item.homepage != nil) // already available from INDEX
        return item.homepage;
    else {
        NSString *category = [item.categories componentsSeparatedByString:@" "][0];
        NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/url.cgi?ports/%@/%@/pkg-descr", category, item.name] XPath:@"//pre/a"];
        if ([nodes count] == 0) {
            nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/url.cgi?ports/%@/%@/pkg-descr", category, [item.name lowercaseString]] XPath:@"//pre/a"];
        }
        if ([nodes count] == 0 )
            return item.system.homepage;
        else
            return [nodes[0] stringValue];
    }
}

// TODO:
- (NSString *)log:(GItem *)item {
    NSString *category = [item.categories componentsSeparatedByString:@" "][0];
    if (item != nil)
        return [NSString stringWithFormat:@"http://www.freshports.org/%@/%@", category, item.name];
    else
        return @"http://www.freshports.org";
}

- (NSString *)contents:(GItem *)item {
    NSString *category = [item.categories componentsSeparatedByString:@" "][0];
    NSString *itemName = item.name;
    NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/cvsweb.cgi/ports/%@/%@/pkg-plist", category, itemName] XPath:@"//a[@class=\"display-link\"]"];
    if ([nodes count] == 0) {
        itemName = [itemName lowercaseString];
        nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/cvsweb.cgi/ports/%@/%@/pkg-plist", category, itemName] XPath:@"//a[@class=\"display-link\"]"];
    }
    if ([nodes count] == 0 )
        return @"[pkglist not reachable]";
    else {
        NSString *link = [[nodes[0] attributeForName:@"href"] stringValue];
        return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/cvsweb.cgi/ports/%@/%@/%@", category, itemName, link]] encoding:NSUTF8StringEncoding error:nil];
    }
}

- (NSString *)cat:(GItem *)item {
    NSString *category = [item.categories componentsSeparatedByString:@" "][0];
    NSString *itemName = item.name;
    NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/cvsweb.cgi/ports/%@/%@/Makefile", category, itemName] XPath:@"//a[@class=\"display-link\"]"];
    if ([nodes count] == 0) {
        itemName = [itemName lowercaseString];
        nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/cvsweb.cgi/ports/%@/%@/Makefile", category, itemName] XPath:@"//a[@class=\"display-link\"]"];
    }
    if ([nodes count] == 0 )
        return @"[Makefile not reachable]";
    else {
        NSString *link = [[nodes[0] attributeForName:@"href"] stringValue];
        return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://www.FreeBSD.org/cgi/cvsweb.cgi/ports/%@/%@/%@", category, itemName, link]] encoding:NSUTF8StringEncoding error:nil];
    }
}

//# TODO:deps => parse requirements:
// http://www.FreeBSD.org/cgi/ports.cgi?query=%5E' + '%@-%@' item.name-item.version

@end
