require 'umu/common'


module Umu

module Environment

module Context

module Type

ROOT_CLASS = VC::Top
META_CLASS = VC::Class


CLASSES = ::ObjectSpace.each_object(::Class).select {
	|klass|

	klass <= ROOT_CLASS
}.sort { |a, b|
	a.to_s <=> b.to_s
}.each_with_index.sort { |(a, ord_a), (b, ord_b)|
	result = a <=> b

	if result
		result * -1
	else
		ord_a <=> ord_b
	end
}.map { |a, _ord|
	ASSERT.subclass_of a, VC::Top
}.freeze


def update_method_info_of_symbol(info_of_symbol, infos, klass)
	ASSERT.kind_of		info_of_symbol,	::Hash
	ASSERT.kind_of		infos,			::Array
	ASSERT.subclass_of	klass,			VC::Top

	info_of_symbol.merge(
		infos.inject({}) { |hash, info|
			ASSERT.kind_of info, ::Array

			meth_sym, ret_class, sym, *_param_classes = info
			ASSERT.kind_of		meth_sym,	::Symbol
			ASSERT.subclass_of	ret_class,	VC::Top
			ASSERT.kind_of		sym,		::Symbol

			hash.merge(sym => info) {
				ASSERT.abort(
					"In class: %s, " +
					"duplicated a method symbol: %s",
					klass.type_sym, method_sym
				)
			}
		}
	) { |sym, sub_info, sup_info|
		sub_meth_sym, sub_ret_class,
			_sub_sym, *sub_param_classes = sub_info
		sup_meth_sym, sup_ret_class,
			_sup_sym, *sup_param_classes = sup_info

		ASSERT.assert(sub_meth_sym == sup_meth_sym)

		ASSERT.assert(
			sub_param_classes.size == sup_param_classes.size
		)

		ASSERT.assert(
			sub_ret_class <= sup_ret_class,

			[
				format("Class: %s", klass.inspect),
				format("  Method: %s", sym),
				format("  Super:"),
				format("    Return: %s", sup_ret_class),
				format("    Param: [%s]",
						sup_param_classes.map(
							&:inspect
						).join(', ')
					),
				format("  Sub:"),
				format("    Return: %s", sub_ret_class),
				format("    Param: [%s]",
						sub_param_classes.map(
							&:inspect
						).join(', ')
					),
			].join("\n")
		)

		sub_param_classes.zip(sup_param_classes).each do
			|sub_param_class, sup_param_class|
			ASSERT.subclass_of sub_param_class,	VC::Top
			ASSERT.subclass_of sup_param_class,	VC::Top

			ASSERT.assert(
				sub_param_class <= sup_param_class
			)
		end

		sub_info
	}
end

module_function :update_method_info_of_symbol


CLASS_SPECS = CLASSES.map { |klass|
	ASSERT.subclass_of	klass, VC::Top

	class_method_info_of_symbol,
	instance_method_info_of_symbol = if klass <= META_CLASS
		[{}, {}]
	else
		loop.inject(
			 [{},					{},					klass]
		) {
			|(cmeth_info_of_sym,	imeth_info_of_sym,	k), _|

			unless k <= ROOT_CLASS
				break [cmeth_info_of_sym, imeth_info_of_sym]
			end

			[
				update_method_info_of_symbol(
					cmeth_info_of_sym, k.class_method_infos, k
				),

				update_method_info_of_symbol(
					imeth_info_of_sym, k.instance_method_infos, k
				),

				k.superclass
			]
		}
	end

	ECTS.make_class(
		klass,
		klass.type_sym,
		class_method_info_of_symbol,
		instance_method_info_of_symbol
	)
}
CLASS_SPECS.freeze


=begin
CLASS_SPECS.each do |spec|
	printf "==== %s : %s ====\n", spec.symbol, spec.klass
	p spec
	puts
end
exit
=end

SPEC_OF_CLASS, SPEC_OF_SYMBOL = CLASS_SPECS.inject(
	 [{},				{}]
	) {
	|(spec_of_class,	spec_of_symbol), spec|
	ASSERT.kind_of spec_of_class,	::Hash
	ASSERT.kind_of spec_of_symbol,	::Hash
	ASSERT.kind_of spec,			ECTSC::Base

	[
		spec_of_class.merge(spec.klass => spec) {
			ASSERT.abort "Duplicated a class: %s", spec.klass.to_s
		},

		spec_of_symbol.merge(spec.symbol => spec) {
			ASSERT.abort "Duplicated a symbol: %s", spec.symbol.to_s
		}
	]
}
SPEC_OF_CLASS.freeze
SPEC_OF_SYMBOL.freeze


SUPERCLASS_OF_SUBCLASS, SUBCLASSES_OF_SUPERCLASS = CLASSES.inject(
	 [{},					{}]
) {
	|(supspec_of_subspec,	subspecs_of_supspec), subclass|
	ASSERT.kind_of		supspec_of_subspec,		::Hash
	ASSERT.kind_of		subspecs_of_supspec,	::Hash
	ASSERT.subclass_of	subclass,				VC::Top

	if subclass < ROOT_CLASS
		subspec = SPEC_OF_CLASS[subclass]
		supspec = SPEC_OF_CLASS[subclass.superclass]
		ASSERT.kind_of subspec, ECTSC::Base
		ASSERT.kind_of supspec, ECTSC::Base

		[
			supspec_of_subspec.merge(subspec => supspec) {
				|spec, _, _|

				ASSERT.abort(
					"Duplicated a class specification: %s", spec.inspect
				)
			},
			
			subspecs_of_supspec.merge(supspec => ECTS.make_set([subspec])) {
				|_, old_set_of_spec, new_set_of_spec|

				old_set_of_spec.union new_set_of_spec
			}
		]
	else
		[
			supspec_of_subspec,

			subspecs_of_supspec
		]
	end
}.freeze
SUPERCLASS_OF_SUBCLASS.freeze
SUBCLASSES_OF_SUPERCLASS.freeze


ANCESTORS_OF_DESCENDANT, DESCENDANTS_OF_ANCESTOR = CLASS_SPECS.inject(
	 [{},						{}]
) {
	|(ancestors_of_descendant,	descendants_of_ancestor), descendant|
	ASSERT.kind_of ancestors_of_descendant,	::Hash
	ASSERT.kind_of descendants_of_ancestor,	::Hash
	ASSERT.kind_of descendant,				ECTSC::Base

	ancestors, _ = loop.inject([[], descendant]) { |(specs, spec), _|
		ASSERT.kind_of specs,	::Array
		ASSERT.kind_of spec,	ECTSC::Base

		opt_supspec = SUPERCLASS_OF_SUBCLASS[spec]
		ASSERT.opt_kind_of opt_supspec, ECTSC::Base

		if opt_supspec
			[specs + [opt_supspec], opt_supspec]
		else
			break [specs, nil]
		end
	}

	[
		ancestors_of_descendant.merge(
			descendant => ECTS.make_set(ancestors)
		) { |spec, _, _|

			ASSERT.abort(
				"Duplicated a class specification: %s", spec.inspect
			)
		},

		descendants_of_ancestor.merge(
			ancestors.inject({}) { |hash, ancestor|
				hash.merge(ancestor => ECTS.make_set([descendant])) {
					|spec, _, _|

					ASSERT.abort("Duplicated a class specification: %s",
									spec.inspect
					)
				}
			}
		) { |_, old_set_of_spec, new_set_of_spec|
			old_set_of_spec.union new_set_of_spec
		}
	]
}.freeze
ANCESTORS_OF_DESCENDANT.freeze
DESCENDANTS_OF_ANCESTOR.freeze



class Entry
	def classes
		CLASSES
	end


	def class_specs
		CLASS_SPECS
	end


	def class_spec_of(value)
		ASSERT.kind_of value, VC::Top

		spec = if value.kind_of?(META_CLASS)
					ECTS.make_metaclass value.class_spec
				else
					self.spec_of_class value.class
				end

		ASSERT.kind_of spec, ECTSC::Abstract
	end


	def spec_of_class(klass)
		ASSERT.subclass_of klass, VC::Top

		ASSERT.kind_of SPEC_OF_CLASS[klass], ECTSC::Base
	end


	def root_class_spec
		ASSERT.kind_of self.spec_of_class(ROOT_CLASS), ECTSC::Base
	end


	def lookup(sym, pos, env)
		ASSERT.kind_of sym,	::Symbol
		ASSERT.kind_of pos,	L::Position
		ASSERT.kind_of env,	E::Entry

		spec = SPEC_OF_SYMBOL[sym]

		unless spec
			raise X::NameError.new(
				pos,
				env,
				"Unbound type identifier: '%s'", sym.to_s
			)
		end

		ASSERT.kind_of spec, ECTSC::Base
	end


	def test_kind_of?(lhs_value, rhs_spec)
		ASSERT.kind_of lhs_value,	VC::Top
		ASSERT.kind_of rhs_spec,	ECTSC::Base

		lhs_spec = self.class_spec_of lhs_value
		ASSERT.kind_of lhs_spec, ECTSC::Abstract

		result = (
					lhs_spec.kind_of? ECTSC::Base
				) && (
					if lhs_spec == rhs_spec
						true
					else
						rhs_specs = self.descendants_of rhs_spec
						ASSERT.kind_of rhs_specs, ECTS::SetOfClass

						rhs_specs.member? lhs_spec
					end
				)
		ASSERT.bool result
	end


	def opt_superclass_of(subclass)
		ASSERT.kind_of subclass, ECTSC::Base

		ASSERT.opt_kind_of subclass.opt_superclass, ECTSC::Base
	end


	def subclasses_of(superclass)
		ASSERT.kind_of superclass, ECTSC::Base

		ASSERT.kind_of superclass.subclasses, ECTS::SetOfClass
	end


	def ancestors_of(descendant)
		ASSERT.kind_of descendant, ECTSC::Base

		ASSERT.kind_of descendant.ancestors, ECTS::SetOfClass
	end


	def descendants_of(ancestor)
		ASSERT.kind_of ancestor, ECTSC::Base

		ASSERT.kind_of ancestor.descendants, ECTS::SetOfClass
	end
end


BUILTIN = Entry.new.freeze

# BUILTIN.print



module_function

	def make
		BUILTIN
	end

end	# Umu::Environment::Context::Type

end	# Umu::Environment::Context

end	# Umu::Environment

end	# Umu
