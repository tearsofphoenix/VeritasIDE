#ifndef LOAD_GRAMMAR_H_FPR2TQML
#define LOAD_GRAMMAR_H_FPR2TQML


@class OakBundleItem;

namespace parse
{
	struct rule_t;
	struct stack_t;
	typedef std::shared_ptr<rule_t> rule_ptr;
	typedef std::shared_ptr<stack_t> stack_ptr;

	struct extern grammar_t
	{
		struct callback_t
		{
			 ~callback_t () { }
			 void grammar_did_change ();
		};

		grammar_t (OakBundleItem * grammarItem);
		~grammar_t ();

		NSUUID * uuid () const;
		stack_ptr seed () const;

		void add_callback (callback_t* cb)      { _callbacks.add(cb);    }
		void remove_callback (callback_t* cb)   { _callbacks.remove(cb); }

		void resolve_includes ();

	private:
		static void resolve_includes (rule_ptr rule, std::vector<rule_ptr>& stack);

		struct bundles_callback_t : bundles::callback_t
		{
			bundles_callback_t (grammar_t& grammar) : _grammar(grammar)
            { }
			void bundles_did_change ()
            {
                _grammar.bundles_did_change();
            }
		private:
			grammar_t& _grammar;
		};

		void bundles_did_change ();

		OakBundleItem * _item;
		NSMutableDictionary * _old_plist;
		bundles_callback_t _bundles_callback;
		oak::callbacks_t<callback_t> _callbacks;
		rule_ptr _rule;
	};

	typedef std::shared_ptr<grammar_t> grammar_ptr;
	extern grammar_ptr parse_grammar (OakBundleItem * grammarItem);

} /* parse */ 

#endif /* end of include guard: LOAD_GRAMMAR_H_FPR2TQML */
