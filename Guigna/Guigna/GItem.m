#import "GItem.h"

@implementation GItem

@synthesize name = _name;
@synthesize version = _version;
@synthesize source = _source;
@synthesize status = _status;
@synthesize system = _system;
@synthesize mark;
@synthesize ID = _id;
@synthesize categories;
@synthesize description;
@synthesize homepage;
@synthesize URL;

- (id)initWithName:(NSString *)name
           version:(NSString *)version
            source:(GSource *)source
            status:(GStatus)status {
    self = [super init];
    if (self) {
        self.name = name;
        self.version = version;
        self.source = source;
        self.status = status;
    }
    return self;
}

// TODO: 

- (id)initWithCoder:(NSCoder *)coder
{
	self = [super init];
	if (self) {
		_name = [coder decodeObjectForKey:@"name"];
		_version = [coder decodeObjectForKey:@"version"];
	}
	return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_name forKey:@"name"];
    [coder encodeObject:_version forKey:@"version"];
}

@end


@implementation GStatusTransformer

+ (Class)transformedValueClass { 
	return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation { 
	return NO;
}

- (id)transformedValue:(id)status {
    switch ([status intValue]) {
        case GInactiveStatus:
            return [NSImage imageNamed:NSImageNameStatusNone];
            break;
        case GUpToDateStatus:
            return [NSImage imageNamed:NSImageNameStatusAvailable];
            break;
        case GOutdatedStatus:
            return [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
            break;
        case GUpdatedStatus:
            return [NSImage imageNamed:@"status-updated.tiff"];
            break;
        case GNewStatus:
            return [NSImage imageNamed:@"status-new.tiff"];
            break;
        case GBrokenStatus:
            return [NSImage imageNamed:NSImageNameStatusUnavailable];
            break;
        default:
            return nil;
    }
}

@end


@implementation GSourceTransformer

+ (Class)transformedValueClass { 
	return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation { 
	return NO;
}

- (id)transformedValue:(GSource *)source {
    // TODO: rename source-xxx.tiff and automatic downcase
    NSString *name = source.name;
    if ([name isEqualToString:@"MacPorts"])
        return [NSImage imageNamed:@"system-macports.tiff"];
    else if ([name isEqualToString:@"Homebrew"])
        return [NSImage imageNamed:@"system-homebrew.tiff"];
    else if ([name isEqualToString:@"CocoaPods"])
        return [NSImage imageNamed:@"system-cocoapods.tiff"];
    else if ([name isEqualToString:@"Mac OS X"])
        return [NSImage imageNamed:@"system-macosx.tiff"];
    else if ([name isEqualToString:@"Fink"])
        return [NSImage imageNamed:@"system-fink.tiff"];
    else if ([name isEqualToString:@"pkgsrc"])
        return [NSImage imageNamed:@"system-pkgsrc.tiff"];
    else if ([name isEqualToString:@"FreeBSD"])
        return [NSImage imageNamed:@"system-freebsd.tiff"];
    else if ([name isEqualToString:@"Native Installers"])
        return [NSImage imageNamed:@"source-native.tiff"];
    else if ([name isEqualToString:@"Rudix"])
        return [NSImage imageNamed:@"system-rudix.tiff"];
    if ([name isEqualToString:@"MacPorts.org"])
        return [NSImage imageNamed:@"system-macports.tiff"];
    else if ([name isEqualToString:@"installed"])
        return [NSImage imageNamed:NSImageNameStatusAvailable];
    else if ([name isEqualToString:@"outdated"])
        return [NSImage imageNamed:NSImageNameStatusPartiallyAvailable];
    else if ([name isEqualToString:@"inactive"])
        return [NSImage imageNamed:NSImageNameStatusNone];
    else if ([name hasPrefix:@"updated"])
        return [NSImage imageNamed:@"status-updated.tiff"];
    else if ([name hasPrefix:@"new"])
        return [NSImage imageNamed:@"status-new.tiff"];
    else if ([name isEqualToString:@"Freecode"])
        return [NSImage imageNamed:@"source-freecode.tiff"];
    else if ([name isEqualToString:@"Pkgsrc.se"])
        return [NSImage imageNamed:@"source-pkgsrc.se.tiff"];
    else if ([name isEqualToString:@"AppShopper"])
        return [NSImage imageNamed:@"source-appshopper.tiff"];
    else if ([name isEqualToString:@"AppShopper iOS"])
        return [NSImage imageNamed:@"source-appshopper.tiff"];
    else if ([name isEqualToString:@"MacUpdate"])
        return [NSImage imageNamed:@"source-macupdate.tiff"];
    else if ([name isEqualToString:@"VersionTracker"])
        return [NSImage imageNamed:@"source-versiontracker.tiff"];

    else
        return nil;
}

@end

@implementation GMarkTransformer

+ (Class)transformedValueClass { 
	return [NSImage class]; 
}

+ (BOOL)allowsReverseTransformation { 
	return NO;
}

- (id)transformedValue:(id)mark {
    switch ([mark intValue]) {
        case GInstallMark:
            return [NSImage imageNamed:NSImageNameAddTemplate];
            break;
        case GUninstallMark:
            return [NSImage imageNamed:NSImageNameRemoveTemplate];
            break;
        case GDeactivateMark:
            return [NSImage imageNamed:NSImageNameStopProgressTemplate];
            break;
        case GUpgradeMark:
            return [NSImage imageNamed:NSImageNameRefreshTemplate];
            break;
        case GFetchMark:
            return [NSImage imageNamed:@"source-native.tiff"];
            break;
        case GCleanMark:
            return [NSImage imageNamed:NSImageNameActionTemplate];
            break;
        default:
            return nil;
    }
}

@end
