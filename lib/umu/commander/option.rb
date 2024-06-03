# vim: set nu ai sw=4 ts=4 :
# coding: utf-8
# frozen_string_literal: true

module Umu

module Commander

module_function

	def parse_option(args, init_pref)
		ASSERT.kind_of args,		::Array
		ASSERT.kind_of init_pref,	E::Preference

		_, final_pref, file_names = args.inject(
			[:wait_opt,	init_pref,	[]]
		) {
			|(state,	pref,		names), arg|
			ASSERT.kind_of state,	::Symbol
			ASSERT.kind_of pref,	E::Preference
			ASSERT.kind_of names,	::Array
			ASSERT.kind_of arg,		::String

			case state
			when :wait_opt
				if /^-/ =~ arg
					case arg
					when '-i'
						[
							state,
							pref.update_interactive_mode(true),
							names
						]
					when '-t'
						[
							state,
							pref.update_trace_mode(true),
							names
						]
					else
						raise X::CommandError.new(
									"Unknown option: '%s'", arg
								)
					end
				else
					[:skip, pref, names + [arg]]
				end
			when :skip
				[:skip, pref, names + [arg]]
			else
				ASSERT.abort "Unknown state: #{state.inspect}"
			end
		}

		pair = [final_pref, file_names]
		ASSERT.tuple_of pair, [E::Preference, ::Array]
	end
end # Umu::Commander

end # Umu
