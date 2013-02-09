//
//  ProgramStore.m
//  MrScience
//
//  Created by Chris Marrin on 2/18/10.
//  Copyright 2010 Apple Inc. All rights reserved.
//

#import "ProgramStore.h"

#define uncategorizedName @"Uncategorized"

@implementation ProgramStore

+ (NSString*)pathForProgram:(NSString*) title withCategory:(NSString*) category
{
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    path = [path stringByAppendingString:@"/"];
    if ([category length]) {
        path = [path stringByAppendingPathComponent:category];
        path = [path stringByAppendingString:@"/"];
    }
    return [path stringByAppendingPathComponent:[title length] ? title : @"_unnamedProgram"];
}

- (NSString*)currentProgramPath
{
    return [ProgramStore pathForProgram:self.title withCategory:self.category];
}

- (void)moveProgramFromPath:(NSString*) path
{
    NSString* newPath = [self currentProgramPath];
    
    // Make sure new folder exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString* folderPath = [newPath stringByDeletingLastPathComponent];
    if (![fileManager fileExistsAtPath:folderPath]) {
        // Create the folder
        BOOL success = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
        assert(success);
    }
    
    // Make sure there is no file at the path
    if ([fileManager fileExistsAtPath:newPath]) {
        BOOL success = [fileManager removeItemAtPath:newPath error:nil];
        assert(success);
    }
    
    if (![path isEqualToString:newPath]) {
        BOOL success = [fileManager moveItemAtPath:path toPath:newPath error:nil];
        assert(success);
    }
        
    [fileManager release];
}

- (void)makeProgramDirty
{
    m_programDescriptorDirty = YES;
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(saveTimerFired:) userInfo:nil repeats:NO];
}

- (NSArray*)program
{
    return [m_programDescriptor objectForKey:@"program"];
}

- (NSUInteger) currentFunction
{
    return [[m_programDescriptor objectForKey:@"currentFunction"] intValue];
}

- (void)setCurrentFunction:(NSUInteger) value
{
    [m_programDescriptor setValue:[NSNumber numberWithInt:value] forKey:@"currentFunction"];
    [self makeProgramDirty];
}

- (NSUInteger) currentInstruction
{
    return [[m_programDescriptor objectForKey:@"currentInstruction"] intValue];
}

- (void)setCurrentInstruction:(NSUInteger) value
{
    [m_programDescriptor setValue:[NSNumber numberWithInt:value] forKey:@"currentInstruction"];
    [self makeProgramDirty];
}

- (NSString*)title
{
    return [m_programDescriptor objectForKey:@"title"];
}

- (void)setTitle:(NSString*) s
{
    if ([self.title isEqualToString:s])
        return;
        
    NSString* oldPath = [self currentProgramPath];
    [m_programDescriptor setValue:s forKey:@"title"];
    [self moveProgramFromPath:oldPath];
    [self makeProgramDirty];
}

- (NSString*)category
{
    return [m_programDescriptor objectForKey:@"category"];
}

- (void)setCategory:(NSString*) s
{
    if ([self.category isEqualToString:s])
        return;
        
    NSString* oldPath = [self currentProgramPath];
    [m_programDescriptor setValue:s forKey:@"category"];
    [self moveProgramFromPath:oldPath];
    [self makeProgramDirty];
}

- (NSString*)description
{
    return [m_programDescriptor objectForKey:@"description"];
}

- (void)setDescription:(NSString*) s
{
    [m_programDescriptor setValue:s forKey:@"description"];
    [self makeProgramDirty];
}

- (void)saveProgram
{
    if (m_programDescriptorDirty) {
        NSString* path = [self currentProgramPath];
        
        // Make sure new folder exists
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString* folderPath = [path stringByDeletingLastPathComponent];
        if (![fileManager fileExistsAtPath:folderPath]) {
            // Create the folder
            BOOL success = [fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:nil];
            assert(success);
        }
    
        [m_programDescriptor writeToFile:path atomically:YES];
        m_programDescriptorDirty = NO;

    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"currentCategory"] isEqualToString:self.category])
        [[NSUserDefaults standardUserDefaults] setValue:self.category forKey:@"currentCategory"];
    
    if (![[[NSUserDefaults standardUserDefaults] valueForKey:@"currentTitle"] isEqualToString:self.title])
        [[NSUserDefaults standardUserDefaults] setValue:self.title forKey:@"currentTitle"];
    }
}

- (void)saveTimerFired:(NSTimer*)timer
{
    [self saveProgram];
}

+ (NSMutableDictionary*)loadProgramDescriptor:(NSString*) title withCategory:(NSString*) category
{
    NSString *path = [self pathForProgram:title withCategory:category];

    // Check if file exists
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:path]) {
        title = @"";
        category = @"";
        path = [self pathForProgram:title withCategory:category];
        if (![fileManager fileExistsAtPath:path])
            return nil;
    }
    
    NSMutableDictionary* programDescriptor = [NSMutableDictionary dictionaryWithContentsOfFile:path];
    [fileManager release];
    
    // Make sure the title and category are set
    [programDescriptor setObject:title ? title : @"" forKey:@"title"];
    [programDescriptor setObject:category ? category : @"" forKey:@"category"];
    
    return programDescriptor;
}

- (void)loadProgram:(NSString*) title withCategory:(NSString*) category
{
    [self saveProgram];
    m_programDescriptorDirty = NO;

    if ([category isEqualToString:uncategorizedName])
        category = @"";
    
    [m_programDescriptor release];
    m_programDescriptor = [ProgramStore loadProgramDescriptor:title withCategory:category];
    if (!m_programDescriptor)
        return;
        
    [m_programDescriptor retain];
    
    // Validate program descriptor and add any missing items
    if (![[m_programDescriptor objectForKey:@"program"] isKindOfClass:[NSMutableArray class]]) {
        [m_programDescriptor setObject:[NSMutableArray array] forKey:@"program"];
        [self addFunction];
    }
    
    if (![[m_programDescriptor objectForKey:@"title"] isKindOfClass:[NSString class]]) {
        [m_programDescriptor setObject:[NSString string] forKey:@"title"];
    }

    if (![[m_programDescriptor objectForKey:@"description"] isKindOfClass:[NSString class]]) {
        [m_programDescriptor setObject:[NSString string] forKey:@"description"];
    }

    if (![[m_programDescriptor objectForKey:@"category"] isKindOfClass:[NSString class]]) {
        [m_programDescriptor setObject:[NSString string] forKey:@"category"];
    }

    if (![[m_programDescriptor objectForKey:@"currentFunction"] isKindOfClass:[NSNumber class]]) {
        [m_programDescriptor setObject:[NSNumber numberWithInt:0] forKey:@"currentFunction"];
    }

    if (![[m_programDescriptor objectForKey:@"currentInstruction"] isKindOfClass:[NSNumber class]]) {
        [m_programDescriptor setObject:[NSNumber numberWithInt:0] forKey:@"currentInstruction"];
    }

    self.title = title;
    self.category = category;
    [self makeProgramDirty];
}

static NSDictionary* makeFunction(NSString* name, int key)
{
    return [NSMutableDictionary dictionaryWithObjectsAndKeys:
                            name, @"name", 
                            [NSNumber numberWithInt:key], @"key",
                            [NSMutableArray arrayWithObject:@""], @"inst",
                            nil];
}

- (id) initWithProgramPath:(NSString*) path
{
    // Path is a .mrscience program
    NSString* program = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    
    // Convert to lower case
    program = [program lowercaseString];

    // Split into lines
    NSArray* lines = [program componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"\n;"]];
    NSMutableArray* outputLines = [[NSMutableArray alloc] init];
    
    // Get rid of cruft (comment lines, space at start of lines, comments at end of line)
    for (NSString* line in lines) {
        line = [line stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        NSArray* array = [line componentsSeparatedByString:@"//"];
        if (!array || ![array count])
            continue;
            
        line = [array objectAtIndex:0];
            
        if ([line hasPrefix:@"//"])
            continue;
            
        [outputLines addObject:line];
    }
    
    // Construct the program descriptor
    m_programDescriptor = [[NSMutableDictionary dictionaryWithObjectsAndKeys:
                            [NSMutableArray array], @"program",
                            @"Solve", @"title",
                            @"Root Finder", @"description",
                            @"Math", @"category",
                            [NSNumber numberWithInt:0], @"currentFunction",
                            [NSNumber numberWithInt:0], @"currentInstruction",
                            nil] retain];
                            
    // Fill in the program
    NSDictionary* function;
    
    for (NSString* line in outputLines) {
        NSArray* array = [line componentsSeparatedByString:@":"];
        assert(array && [array count]);
            
        BOOL func = [[array objectAtIndex:0] isEqualToString:@"func"];
        
        if (func || [[array objectAtIndex:0] isEqualToString:@"proc"]) {
            if (function)
                NSLog(@"*** Error: Nested func or proc not allowed\n");
            else if ([array count] != 2)
                NSLog(@"*** Error: No name for func or proc\n");
            else {
                function = makeFunction([array objectAtIndex:1], func ? 0 : -1);
                continue;
            }
            
            function = nil;
        }
        else if ([[array objectAtIndex:0] isEqualToString:@"end"]) {
            if (!function)
                NSLog(@"*** Error: End with no matching func or proc\n");
            else {
                [[m_programDescriptor objectForKey:@"program"] addObject:function];
                function = nil;
            }
        }
        else if ([[array objectAtIndex:0] isEqualToString:@"desc"]) {
            if (function)
                NSLog(@"*** Error: desc must be outside func or proc\n");
            else
                [m_programDescriptor setObject:[array objectAtIndex:1] forKey:@"description"];
        }
        else if ([[array objectAtIndex:0] isEqualToString:@"title"]) {
            if (function)
                NSLog(@"*** Error: title must be outside func or proc\n");
            else
                [m_programDescriptor setObject:[array objectAtIndex:1] forKey:@"title"];
        }
        else if ([[array objectAtIndex:0] isEqualToString:@"category"]) {
            if (function)
                NSLog(@"*** Error: category must be outside func or proc\n");
            else
                [m_programDescriptor setObject:[array objectAtIndex:1] forKey:@"category"];
        }
        else {
            if (!function)
                NSLog(@"*** Instruction not inside func or proc\n");
            else
                [[function objectForKey:@"inst"] addObject:line];
        }
    }
    
    return self;
}


- (id)init
{
    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    NSString* currentCategory = [defaults valueForKey:@"currentCategory"];
    NSString* currentTitle = [defaults valueForKey:@"currentTitle"];
    [self loadProgram:currentTitle withCategory:currentCategory];
    if (!m_programDescriptor) {
        m_programDescriptor = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                [NSMutableArray array], @"program",
                                [NSString string], @"title",
                                [NSString string], @"description",
                                [NSString string], @"category",
                                [NSNumber numberWithInt:0], @"currentFunction",
                                [NSNumber numberWithInt:0], @"currentInstruction",
                                nil];
        [self addFunction];
        [self saveProgram];
    }
    
    [m_programDescriptor retain];

    return self;
}

- (void)dealloc
{
    [self saveProgram];
    [m_programDescriptor release];
    [super dealloc];
}

- (int)findFreeUserKey
{
    for (int key = 1; key <= 8; ++key) {
        BOOL foundKey = NO;
        
        for (NSDictionary* func in self.program) {
            if ([[func objectForKey:@"key"] intValue] == key) {
                foundKey = YES;
                break;
            }
        }
        
        if (!foundKey)
            return key;
    }
    
    return -1;
}

- (void)nameCurrentSubroutine:(int) reg
{
    NSDictionary* func = [self.program objectAtIndex:self.currentFunction];
    [func setValue:[NSNumber numberWithInt:-1] forKey:@"key"];
    [func setValue:[NSNumber numberWithInt:reg] forKey:@"name"];
    [self makeProgramDirty];
}

- (BOOL)canAssignUserKey
{
    return [self findFreeUserKey] > 0;
}

- (void)nameCurrentFunction:(NSString*) name
{
    int newKey = -1;
    NSDictionary* func = [self.program objectAtIndex:self.currentFunction];
    
    if ([name length] == 0) {
        // Wants it to be an anonymous function
        newKey = 0;
    }
    else if ([[func objectForKey:@"key"] intValue] <= 0) {
        newKey = [self findFreeUserKey];
        assert(newKey > 0);
    }
    
    [func setValue:[NSNumber numberWithInt:newKey] forKey:@"key"];
    [func setValue:(newKey == 0) ? @"" : name forKey:@"name"];
    [self makeProgramDirty];
}

- (void)addFunction
{
    // Add a new anonymous function before the current function. 
    // If we are on the last instruction of the function, add it after
    if ([self.program count] == 0) {
        [(NSMutableArray*) self.program addObject:makeFunction(@"", 0)];
        self.currentFunction = 0;
    }
    else {
        NSMutableArray* inst = [[self.program objectAtIndex:self.currentFunction] objectForKey:@"inst"];
        if (self.currentInstruction >= [inst count] - 1) {
            // add it after
            self.currentFunction++;
        }
        
        if (self.currentFunction >= [self.program count])
            [(NSMutableArray*) self.program addObject:makeFunction(@"", 0)];
        else
            [(NSMutableArray*) self.program insertObject:makeFunction(@"", 0) atIndex:self.currentFunction];
    }
        
    self.currentInstruction = 0;
    [self makeProgramDirty];
}

- (void)addInstructionString:(NSString*) instruction
{
    if (!instruction)
        return;
        
    if (self.currentFunction >= [self.program count]) {
        // Create a new anonymous function
        [self addFunction];
    }
    
    NSMutableArray* inst = [[self.program objectAtIndex:self.currentFunction] objectForKey:@"inst"];
    [inst insertObject:instruction atIndex:self.currentInstruction++];
    [self makeProgramDirty];
}

- (void)selectFunction:(NSUInteger) func instruction:(NSUInteger) inst
{
    self.currentFunction = func;
    self.currentInstruction = inst;
}

- (void)currentFunctionName:(NSString**) name key:(int*) key
{
    NSDictionary* func = [self.program objectAtIndex:self.currentFunction];
    *name = [func objectForKey:@"name"];
    *key = [[func objectForKey:@"key"] intValue];
}

- (NSString*)functionNameForKey:(int) key
{
    if (key <= 0 || key > 9)
        return nil;
        
    for (NSDictionary* func in self.program)
        if ([[func objectForKey:@"key"] intValue] == key)
            return [func objectForKey:@"name"];
    
    return nil;
}

- (void)deleteCurrentFunction
{
    [(NSMutableArray*) self.program removeObjectAtIndex:self.currentFunction];
    if ([self.program count] == 0)
        [self addFunction];
    else if (self.currentFunction >= [self.program count])
        self.currentFunction = [self.program count] - 1;
    
    self.currentInstruction = 0;
    [self makeProgramDirty];
}

- (void)deleteCurrentInstruction
{
    NSMutableArray* inst = [[self.program objectAtIndex:self.currentFunction] objectForKey:@"inst"];
    
    // Don't delete the last (blank) instruction
    if (self.currentInstruction < [inst count] - 1) {
        [inst removeObjectAtIndex:self.currentInstruction];
        [self makeProgramDirty];
    }
}

- (NSArray*)instructionsForSubr:(int) reg function:(NSUInteger*) function
{
    NSUInteger fun = 0;
    for (NSDictionary* func in self.program) {
        if ([[func objectForKey:@"key"] intValue] < 0 && [[func objectForKey:@"name"] intValue] == reg) {
            *function = fun;
            return [func objectForKey:@"inst"];
        }
        fun++;
    }
    return nil;
}

- (void)clear
{
    [[m_programDescriptor objectForKey:@"program"] removeAllObjects];
    [self selectFunction:0 instruction:0];
    self.title = @"";
    self.category = @"";
    self.description = @"";
    [self addFunction];
}

- (NSString*)programToPropertyListString
{
    NSString* error;
    NSData* data = [NSPropertyListSerialization dataFromPropertyList:m_programDescriptor format:NSPropertyListXMLFormat_v1_0 errorDescription:&error];
    return [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];
}

- (void)cleanup
{
    [self saveProgram];
}

+ (NSDictionary*)detailsForProgram:(NSString*) title withCategory:(NSString*)category
{
    if ([category isEqualToString:uncategorizedName])
        category = @"";
        
    return [ProgramStore loadProgramDescriptor:title withCategory:category];
}

- (void)setProgramDescriptor:(NSDictionary*) program
{
    [self saveProgram];
    m_programDescriptorDirty = NO;

    [m_programDescriptor release];
    m_programDescriptor = [[NSMutableDictionary alloc] init];
    [m_programDescriptor setDictionary:program];
    [self makeProgramDirty];
}

+ (void)addTitle:(NSString*) title category:(NSString*) category toProgramListDictionary:(NSMutableDictionary*) dictionary
{
    if ([title isEqualToString:@"_unnamedProgram"])
        return;
        
    NSMutableArray* array = [dictionary objectForKey:category];
    if (!array) {
        [dictionary setObject:[[[NSMutableArray alloc] init] autorelease] forKey:category];
        array = [dictionary objectForKey:category];
    }
        
    [array addObject:title];
}

+ (void)fillProgramListDictionary:(NSMutableDictionary*) dictionary forPath:(NSString*) path
{
    NSString* category = [NSString stringWithString:[path lastPathComponent]];
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSArray* directory = [fileManager contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString* directoryPath in directory)
        [self addTitle:[directoryPath lastPathComponent] category:category toProgramListDictionary:dictionary];
}

+ (void)addTitles:(NSArray*) titles forCategory:(NSString*) category toProgramList:(NSMutableArray*) list
{
    NSArray* orderedTitles = [titles sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    NSDictionary* dictionary = [NSDictionary dictionaryWithObjectsAndKeys:category, @"category", orderedTitles, @"array", nil];
    [list addObject:dictionary];
}

+ (NSArray*)programList
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    
    // Get the list of programs
    NSArray* documentDirectory = [fileManager contentsOfDirectoryAtPath:path error:nil];
    NSMutableDictionary* categoryDictionary = [[NSMutableDictionary alloc] init];
    [categoryDictionary setObject:[[[NSMutableArray alloc] init] autorelease] forKey:uncategorizedName];
    
    // For each file add an entry to the Uncategorized dictionary. For each directory, add a dictionary for that category
    for (NSString* directoryPath in documentDirectory) {
        BOOL directory;
        NSString* itemPath = [path stringByAppendingPathComponent:directoryPath];
        if ([fileManager fileExistsAtPath:itemPath isDirectory:&directory]) {
            if (directory)
                [self fillProgramListDictionary:categoryDictionary forPath:itemPath];
            else if (![directoryPath isEqualToString:@".DS_Store"])
                [self addTitle:directoryPath category:uncategorizedName toProgramListDictionary:categoryDictionary];
        }
    }
    
    // Construct the list
    NSMutableArray* list = [[[NSMutableArray alloc] init] autorelease];
    
    // Add Uncategorized if needed
    NSArray* titles = [categoryDictionary objectForKey:uncategorizedName];
    if ([titles count] > 0)
        [self addTitles:titles forCategory:uncategorizedName toProgramList:list];
        
    // Add the rest in alphabetical order
    NSArray* orderedList = [[categoryDictionary allKeys] sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    
    for (NSString* category in orderedList) {
        if ([category isEqualToString:uncategorizedName])
            continue;
            
        titles = [categoryDictionary objectForKey:category];
        if ([titles count] > 0)
            [self addTitles:titles forCategory:category toProgramList:list];
    }

    return list;
}

@end
