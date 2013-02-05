#import "GPkgsrc.h"
#import "GPackage.h"

@implementation GPkgsrc

- (id)initWithAgent:(GuignaAgent *)agent {
    self = [super initWithAgent:agent];
    if (self) {
        self.name = @"pkgsrc";
        self.homepage = @"http://www.pkgsrc.org";
        self.prefix = @"/usr/pkg/sbin";
        self.cmd = [NSString stringWithFormat:@"%@/pkg_info", self.prefix];
    }
    return self;
}

- (NSArray *)list {
    [self.packagesIndex removeAllObjects];
    [self.items removeAllObjects];  
    if ([[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/Guigna/pkgsrc/INDEX" stringByExpandingTildeInPath]]) {
        NSArray *lines = [[NSString stringWithContentsOfFile:[@"~/Library/Application Support/Guigna/pkgsrc/INDEX" stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil]componentsSeparatedByString:@"\n"];
        for (NSString *line in lines) {
            NSArray *components = [line componentsSeparatedByString:@"|"];
            NSString *name = components[0];
            NSInteger sep = [name rangeOfString:@"-" options:NSBackwardsSearch].location;
            if (sep == NSNotFound)
                continue;
            NSString *version = [name substringFromIndex:sep+1];
            // name = [name substringToIndex:sep];
            NSString *ID = components[1];
            sep = [ID rangeOfString:@"/" options:NSBackwardsSearch].location;
            name = [ID substringFromIndex:sep+1];
            NSString *description = components[3];
            NSString *category = components[6];
            NSString *homepage = components[11];
            GPackage *package = [[GPackage alloc] initWithName:name
                                                       version:version
                                                        system:self
                                                        status:GAvailableStatus];
            package.ID = ID;
            package.categories = category;
            package.description = description;
            package.homepage = homepage;
            [self.items addObject:package];
            (self.packagesIndex)[[package key]] = package;
        }
    } else {
        NSArray *nodes =[self.agent nodesForURL:@"http://ftp.netbsd.org/pub/pkgsrc/current/pkgsrc/README-all.html" XPath:@"//tr"];
        for (id node in nodes) {
            NSArray *dataRows = [node nodesForXPath:@"td" error:nil];
            if ([dataRows count]== 0)
                continue;
            NSString *name = [dataRows[0] stringValue];
            NSInteger sep = [name rangeOfString:@"-" options:NSBackwardsSearch].location;
            if (sep == NSNotFound)
                continue;
            NSString *version = [name substringWithRange:NSMakeRange(sep+1, [name length]-sep-3)];
            name = [name substringToIndex:sep];
            NSString *category = [dataRows[1] stringValue];
            category = [category substringWithRange:NSMakeRange(1, [category length]-3)];
            NSString *description = [dataRows[2] stringValue];
            sep = [description rangeOfString:@"  " options:NSBackwardsSearch].location;
            if (sep != NSNotFound)
                description = [description substringToIndex:sep];
            GPackage *package = [[GPackage alloc] initWithName:name
                                                       version:version
                                                        system:self
                                                        status:GAvailableStatus];
            package.categories = category;
            package.description = description;
            [self.items addObject:package];
            (self.packagesIndex)[[package key]] = package;
        }
    }
    for (GPackage *package in self.installed) {
        ((GPackage *)(self.packagesIndex)[[package key]]).status = package.status;
    }
    return self.items;
}

// TODO:

- (NSArray *)installed {
    NSMutableArray *packages = [NSMutableArray array];
    if (self.mode == GOnlineMode)
        return packages;
    NSMutableArray *output = [NSMutableArray arrayWithArray:[[self outputFor:@"%@", self.cmd] componentsSeparatedByString:@"\n"]];
    NSMutableArray *ids = [NSMutableArray arrayWithArray:[[self outputFor:@"%@ -Q PKGPATH -a", self.cmd] componentsSeparatedByString:@"\n"]];
    [output removeLastObject];
    [ids removeLastObject];
    GStatus status;
    NSCharacterSet *whitespaceCharacterSet = [NSCharacterSet whitespaceCharacterSet];
    int i = 0;
    for (NSString *line in output) {
        NSInteger sep = [line rangeOfString:@" "].location;
        NSString *name = [line substringToIndex:sep];
        NSString *description = [line substringFromIndex:sep+1];
        sep = [name rangeOfString:@"-" options:NSBackwardsSearch].location;
        NSString *version = [name substringFromIndex:sep+1];
        // name = [name substringToIndex:sep];
        NSString *ident= ids[i];
        sep = [ident rangeOfString:@"/"].location;
        name = [ident substringFromIndex:sep+1];
        status = GUpToDateStatus;
        GPackage *package = [[GPackage alloc] initWithName:name
                                                   version:version
                                                    system:self
                                                    status:status];
        package.description = [description stringByTrimmingCharactersInSet:whitespaceCharacterSet];
        package.ID = ident;
        [packages addObject:package];
        i++;
    }
    return packages;
}

// include category for managing duplicates of xp, binutils, fuse, p5-Net-CUPS
- (NSString *)keyForPackage:(GPackage *)package {
    if (package.ID != nil)
        return [NSString stringWithFormat:@"%@-%@", package.ID, self.name];
    else {
        return [NSString stringWithFormat:@"%@/%@-%@", [package.categories componentsSeparatedByString:@" "][0], package.name, self.name];        
    }
}

// TODO: pkg_info -d

// TODO: pkg_info -B PKGPATH=misc/figlet


- (NSString *)info:(GItem *)item {
    if (self.mode == GOfflineMode && item.status != GAvailableStatus)
        return [self outputFor:@"%@ %@", self.cmd, item.name];
    else {
        if (item.ID != nil)
            return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/%@/DESCR", item.ID]] encoding:NSUTF8StringEncoding error:nil];
        else // TODO lowercase (i.e. Hermes -> hermes)
            return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/%@/%@/DESCR", item.categories, item.name]] encoding:NSUTF8StringEncoding error:nil];
    }
}

- (NSString *)home:(GItem *)item {
    if (item.homepage != nil) // already available from INDEX
        return item.homepage;
    else if (item.status != GAvailableStatus) {
        NSArray *filtered = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", item.name]];
        return ((GPackage *)filtered[0]).homepage;
    } else {
        NSArray *links = [self.agent nodesForURL:[NSString stringWithFormat:@"http://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/%@/%@/README.html", item.categories, item.name] XPath:@"//p/a"];
        return [[links[2] attributeForName:@"href"] stringValue];
    }
}

- (NSString *)log:(GItem *)item {
    if (item != nil ) {
        if (item.status != GAvailableStatus) {
            NSArray *filtered = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", item.name]];
            item.ID = ((GPackage *)filtered[0]).ID;
        }
        if (item.ID != nil)
            return [NSString stringWithFormat:@"http://cvsweb.NetBSD.org/bsdweb.cgi/pkgsrc/%@/", item.ID];
        else 
            return [NSString stringWithFormat:@"http://cvsweb.NetBSD.org/bsdweb.cgi/pkgsrc/%@/%@/", item.categories, item.name];
    } else {
        return @"http://www.netbsd.org/changes/pkg-changes.html";
    }
}


- (NSString *)contents:(GItem *)item {
    if (item.status != GAvailableStatus)
        return [[self outputFor:@"%@ -L %@", self.cmd, item.name] componentsSeparatedByString:@"Files:\n"][1];
    else {
        if (item.ID != nil)
            return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/%@/PLIST", item.ID]] encoding:NSUTF8StringEncoding error:nil];
        else
            return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/%@/%@/PLIST", item.categories, item.name]] encoding:NSUTF8StringEncoding error:nil];
    }
}

- (NSString *)cat:(GItem *)item {
    if (item.status != GAvailableStatus) {
        NSArray *filtered = [self.items filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"name == %@", item.name]];
        item.ID = ((GPackage *)filtered[0]).ID;
    }
    if (item.ID != nil)
        return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/%@/Makefile", item.ID]] encoding:NSUTF8StringEncoding error:nil];
    else 
        return [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"http://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc/%@/%@/Makefile", item.categories, item.name]] encoding:NSUTF8StringEncoding error:nil];
}

// TODO: Deps: pkg_info -n -r, scrape site, parse Index

- (NSString *)deps:(GItem *)item { // FIXME: "*** PACKAGE MAY NOT BE DELETED *** "
    if (item.status != GAvailableStatus) {
        NSArray *components = [[self outputFor:@"%@ -n %@", self.cmd, item.name] componentsSeparatedByString:@"Requires:\n"];
        if ([components count] > 1) {
            return [components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        } else
            return @"[No depends]";
    } else {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[@"~/Library/Application Support/Guigna/pkgsrc/INDEX" stringByExpandingTildeInPath]]) {
            // TODO: parse INDEX
            // NSArray *lines = [NSString stringWithContentsOfFile:[@"~/Library/Application Support/Guigna/pkgsrc/INDEX" stringByExpandingTildeInPath] encoding:NSUTF8StringEncoding error:nil];
        }
        return @"[No depends]";
    }
}

- (NSString *)dependents:(GItem *)item {
    if (item.status != GAvailableStatus) {
        NSArray *components = [[self outputFor:@"%@ -r %@", self.cmd, item.name] componentsSeparatedByString:@"required by list:\n"];
        if ([components count] > 1) {
            return [components[1] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        } else
            return @"[No dependents]";
    } else
        return @"[No dependents]";
}

- (NSString *) installCmd:(GPackage *)package {
    if (package.ID != nil)
        return [NSString stringWithFormat:@"cd /usr/pkgsrc/%@ ; sudo /usr/pkg/bin/bmake install clean clean-depends", package.ID];
    else 
        return [NSString stringWithFormat:@"cd /usr/pkgsrc/%@/%@ ; sudo /usr/pkg/bin/bmake install clean clean-depends", package.categories, package.name];
}

- (NSString *) uninstallCmd:(GPackage *)package {
    return [NSString stringWithFormat:@"sudo %@/pkg_delete %@", self.prefix, package.name];
}

+ (NSString *)setupCmd {
    return @"cd ~/Library/Application\\ Support/Guigna/pkgsrc ; curl -L -O ftp://ftp.NetBSD.org/pub/pkgsrc/current/pkgsrc.tar.gz ; sudo tar -xvzf pkgsrc.tar.gz -C /usr; cd /usr/pkgsrc/bootstrap ; sudo ./bootstrap";
}

+ (NSString *)removeCmd {
    return @"sudo rm -r /usr/pkg ; sudo rm -r /usr/pkgsrc ; sudo rm -r /var/db/pkg";
}

- (NSString *)hideCmd {
    return @"sudo mv /usr/pkg /usr/pkg_off"; // TODO: prefix
}

- (NSString *)unhideCmd {
    return @"sudo mv /usr/pkg_off /usr/pkg";
}


@end
