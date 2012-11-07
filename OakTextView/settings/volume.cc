#include "volume.h"


namespace volume
{
	std::map<NSString *, volume::settings_t> settings_t::create ()
	{
		std::map<NSString *, volume::settings_t> res;
		if(CFPropertyListRef cfPlist = CFPreferencesCopyAppValue(CFSTR("volumeSettings"), kCFPreferencesCurrentApplication))
		{
			citerate(pair, plist::convert(cfPlist))
			{
				settings_t info;
				plist::get_key_path(pair->second, "extendedAttributes", info._extended_attributes);
				plist::get_key_path(pair->second, "scmBadges",          info._scm_badges);
				plist::get_key_path(pair->second, "displayNames",       info._display_names);
				res.insert(std::make_pair(pair->first, info));
			}
			CFRelease(cfPlist);
		}
		return res;
	}

	volume::settings_t  settings (NSString * path)
	{
		static std::map<NSString *, volume::settings_t> userSettings = settings_t::create();
		iterate(pair, userSettings)
		{
			if(path.find(pair->first) == 0)
				return pair->second;
		}

		static volume::settings_t defaultSettings;
		return defaultSettings;
	}

} /* volume */
