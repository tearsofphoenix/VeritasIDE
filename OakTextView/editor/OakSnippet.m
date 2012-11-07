//
//  OakSnippet.m
//  OakAppKit
//
//  Created by tearsofphoenix on 12-11-7.
//  Copyright (c) 2012年 tearsofphoenix. All rights reserved.
//

#import "OakSnippet.h"
#import "OakTextIndent.h"
#import <OakFoundation/OakFoundation.h>

static OakDependencyGraph *build_graph (NSDictionary *fields, NSDictionary *mirrors)
{
    OakDependencyGraph *graph = [[OakDependencyGraph alloc] init];
    
    [fields enumerateKeysAndObjectsUsingBlock: (^(id key, id obj, BOOL *stop)
    {
        [graph addNode: key];
        
        iterate(otherField, fields)
        {
            if(field->second->range.contains(otherField->second->range))
                graph.add_edge(field->first, otherField->first);
        }
        
        iterate(mirror, mirrors)
        {
            if(field->second->range.contains(mirror->second->range))
                graph.add_edge(field->first, mirror->first);
        }
    }
    return graph;
}

@interface OakSnippet ()
{
    NSString *_text;
    NSMutableDictionary *_fields;
    NSMutableDictionary *_mirrors;
    NSMutableDictionary *_variables;
    NSString *_indent_string;
    OakTextIndent *_indent_info;
    
    NSUInteger _current_field;
}

@end

@implementation OakSnippet

- (NSArray *)replaceContentInRange: (OakTextRange *)range
                       withContent: (NSString *) str
{
    
}

- (void)_setup
{
    oak::dependency_graph const& graph = build_graph(fields, mirrors);
    citerate(node, graph.topological_order())
    {
        if(!forFields.empty() && forFields.find(*node) == forFields.end())
            continue;
        
        std::string const& src = fields[*node]->range.to_s(text);
        D(DBF_Snippet, bug("update mirrors of %zu (%s)\n", *node, src.c_str()););
        
        foreach(mirror, mirrors.lower_bound(*node), mirrors.upper_bound(*node))
        {
            std::string str = mirror->second->transform(src, variables);
            str = tabs_to_spaces(str, indent_info.create());
            str = format_string::replace(str, regexp::pattern_t("(?<=\n)(?!$)"), indent_string);
            D(DBF_Snippet, bug(" → %s\n", str.c_str()););
            snippet::replace(mirror->second->range, str, text, fields, mirrors);
        }
    }
}

- (void)updateMirrosWithFileds: (NSSet *)fields
{
    
}

- (NSArray *)_replaceWithCount: (NSUInteger)n
                         range: (OakTextRange *)range
                   replacement: (NSString *) replacement
{
    
}

@end
