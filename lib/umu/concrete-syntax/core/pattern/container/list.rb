require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

class List < Abstraction::Abstract
	alias		pats array
	attr_reader	:opt_last_pat


	def initialize(pos, pats, opt_last_pat)
		ASSERT.kind_of		pats,			::Array
		ASSERT.opt_kind_of	opt_last_pat,	Variable
		ASSERT.assert (if pats.empty? then opt_last_pat.nil? else true end)

		init_hash = if opt_last_pat
						{opt_last_pat.var_sym => true}
					else
						{}
					end

		pats.reject(&:wildcard?).inject(init_hash) do |hash, vpat|
			ASSERT.kind_of vpat,	Variable
			ASSERT.kind_of hash,	::Hash

			hash.merge(vpat.var_sym => true) { |key, _, _|
				raise X::SyntaxError.new(
					pos,
					"Duplicated pattern variable: '%s'", key.to_s
				)
			}
		end

		super(pos, pats)

		@opt_last_pat = opt_last_pat
	end


	def to_s
		format("[%s%s]",
			self.map(&:to_s).join(', '),

			if self.opt_last_pat
				'|' + self.opt_last_pat.to_s
			else
				''
			end
		)
	end


	def exported_vars
		(self.pats + [self.opt_last_pat]).reject(&:wildcard?).inject([]) {
			|array, vpat|
			ASSERT.kind_of array,	::Array
			ASSERT.kind_of vpat,	Variable

			array + vpat.exported_vars
		}.freeze
	end


private

	def __desugar_value__(expr, env, _event)
		ASSERT.kind_of expr, SACE::Abstract

		if self.pats.empty?
			SACD.make_value self.pos, WILDCARD, expr
		else
			SACD.make_declarations self.pos, __desugar__(expr, env)
		end
	end


	def __desugar_lambda__(seq_num, env, _event)
		ASSERT.kind_of seq_num, ::Integer

		var_sym = __gen_sym__ seq_num

		if self.pats.empty?
			SCCP.make_result(
				SACE.make_identifier(self.pos, WILDCARD),
				[]
			)
		else
			SCCP.make_result(
				SACE.make_identifier(self.pos, var_sym),
				__desugar__(SACE.make_identifier(self.pos, var_sym), env)
			)
		end
	end


	def __desugar__(expr, _env)
		ASSERT.kind_of expr, SACE::Abstract

		head_vpat, *tail_pats = self.pats
		ASSERT.kind_of head_vpat, Variable

		init_pos = head_vpat.pos

		init_seq_num = 1

		init_pair_sym = __gen_pair_sym__ init_seq_num

		init_decls = [
			SACD.make_value(
				init_pos,
				init_pair_sym,
				__make_send_des__(init_pos, expr)
			),

			SACD.make_value(
				init_pos,
				head_vpat.var_sym,
				__make_select_head__(init_pos, init_pair_sym)
			)
		]

		_final_seq_num, final_pair_sym, final_decls = tail_pats.inject(
			 [init_seq_num, init_pair_sym, init_decls]
		) {
			|(seq_num,      pair_sym,      decls     ), vpat|
			ASSERT.kind_of seq_num,		::Integer
			ASSERT.kind_of pair_sym,	::Symbol
			ASSERT.kind_of decls,		::Array
			ASSERT.kind_of vpat,		Variable

			pos				= vpat.pos
			next_seq_num	= seq_num + 1
			next_pair_sym	= __gen_pair_sym__ next_seq_num
			tail_list_expr	= __make_select_tail__ pos, pair_sym

			next_decls = (
					decls
				) + (
					if vpat.wildcard?
						[
							SACD.make_value(
								pos,
								next_pair_sym,
								SACE.make_send(
									pos,
									__make_send_des__(pos, tail_list_expr),
									[SACE.make_number_selector(pos, 2)]
								)
							)
						]
					else
						[
							SACD.make_value(
								pos,
								next_pair_sym,
								__make_send_des__(pos, tail_list_expr)
							),

							SACD.make_value(
								pos,
								vpat.var_sym,
								__make_select_head__(pos, next_pair_sym)
							)

						]
					end
				)

			[next_seq_num, next_pair_sym, next_decls]
		}

		(
			final_decls
		) + (
			if self.opt_last_pat
				last_pat = self.opt_last_pat

				[
					SACD.make_value(
						last_pat.pos,
						last_pat.var_sym,
						__make_select_tail__(last_pat.pos, final_pair_sym)
					)
				]
			else
				[]
			end
		)
	end


	def __gen_pair_sym__(num)
		ASSERT.kind_of num, ::Integer

		format("%%p%d", num).to_sym
	end


	def __make_send_des__(pos, expr)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of expr, SACE::Abstract

		SACE.make_send pos, expr, [SACE.make_method(pos, :des, [])]
	end


	def __make_select_by_number__(pos, var_sym, sel_num)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of var_sym,	::Symbol
		ASSERT.kind_of sel_num,	::Integer

		SACE.make_send(
			pos,
			SACE.make_identifier(pos, var_sym),
			[SACE.make_number_selector(pos, sel_num)]
		)
	end


	def __make_select_head__(pos, var_sym)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of var_sym,	::Symbol

		__make_select_by_number__ pos, var_sym, 1
	end


	def __make_select_tail__(pos, var_sym)
		ASSERT.kind_of pos,		L::Position
		ASSERT.kind_of var_sym,	::Symbol

		__make_select_by_number__ pos, var_sym, 2
	end
end

end	# Umu::ConcreteSyntax::Core::Pattern::Container


module_function

	def make_list(pos, pats, opt_last_pat)
		ASSERT.kind_of		pos,			L::Position
		ASSERT.kind_of		pats,			::Array
		ASSERT.opt_kind_of	opt_last_pat,	Variable

		Container::List.new(pos, pats.freeze, opt_last_pat).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
