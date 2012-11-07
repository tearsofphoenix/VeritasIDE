#include "path_info.h"




#include <text/tokenize.h>

#include <CoreServices/CoreServices.h>

#import <Foundation/Foundation.h>

//	struct attribute_rule_t
//	{
//		NSString * attribute;
//		path::glob_t glob;
//		NSString * group;
//	};


static NSArray *attribute_specifiers (void)
{
    static NSString * DefaultScopeAttributes =
    @"{ rules = ("
    "	{ attribute = 'attr.scm.svn';       glob = '.svn';           group = 'scm';   },"
    "	{ attribute = 'attr.scm.hg';        glob = '.hg';            group = 'scm';   },"
    "	{ attribute = 'attr.scm.git';       glob = '.git';           group = 'scm';   },"
    "	{ attribute = 'attr.scm.p4';        glob = '.p4config';      group = 'scm';   },"
    "	{ attribute = 'attr.project.ninja'; glob = 'build.ninja';    group = 'build'; },"
    "	{ attribute = 'attr.project.make';  glob = 'Makefile';       group = 'build'; },"
    "	{ attribute = 'attr.project.xcode'; glob = '*.xcodeproj';    group = 'build'; },"
    "	{ attribute = 'attr.project.rake';  glob = 'Rakefile';       group = 'build'; },"
    "	{ attribute = 'attr.project.ant';   glob = 'build.xml';      group = 'build'; },"
    "	{ attribute = 'attr.project.cmake'; glob = 'CMakeLists.txt'; group = 'build'; },"
    "	{ attribute = 'attr.project.maven'; glob = 'pom.xml';        group = 'build'; },"
    "	{ attribute = 'attr.project.scons'; glob = 'SConstruct';     group = 'build'; },"
    "); }";
    
    std::vector<attribute_rule_t> res;
    ///TODO
    //
    //parse_rules(plist::load(path::join(path::home(), "Library/Application Support/TextMate/ScopeAttributes.plist")), back_inserter(res));
    //parse_rules(plist::parse_ascii(DefaultScopeAttributes), back_inserter(res));
    return res;
}

static void directory_attributes (NSString * dir, std::vector<NSString *>& res)
{
    if(dir == NULL_STR || dir == "" || dir[0] != '/')
        return;
    
    std::set<NSString *> groups;
    for(NSString * cwd = dir; cwd != "/"; cwd = path::parent(cwd))
    {
        auto entries = path::entries(cwd);
        
        static std::vector<attribute_rule_t> const specifiers = attribute_specifiers();
        iterate(specifier, specifiers)
        {
            if(groups.find(specifier->group) != groups.end())
                continue;
            
            iterate(entry, entries)
            {
                if(specifier->glob.does_match((*entry)->d_name))
                {
                    res.push_back(specifier->attribute);
                    if(specifier->group != NULL_STR)
                    {
                        groups.insert(specifier->group);
                        break;
                    }
                }
            }
        }
    }
}

static void scm_attributes (NSString * path, NSString * dir, std::vector<NSString *>& res)
{
    if(scm::info_ptr info = scm::info(dir))
    {
        NSString * branch = info->branch();
        if(branch != NULL_STR)
            res.push_back("attr.scm.branch." + branch);
        
        if(path != NULL_STR)
        {
            OakSCMStatus status = info->status(path);
            if(status != scm::status::unknown)
                res.push_back("attr.scm.status." + to_s(status));
        }
    }
}

NSString * path_attributes (NSString * path, NSString * dir)
{
    std::vector<NSString *> res;
    if(path != NULL_STR)
    {
        std::vector<NSString *> revPath;
        citerate(token, text::tokenize(path.begin(), path.end(), '/'))
        {
            NSString * tmp = *token;
            citerate(subtoken, text::tokenize(tmp.begin(), tmp.end(), '.'))
            {
                if((*subtoken).empty())
                    continue;
                revPath.push_back(*subtoken);
                std::replace(revPath.back().begin(), revPath.back().end(), ' ', '_');
            }
        }
        revPath.push_back("rev-path");
        revPath.push_back("attr");
        std::reverse(revPath.begin(), revPath.end());
        res.push_back(text::join(revPath, "."));
    }
    else
    {
        res.push_back("attr.untitled");
    }
    
    SInt32 major, minor, bugFix;
    Gestalt(gestaltSystemVersionMajor,  &major);
    Gestalt(gestaltSystemVersionMinor,  &minor);
    Gestalt(gestaltSystemVersionBugFix, &bugFix);
    res.push_back(text::format("attr.os-version.%zd.%zd.%zd", (ssize_t)major, (ssize_t)minor, (ssize_t)bugFix));
    
    NSString * parentDir = dir == NULL_STR ? path::parent(path) : dir;
    directory_attributes(parentDir, res);
    scm_attributes(path, parentDir, res);
    
    res.push_back(settings_for_path(path, text::join(res, " "), parentDir).get(kSettingsScopeAttributesKey, ""));
    res.erase(std::remove(res.begin(), res.end(), ""), res.end());
    return text::join(res, " ");
}

NSDictionary *variables (NSString * path)
{
    NSMutableDictionary *map = [NSMutableDictionary dictionary];
    // map["TM_DOCUMENT_UUID"] = to_s(identifier());
    if(path)
    {
        map["TM_DISPLAYNAME"] = path::display_name(path);
        map["TM_FILEPATH"]    = path;
        map["TM_FILENAME"]    = path::name(path);
        map["TM_DIRECTORY"]   = path::parent(path);
        map["PWD"]            = path::parent(path);
        
        if(scm::info_ptr info = scm::info(path::parent(path)))
        {
            NSString * branch = info->branch();
            if(branch != NULL_STR)
                map["TM_SCM_BRANCH"] = branch;
            
            NSString * name = info->scm_name();
            if(name != NULL_STR)
                map["TM_SCM_NAME"] = name;
        }
    }
    else
    {
        map["TM_DISPLAYNAME"] = "untitled";
    }
    return variables_for_path(path, "", map);
}
