#ifndef VOLUME_H_3HE6P24J
#define VOLUME_H_3HE6P24J



namespace volume
{
	struct settings_t
	{
		bool extended_attributes () const { return _extended_attributes; }

	private:
		static std::map<NSString *, settings_t> create ();
		friend volume::settings_t  settings (NSString * path);

		bool _extended_attributes = true;
		bool _scm_badges          = true;
		bool _display_names       = true;
	};

	extern volume::settings_t  settings (NSString * path);

} /* volume */

#endif /* end of include guard: VOLUME_H_3HE6P24J */
