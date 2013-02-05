#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import <ScriptingBridge/ScriptingBridge.h>
#import "Terminal.h"
#import "Safari.h"

#import "GuignaAgent.h"

#import "GItem.h"
#import "GSource.h"

#import "GMacPorts.h"
#import "GHomebrew.h"
#import "GCocoaPods.h"
#import "GFink.h"
#import "GMacOSX.h"
#import "GPkgsrc.h"
#import "GFreeBSD.h"
#import "GNative.h"
#import "GRudix.h"
#import "GMacPortsOrg.h"
#import "GFreecode.h"
#import "GPkgsrcSE.h"
#import "GAppShopper.h"
#import "GAppShopperIOS.h"
#import "GMacUpdate.h"
#import "GVersionTracker.h"

@interface GuignaAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate, NSOutlineViewDelegate,NSOutlineViewDataSource, NSTableViewDelegate, NSTableViewDataSource, NSTextViewDelegate>

@property (strong) IBOutlet GuignaAgent *agent;
@property (strong) IBOutlet NSUserDefaultsController *defaultsController;

@property (strong) IBOutlet NSWindow *window;
@property (strong) IBOutlet NSOutlineView *sourcesOutline;
@property (strong) IBOutlet NSTableView *itemsTable;
@property (strong) IBOutlet NSSearchField *searchField;
@property (strong) IBOutlet NSTabView *tabView;
@property (strong) IBOutlet NSTextView *infoText;
@property (strong) IBOutlet WebView *webView;
@property (strong) IBOutlet NSTextView *logText;
@property (strong) IBOutlet NSSegmentedControl *segmentedControl;
@property (strong) IBOutlet NSPopUpButton *commandsPopUp;
@property (strong) IBOutlet NSButton *shellDisclosure;
@property (strong) IBOutlet NSTextField *cmdline;
@property (strong) IBOutlet NSTextField *statusField;
@property (strong) IBOutlet NSButton *clearButton;
@property (strong) IBOutlet NSTextField *statsLabel;
@property (strong) IBOutlet NSButton *moreButton;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;
@property (strong) IBOutlet NSProgressIndicator *tableProgressIndicator;
@property (strong) IBOutlet NSToolbarItem *applyButton;
@property (strong) IBOutlet NSToolbarItem *stopButton;

@property (strong) IBOutlet NSMenu *toolsMenu;
@property (strong) IBOutlet NSMenu *markMenu;
@property (strong) IBOutlet NSPanel *optionsPanel;
@property (strong) IBOutlet NSProgressIndicator *optionsProgressIndicator;
@property (strong) IBOutlet NSTextField *optionsStatusField;

@property(strong) TerminalApplication *terminal;
@property(strong) TerminalTab *shell;
@property(strong) TerminalWindow *shellWindow;
@property(strong) SafariApplication *browser;

@property (strong) IBOutlet NSTreeController *sourcesController;
@property (strong) IBOutlet NSArrayController *itemsController;

@property(strong) NSMutableArray *sources;
@property(strong) NSMutableArray *systems;
@property(strong) NSMutableArray *scrapes;
@property(strong) NSMutableArray *repos;

@property(strong) NSMutableArray *items;
@property(strong) NSMutableArray *allPackages;
@property(strong) NSMutableDictionary *packagesIndex;
@property(strong) NSMutableArray *markedItems;

@property(readwrite) NSInteger marksCount;
@property(strong) NSString *selectedSegment;
@property(readwrite) NSInteger previousSegment;
@property(strong) NSString *APPDIR;


- (void)status:(NSString *)msg;
- (void)info:(NSString *)msg;
- (void)log:(NSString *)text;

- (void)sourcesSelectionDidChange:(id)sender;
- (void)updateTabView:(GItem *)item;
- (void)updateScrape:(GScrape *)scrape;
- (void)updateCmdLine:(NSString *)cmd;
- (void)execute:(NSString *)cmd withBaton:(NSString *)baton;
- (void)execute:(NSString *)cmd;
- (void)executeAsRoot:(NSString *)cmd;
- (void)sudo:(NSString *)cmd withBaton:(NSString *)baton;
- (void)sudo:(NSString *)cmd;

- (void)reloadAllPackages;
- (void)sync:(id)sender;

- (IBAction)marks:(id)sender;
- (IBAction)apply:(id)sender;
- (IBAction)stop:(id)sender;
- (IBAction)syncAction:(id)sender;
- (IBAction)details:(id)sender;
- (IBAction)web:(id)sender;
- (IBAction)shell:(id)sender;
- (IBAction)toolsAction:(id)sender;
- (IBAction)options:(id)sender;
- (IBAction)preferences:(id)sender;
- (IBAction)executeCommandsMenu:(id)sender;

- (IBAction)switchSegment:(id)sender;
- (IBAction)toggleShell:(id)sender;
- (IBAction)executeCmdLine:(id)sender;
- (IBAction)clear:(id)sender;
- (IBAction)moreScrapes:(id)sender;
- (IBAction)showMarkMenu:(id)sender;
- (IBAction)mark:(id)sender;
- (IBAction)setOptions:(id)sender;
- (IBAction)tools:(id)sender;


@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
