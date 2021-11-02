require 'umu/common'
require 'umu/lexical/position'
require 'umu/environment/preference'


module Umu

module Environment

module Tracer

class Event < Abstraction::CartesianProduct
	attr_reader :label
	attr_reader :klass
	attr_reader :pos
	attr_reader :msg


	def initialize(label, klass, pos, msg)
		ASSERT.kind_of label,	::String
		ASSERT.kind_of klass,	::Class
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of msg,		::String

		@label	= label
		@klass	= klass
		@pos	= pos
		@msg	= msg
	end


	def to_s
		format("%s:#%d:[%s] %s: %s",
					self.pos.file_name,
					self.pos.line_num,
					label,
					klass.to_s.split(/::/)[-1],
					self.msg
		)
	end
end



module_function

	def make_event(label, klass, pos, msg)
		ASSERT.kind_of label,	::String
		ASSERT.kind_of klass,	::Class
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of msg,		::String

		Event.new(label.freeze, klass, pos, msg.freeze).freeze
	end


	def trace(pref, eval_depth, label, klass, pos, msg)
		ASSERT.kind_of pref,		E::Preference
		ASSERT.kind_of eval_depth,	::Integer
		ASSERT.kind_of label,		::String
		ASSERT.kind_of klass,		::Class
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of msg,			::String
		ASSERT.assert block_given?

		if pref.trace_mode?
			STDERR.printf "%s[%s] %s: %s\n",
							'| ' * eval_depth,
							label,
							Tracer.class_to_string(klass),
							msg
		end

		object = yield Tracer.make_event(label, klass, pos, msg)

		if pref.trace_mode?
			STDERR.printf "%s--> %s: %s\n",
							'| ' * eval_depth,
							Tracer.class_to_string(object.class),
							object.to_s
		end

		object
	end


	def trace_single(pref, eval_depth, label, klass, pos, msg)
		ASSERT.kind_of pref,		E::Preference
		ASSERT.kind_of eval_depth,	::Integer
		ASSERT.kind_of label,		::String
		ASSERT.kind_of klass,		::Class
		ASSERT.kind_of pos,			L::Position
		ASSERT.kind_of msg,			::String

		if pref.trace_mode?
			STDERR.printf "%s[%s] %s: %s",
							'| ' * eval_depth,
							label,
							Tracer.class_to_string(klass),
							msg
		end

		object = yield Tracer.make_event(label, klass, pos, msg)

		if pref.trace_mode?
			STDERR.printf " --> %s: %s\n",
								Tracer.class_to_string(object.class),
								object.to_s
		end

		object
	end


	def class_to_string(klass)
		ASSERT.kind_of klass, ::Class

		_, *fully_qualified_module_names = klass.to_s.split(/::/)
		*module_names, class_name = fully_qualified_module_names

		s = if module_names.empty?
				class_name
			else
				format("%s (%s)",
						class_name,
						Tracer.abbreviate(module_names).join('::')
				)
			end

		ASSERT.kind_of s, ::String
	end


	ABBREVIATABLE_MODULE_NAMES = [
		[['Lexical'],											'L'],
		[['Lexical', 'Lexer'],									'LL'],
		[['ConcreteSyntax'],									'SC'],
		[['ConcreteSyntax',	'Module'],							'SCM'],
		[['ConcreteSyntax',	'Module',	'Declaration'],			'SCMD'],
		[['ConcreteSyntax',	'Module',	'Expression'],			'SCME'],
		[['ConcreteSyntax',	'Module',	'Pattern'],				'SCMP'],
		[['ConcreteSyntax',	'Core'],							'SCC'],
		[['ConcreteSyntax',	'Core',	'Declaration'],				'SCCD'],
		[['ConcreteSyntax',	'Core',	'Expression'],				'SCCE'],
		[['ConcreteSyntax',	'Core',	'Expression',	'Unary'],	'SCCEU'],
		[['ConcreteSyntax',	'Core',	'Expression',	'Binary'],	'SCCEB'],
		[['ConcreteSyntax',	'Core',	'Expression',	'Nary'],	'SCCEN'],
		[['ConcreteSyntax',	'Core',	'Pattern'],					'SCCP'],
		[['AbstractSyntax'],									'SA'],
		[['AbstractSyntax',	'Core'],							'SAC'],
		[['AbstractSyntax',	'Core',	'Declaration'],				'SACD'],
		[['AbstractSyntax',	'Core',	'Expression'],				'SACE'],
		[['AbstractSyntax',	'Core',	'Expression',	'Unary'],	'SACEU'],
		[['AbstractSyntax',	'Core',	'Expression',	'Binary'],	'SACEB'],
		[['AbstractSyntax',	'Core',	'Expression',	'Nary'],	'SACEN'],
		[['Value'],												'V'],
		[['Value',			'Core'],							'VC'],
		[['Value',			'Core',	'Atom'],					'VCA'],
		[['Value',			'Core',	'Atom',	'Number'],			'VCAN'],
		[['Value',			'Core',	'Product'],					'VCP'],
		[['Value',			'Core',	'Union'],					'VCU'],
		[['Value',			'Core',	'Function'],				'VCF'],
		[['Environment'],										'E']
	].sort { |(xs, _), (ys, _)| ys.size <=> xs.size }	# For longest-match

	def abbreviate(names)
		ASSERT.kind_of names, ::Array

		ABBREVIATABLE_MODULE_NAMES.each { |prefix_names, abbreviated_name|
			prefix_length = prefix_names.length

			if names.take(prefix_length) == prefix_names
				break [abbreviated_name] + names.drop(prefix_length)
			else
				names
			end
		}
	end

end # Umu::Environment::Tracer

end # Umu::Environment

end # Umu