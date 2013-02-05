#import "GMacPorts.h"
#import "GPackage.h"

@implementation GMacPorts

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"MacPorts";
        self.homepage = @"http://www.macports.org";
        self.prefix = @"/opt/local";
        self.cmd = [NSString stringWithFormat:@"%@/bin/port", self.prefix];
    }
    return self;
}

- (NSArray *)list {
    [self.packagesIndex removeAllObjects];
    [self.items removeAllObjects];
    NSString *portIndex;
    if (self.mode == GOnlineMode) // TODO: fetch PortIndex
        portIndex = [NSString stringWithContentsOfFile:[@"~/Library/Application Support/Guigna/MacPorts/PortIndex" stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil];
    else
        portIndex = [NSString stringWithContentsOfFile:[self.prefix stringByAppendingString:@"/var/macports/sources/rsync.macports.org/release/tarballs/ports/PortIndex"] encoding:NSUTF8StringEncoding error:nil];
    NSScanner *s =  [NSScanner scannerWithString:portIndex];
    [s setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    NSCharacterSet *spaceOrReturn = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    NSString *str = [[NSString alloc] init];
    NSUInteger loc;
    NSString *name = [[NSString alloc] init];
    NSString *key =  [[NSString alloc] init];
    NSMutableString *value =  [[NSMutableString alloc] init];
    NSString *version = nil;
    NSString *revision = nil;
    NSString *categories = nil;
    NSString *description = nil;
    NSString *homepage = nil;
    int i = 0;
    
    while (1) {
        if ( ![s scanUpToString:@" " intoString: &name])
            break;
        [s scanUpToString:@"\n" intoString: nil];
        [s scanString:@"\n" intoString: nil];
        while (1) {
            [s scanUpToString:@" " intoString: &key];
            [s scanString:@" " intoString: nil];
            loc = [s scanLocation];
            BOOL nextIsBrace = [s scanString:@"{" intoString:nil];
            [s setScanLocation:loc];
            if (nextIsBrace) {
                [value setString:@""];
                [s scanString:@"{" intoString:nil];
                do {
                    NSRange range = [value rangeOfString:@"{"];
                    if (range.location != NSNotFound)
                        [value replaceOccurrencesOfString:@"{" withString:@"" options:0 range:range];
                    if ([s scanUpToString:@"}" intoString:&str])
                        [value appendString:str];
                    [s scanString:@"}" intoString:nil];
                    
                } while ([value rangeOfString:@"{"].location != NSNotFound);
            } else {
                [s scanUpToCharactersFromSet:spaceOrReturn intoString:&str];
                [value setString:str];
            }
            if ([key isEqualToString:@"version"])
                version = [value copy];
            if ([key isEqualToString:@"revision"])
                revision = [value copy];
            if ([key isEqualToString:@"categories"])
                categories = [value copy];
            if ([key isEqualToString:@"description"])
                description = [value copy];
            if ([key isEqualToString:@"homepage"])
                homepage = [value copy];
            loc = [s scanLocation];
            BOOL nextIsReturn = [s scanString:@"\n" intoString:nil];
            [s setScanLocation:loc];
            if (nextIsReturn) {
                [s scanString:@"\n" intoString:nil];
                break;
            }
            [s scanString:@" " intoString: nil];
        }
        GPackage *package = [[GPackage alloc] initWithName:name
                                                   version:[NSString stringWithFormat:@"%@_%@", version, revision]
                                                    system:self
                                                    status:GAvailableStatus];
        package.categories = categories;
        package.description = description;
        if (self.mode == GOnlineMode) {
            package.homepage = homepage;
        }
        package.ID = [NSString stringWithFormat:@"%d", i];
        [self.items addObject:package];
        (self.packagesIndex)[[package key]] = package;
        i++;
    }
    if (self.mode != GOnlineMode) {
        for (GPackage *package in self.installed) {
            GPackage *indexedPackage = (GPackage *)(self.packagesIndex)[[package key]];
            indexedPackage.status = package.status;
            indexedPackage.variants = package.variants;
        }
    }
    return self.items;
}


- (NSArray *)installed {
    NSMutableArray *packages = [NSMutableArray array];
    if (self.mode == GOnlineMode)
        return packages;
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ installed", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    [output removeObjectAtIndex:0];
    NSArray *outdated = [self outdated];
    GStatus status;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
    for (NSString *line in output) {
        NSArray *components = [[line stringByTrimmingCharactersInSet:whitespaceCharacterSet] componentsSeparatedByString:@" "];
        NSString *name = components[0];
        NSString *version = [components[1] substringFromIndex:1];
        NSString *description = @"";
        NSInteger sep = [version rangeOfString:@"+"].location;
        if (sep != NSNotFound) {
            description = [version substringFromIndex:sep];
            version = [version substringToIndex:sep];
        }
        status = GUpToDateStatus;
        for (GPackage *package in outdated) {
            if ([name isEqualToString:package.name]) {
                status = GOutdatedStatus;
                break;
            }
        }
        if ([components count] == 2)
            status = GInactiveStatus;
        GPackage *package = [[GPackage alloc] initWithName:name
                                                   version:version
                                                    system:self
                                                    status:status];
        package.description = description;
        package.variants = description;
        [packages addObject:package];
    }
    return packages;
}

- (NSArray *)outdated {
    NSMutableArray *packages = [NSMutableArray array];
    if (self.mode == GOnlineMode)
        return packages;
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self  outputFor:@"%@ outdated", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    [output removeObjectAtIndex:0];
    for (NSString *line in output) {
        NSArray *components = [[line  componentsSeparatedByString:@" < "][0] componentsSeparatedByString:@" "];
        GPackage *package = [[GPackage alloc] initWithName:components[0]
                                                   version:[components lastObject]
                                                    system:self
                                                    status:GOutdatedStatus];
        [packages addObject:package];
    }
    return packages;
}

- (NSArray *)inactive {
    NSMutableArray *packages = [NSMutableArray array];
    if (self.mode == GOnlineMode)
        return packages;
    for (GPackage *package in [self installed]) {
        if (package.status == GInactiveStatus)
            [packages addObject:package];
    }
    return packages;
}


- (NSArray *)availableCommands {
    return @[@"sudo install -y"];
}

// TODO: GOnlineState

- (NSString *)info:(GItem *)item {
    if (self.mode == GOnlineMode) {
        // return @"[Not available]";
        // TODO:
        NSString *info = [[self.agent nodesForURL:[NSString stringWithFormat:@"http://www.macports.org/ports.php?by=name&substr=%@", item.name] XPath:@"//div[@id=\"content\"]/dl"][0] stringValue];
        NSArray *keys = [self.agent nodesForURL:[NSString stringWithFormat:@"http://www.macports.org/ports.php?by=name&substr=%@", item.name] XPath:@"//div[@id=\"content\"]/dl//i"];
        for (id key in keys) {
            info = [info stringByReplacingOccurrencesOfString:[key stringValue] withString:[NSString stringWithFormat:@"\n\n%@\n", [key stringValue]]];
        }
        return info;
    }
    return [self outputFor:@"%@ info %@", self.cmd, item.name];
}

- (NSString *)home:(GItem *)item {
    if (self.mode == GOnlineMode)
        return item.homepage;
    NSString *output = [self outputFor:@"%@ -q info --homepage %@", self.cmd, item.name];
    return [output substringToIndex:[output length]-1];
}

- (NSString *)log:(GItem *)item {
    if (item != nil ) {
        NSString *category = [item.categories componentsSeparatedByString:@" "][0];
        return [NSString stringWithFormat:@"http://trac.macports.org/log/trunk/dports/%@/%@/Portfile", category, item.name];
    } else {
        return @"http://trac.macports.org/timeline";
    }
}

- (NSString *)contents:(GItem *)item {
    if (self.mode == GOnlineMode)
        return @"[Not available]";
    return [self outputFor:@"%@ contents %@", self.cmd, item.name];
}

- (NSString *)cat:(GItem *)item {
    if (self.mode == GOnlineMode)
        return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://trac.macports.org/browser/trunk/dports/%@/%@/Portfile?format=txt", [item.categories componentsSeparatedByString:@" "][0], item.name]] encoding:NSUTF8StringEncoding error:nil];
    return [self outputFor:@"%@ cat %@", self.cmd, item.name];
}

- (NSString *)deps:(GItem *)item {
    if (self.mode == GOnlineMode)
        return @"[Not available]";
    return [self outputFor:@"%@ rdeps --index %@", self.cmd, item.name];
}

- (NSString *)dependents:(GItem *)item {
    if (self.mode == GOnlineMode)
        return @"[Not available]";
    // TODO only when status == installed
    if (item.status != GAvailableStatus)
        return [self outputFor:@"%@ dependents %@", self.cmd, item.name];
    else
        return [NSString stringWithFormat:@"[%@ not installed]", item.name];
}


- (NSArray *)dependenciesList:(GPackage *)package {
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ rdeps --index %@", self.cmd, package.name] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    [output removeObjectAtIndex:0];
    NSMutableArray *deps = [NSMutableArray array];
    for (NSString *line in output) {
        [deps addObject:[line stringByTrimmingCharactersInSet:whitespaceCharacterSet]];
    }
    return deps;
}


- (NSString *) installCmd:(GPackage *)package {
    NSString *variants = package.markedVariants;
    if (variants == nil)
        variants = @"";
    return [NSString stringWithFormat:@"sudo %@ install %@ %@", self.cmd, package.name, variants];
}

- (NSString *) uninstallCmd:(GPackage *)package {
    NSString *variants = package.variants;
    if (variants == nil)
        variants = @"";
    if (package.status == GOutdatedStatus || package.status == GInactiveStatus || package.status == GUpdatedStatus)
        return [NSString stringWithFormat:@"sudo %@ -f uninstall %@ ; sudo port clean --all %@", self.cmd, package.name, package.name];
    else
        return [NSString stringWithFormat:@"sudo %@ -f uninstall %@ @%@%@", self.cmd, package.name, package.version, variants];
}

- (NSString *) deactivateCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"sudo %@ deactivate %@", self.cmd, package.name];
}

- (NSString *) upgradeCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"sudo %@ upgrade %@", self.cmd, package.name];
    //    return [NSString stringWithFormat:@"sudo %@ -f uninstall %@ ; sudo %@ -f clean --all %@ ; sudo %@ install %@", self.cmd, package.name, self.cmd, package.name, self.cmd, package.name] ;
}

- (NSString *) fetchCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"sudo %@ fetch %@", self.cmd, package.name];
}

- (NSString *)cleanCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"sudo %@ clean --all %@", self.cmd, package.name];
}

- (NSString *)selfupdateCmd {
    if (self.mode == GOnlineMode) {
        return @"sudo cd ; cd ~/Library/Application\\ Support/Guigna/Macports ; /usr/bin/rsync -rtzv rsync://rsync.macports.org/release/tarballs/PortIndex_darwin_12_i386/PortIndex PortIndex";
    } else {
        return [NSString stringWithFormat:@"sudo %@ selfupdate", self.cmd];
    }
}

- (NSString *)hideCmd {
    return @"sudo mv /opt/local /opt/local_off"; // TODO: prefix
}

- (NSString *)unhideCmd {
    return @"sudo mv /opt/local_off /opt/local";
}


@end
