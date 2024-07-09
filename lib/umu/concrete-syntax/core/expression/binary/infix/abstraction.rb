# coding: utf-8
# frozen_string_literal: true



unless ::Object.new.respond_to?(:then)	# Ruby 2.5 or after
	class ::Object
		def then
			yield self
		end
	end
end



module Umu

module ConcreteSyntax

module Core

module Expression

module Binary

module Infix

module Abstraction

class Abstract < Binary::Abstract
    alias       lhs_opnd lhs
    attr_reader :opr_sym
    alias       rhs_opnd rhs


    def initialize(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of lhs_opnd,    Umu::Abstraction::Model
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    Umu::Abstraction::Model

        super(loc, lhs_opnd, rhs_opnd)

        @opr_sym = opr_sym
    end


    def to_s
        _opr = self.opr_sym.to_s
        opr = if /^[a-zA-Z\-]+\??$/ =~ _opr
                    '%' + _opr.upcase
                else
                    _opr
                end

        format "(%s %s %s)", self.lhs_opnd.to_s, opr, self.rhs_opnd.to_s
    end
end



class Simple < Abstract
    def initialize(loc, lhs_opnd, opr_sym, rhs_opnd)
        ASSERT.kind_of lhs_opnd,    CSCE::Abstract
        ASSERT.kind_of opr_sym,     ::Symbol
        ASSERT.kind_of rhs_opnd,    CSCE::Abstract

        super
    end
end



class WithRepetition < Abstract
    include Enumerable

    alias       hd_rhs_opnd rhs_opnd
    attr_reader :tl_rhs_opnds


    def initialize(loc, lhs_opnd, opr_sym, hd_rhs_opnd, tl_rhs_opnds)
        ASSERT.kind_of lhs_opnd,        CSCE::Abstract
        ASSERT.kind_of opr_sym,         ::Symbol
        ASSERT.kind_of hd_rhs_opnd,     CSCE::Abstract
        ASSERT.kind_of tl_rhs_opnds,    ::Array

        super(loc, lhs_opnd, opr_sym, hd_rhs_opnd)

        @tl_rhs_opnds = tl_rhs_opnds
    end


    def each
        return self.to_enum unless block_given?

        yield self.lhs_opnd

        yield self.hd_rhs_opnd

        self.tl_rhs_opnds.each do |rhs_opnd|
            ASSERT.kind_of rhs_opnd, CSCE::Abstract

            yield rhs_opnd
        end
    end


    def to_s
        opr = format " %s ", self.opr_sym.to_s

        format "(%s)", self.map(&:to_s).join(opr)
    end
end

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix::Abstraction

end # Umu::ConcreteSyntax::Core::Expression::Binary::Infix

end # Umu::ConcreteSyntax::Core::Expression::Binary

end # Umu::ConcreteSyntax::Core::Expression

end # Umu::ConcreteSyntax::Core

end # Umu::ConcreteSyntax

end # Umu
