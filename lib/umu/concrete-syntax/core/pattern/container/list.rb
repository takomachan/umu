require 'umu/common'


module Umu

module ConcreteSyntax

module Core

module Pattern

module Container

class List < Abstraction::Abstract
	alias		pats array
	attr_reader	:opt_last_pat


	def initialize(loc, pats, opt_last_pat)
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
					loc,
					"Duplicated pattern variable: '%s'", key.to_s
				)
			}
		end

		super(loc, pats)

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
			SACD.make_value self.loc, WILDCARD, expr, :Nil
		else
			SACD.make_declarations self.loc, __desugar__(expr, env)
		end
	end


	def __desugar_lambda__(seq_num, env, _event)
		ASSERT.kind_of seq_num, ::Integer

		var_sym = __gen_sym__ seq_num

		if self.pats.empty?
			SCCP.make_result(
				SACE.make_identifier(self.loc, WILDCARD),
				[],
				:Nil
			)
		else
			SCCP.make_result(
				SACE.make_identifier(self.loc, var_sym),
				__desugar__(SACE.make_identifier(self.loc, var_sym), env),
				:Cons
			)
		end
	end


	def __desugar__(expr, _env)
		ASSERT.kind_of expr, SACE::Abstract

		head_vpat, *tail_pats = self.pats
		ASSERT.kind_of head_vpat, Variable

		init_loc = head_vpat.loc

		init_seq_num = 1

		init_pair_sym = __gen_pair_sym__ init_seq_num

		init_decls = [
			SACD.make_value(
				init_loc,
				init_pair_sym,
				__make_send_des__(init_loc, expr)
			),

			SACD.make_value(
				init_loc,
				head_vpat.var_sym,
				__make_select_head__(init_loc, init_pair_sym)
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

			loc				= vpat.loc
			next_seq_num	= seq_num + 1
			next_pair_sym	= __gen_pair_sym__ next_seq_num
			tail_list_expr	= __make_select_tail__ loc, pair_sym

			next_decls = (
					decls
				) + (
					if vpat.wildcard?
						[
							SACD.make_value(
								loc,
								next_pair_sym,
								SACE.make_send(
									loc,
									__make_send_des__(loc, tail_list_expr),
									SACE.make_number_selector(loc, 2)
								)
							)
						]
					else
						[
							SACD.make_value(
								loc,
								next_pair_sym,
								__make_send_des__(loc, tail_list_expr)
							),

							SACD.make_value(
								loc,
								vpat.var_sym,
								__make_select_head__(loc, next_pair_sym)
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
						last_pat.loc,
						last_pat.var_sym,
						__make_select_tail__(last_pat.loc, final_pair_sym)
					)
				]
			else
				[
					SACD.make_value(
						loc,
						WILDCARD,
						__make_select_tail__(loc, final_pair_sym),
						:Nil
					)
				]
			end
		)
	end


	def __gen_pair_sym__(num)
		ASSERT.kind_of num, ::Integer

		format("%%p%d", num).to_sym
	end


	def __make_send_des__(loc, expr)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of expr, SACE::Abstract

		SACE.make_send(
			loc, expr, SACE.make_method(loc, :des), [], :Cons
		)
	end


	def __make_select_by_number__(loc, var_sym, sel_num)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of var_sym,	::Symbol
		ASSERT.kind_of sel_num,	::Integer

		SACE.make_send(
			loc,
			SACE.make_identifier(loc, var_sym),
			SACE.make_number_selector(loc, sel_num)
		)
	end


	def __make_select_head__(loc, var_sym)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of var_sym,	::Symbol

		__make_select_by_number__ loc, var_sym, 1
	end


	def __make_select_tail__(loc, var_sym)
		ASSERT.kind_of loc,		L::Location
		ASSERT.kind_of var_sym,	::Symbol

		__make_select_by_number__ loc, var_sym, 2
	end
end

end	# Umu::ConcreteSyntax::Core::Pattern::Container


module_function

	def make_list(loc, pats, opt_last_pat)
		ASSERT.kind_of		loc,			L::Location
		ASSERT.kind_of		pats,			::Array
		ASSERT.opt_kind_of	opt_last_pat,	Variable

		Container::List.new(loc, pats.freeze, opt_last_pat).freeze
	end

end	# Umu::ConcreteSyntax::Core::Pattern

end	# Umu::ConcreteSyntax::Core

end	# Umu::ConcreteSyntax

end	# Umu
