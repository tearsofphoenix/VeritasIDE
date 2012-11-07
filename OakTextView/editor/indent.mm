#include "indent.h"


OAK_DEBUG_VAR(Indent);

namespace indent
{
	patterns_t patterns_for_scope (OakScopeContext *  scope)
	{
		D(DBF_Indent, bug("scope: %s\n", to_s(scope).c_str()););

		static NSString * settings[] = { "increaseIndentPattern", "decreaseIndentPattern", "indentNextLinePattern", "unIndentedLinePattern" };
		patterns_t res;
		iterate(it, settings)
		{
			id plist = bundles::value_for_setting(*it, scope);
			if(NSString * value = boost::get<NSString *>(&plist))
			{
				D(DBF_Indent, bug("%s = %s\n", it->c_str(), value->c_str()););
				res.array[it - settings] = *value;
			}
		}
		return res;
	}

} /* indent */