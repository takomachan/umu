# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module LSM

module Union

class Abstract < Object
    def to_s
        format("&%s %s", self.type_sym, self.contents.to_s)
    end


    def pretty_print(q)
        q.text format("&%s ", self.type_sym.to_s)
        q.pp self.contents
    end


    def meth_to_string(loc, env, event)
        VC.make_string(
            format("&%s %s",
                    self.type_sym,
                    self.meth_contents(
                        loc, env, event
                    ).meth_to_string(
                        loc, env, event
                    ).val
            )
        )
    end
end
Abstract.freeze

end # Umu::Value::Core::LSM::Union

end # Umu::Value::Core::LSM

end # Umu::Value::Core

end # Umu::Value

end # Umu
