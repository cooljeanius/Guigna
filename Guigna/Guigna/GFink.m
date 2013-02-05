#import "GFink.h"
#import "GPackage.h"

@implementation GFink

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"Fink";
        self.homepage = @"http://www.finkproject.org";
        self.prefix = @"/sw";
        self.cmd = [NSString stringWithFormat:@"%@/bin/fink", self.prefix];
    }
    return self;
}

- (NSArray *)list {
    [self.packagesIndex removeAllObjects];
    [self.items removeAllObjects];
    if (self.mode == GOnlineMode) {
        NSArray *nodes =[self.agent nodesForURL:@"http://pdb.finkproject.org/pdb/browse.php" XPath:@"//tr[@class=\"package\"]"];
        for (id node in nodes) {
            NSArray *dataRows = [node nodesForXPath:@"td" error:nil];
            NSString *name = [dataRows[0] stringValue];
            NSString *version = [dataRows[1] stringValue];
            NSString *description = [dataRows[2] stringValue];        
            GPackage *package = [[GPackage alloc] initWithName:name
                                                       version:version
                                                        system:self
                                                        status:GAvailableStatus];
            package.description = description;
            [self.items addObject:package];
            (self.packagesIndex)[[package key]] = package;
        }
    } else {
        NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ list --tab", self.cmd] componentsSeparatedByString:@"\n"]];
        [output removeLastObject];
        NSString *state;
        GStatus status;
        NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
        for (NSString *line in output) {
            NSArray *components = [line componentsSeparatedByString:@"\t"];
            state = [components[0] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
            status = GAvailableStatus;
            if ([state isEqualToString:@"i"] || [state isEqualToString:@"p"])
                status = GUpToDateStatus;
            else if ([state isEqualToString:@"(i)"])
                status = GUpdatedStatus;
            GPackage *package = [[GPackage alloc] initWithName:components[1]
                                                       version:components[2]
                                                        system:self
                                                        status:status];
            package.description = components[3];
            [self.items addObject:package];
            (self.packagesIndex)[[package key]] = package;
        }
    }
    if (self.mode != GOnlineMode) {
        for (GPackage *package in self.installed) {
            ((GPackage *)(self.packagesIndex)[[package key]]).status = package.status;
        }
    }
    return self.items;
}

// TODO: sync outdated status

- (NSArray *)installed {
    NSMutableArray *packages = [NSMutableArray array];
    if (self.mode == GOnlineMode)
        return packages;
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ list --installed --tab", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    NSString *state;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
    for (NSString *line in output) {
        NSArray *components = [line componentsSeparatedByString:@"\t"];
        state = [components[0] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
        if ([state isEqualToString:@"i"] || [state isEqualToString:@"p"]) {
            GPackage *package = [[GPackage alloc] initWithName:components[1]
                                                       version:components[2]
                                                        system:self
                                                        status:GUpToDateStatus];
            package.description = components[3];
            [packages addObject:package];
        }
    }
    return packages;
}

- (NSArray *)outdated {
    NSMutableArray *packages = [NSMutableArray array];
    if (self.mode == GOnlineMode)
        return packages;
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ list --outdated --tab", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    NSString *state;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
    for (NSString *line in output) {
        NSArray *components = [line componentsSeparatedByString:@"\t"];
        state = [components[0] stringByTrimmingCharactersInSet:whitespaceCharacterSet];
        if ([state isEqualToString:@"(i)"]) {
            GPackage *package = [[GPackage alloc] initWithName:components[1]
                                                       version:components[2]
                                                        system:self
                                                        status:GUpdatedStatus];
            package.description = components[3];
            [packages addObject:package];
        }
    }
    return packages;
}

// TODO: parse all divs (section, maintainer, ...)
- (NSString *)info:(GItem *)item {
    if (self.mode == GOnlineMode) {
        NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://pdb.finkproject.org/pdb/package.php/%@", item.name] XPath:@"//div[@class=\"desc\"]"];
        if ([nodes count] == 0)
            return @"Info not available]";
        else {
            NSString *desc = [nodes[0] stringValue];
            return desc;
        }
    } else {
        return [self outputFor:@"%@ dumpinfo %@", self.cmd, item.name];
    }
}

- (NSString *)home:(GItem *)item {
    NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://pdb.finkproject.org/pdb/package.php/%@", item.name] XPath:@"//a[contains(@title, \"home\")]"];
    if ([nodes count] == 0)
        return @"[Homepage not available]";
    else {
        NSString *homepage = [nodes[0] stringValue];
        return homepage;
    }
}

- (NSString *)log:(GItem *)item {
    if (item != nil)
        return [NSString stringWithFormat: @"http://pdb.finkproject.org/pdb/package.php/%@", item.name];
    else
        return [NSString stringWithFormat:@"http://www.finkproject.org/package-updates.php"];
}

- (NSString *)contents:(GItem *)item {
    return @"[Contents not available]";
}

- (NSString *)cat:(GItem *)item {
    if (self.mode == GOnlineMode) {
        NSArray *nodes = [self.agent nodesForURL:[NSString stringWithFormat: @"http://pdb.finkproject.org/pdb/package.php/%@", item.name] XPath:@"//a[contains(@title, \"info\")]"];
        if ([nodes count] == 0)
            return @"[.info not reachable]";
        else {
            NSString *cvs = [nodes[0] stringValue];
            NSString *info = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat: @"http://fink.cvs.sourceforge.net/fink/%@", cvs]] encoding:NSUTF8StringEncoding error:nil];
            return info;
        }
    } else {
        return [self outputFor:@"%@ dumpinfo %@", self.cmd, item.name];
    }
}


- (NSString *) installCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"sudo %@ install %@", self.cmd, package.name];
}

- (NSString *) uninstallCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"sudo %@ remove %@", self.cmd, package.name];
}

- (NSString *)selfupdateCmd {
    if (self.mode == GOnlineMode)
        return nil;
    else
        return [NSString stringWithFormat:@"sudo %@ selfupdate", self.cmd];
}

+ (NSString *)setupCmd {
    return @"cd ~/Library/Application\\ Support/Guigna/Fink ; curl -L -O http://downloads.sourceforge.net/fink/fink-0.33.1.tar.gz ; tar -xvzf fink-0.33.1.tar.gz ; cd fink-0.33.1 ; sudo ./bootstrap ; /sw/bin/pathsetup.sh ; . /sw/bin/init.sh ; /sw/bin/fink selfupdate-rsync ; /sw/bin/fink index -f";
}

+ (NSString *)removeCmd {
    return @"sudo rm -rf /sw";
}

- (NSString *)hideCmd {
    return @"sudo mv /sw /sw_off"; // TODO: prefix
}

- (NSString *)unhideCmd {
    return @"sudo mv /sw_off /sw";
}

@end
