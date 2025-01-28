# coding: utf-8
# frozen_string_literal: true



module Umu

module Value

module Core

module_function

    # Atom type

    def validate_bool(value, meth_name, loc, env)
        ASSERT.kind_of value,     VC::Top
        ASSERT.kind_of meth_name, ::String

        VC.validate_type value, VCA::Bool, meth_name, loc, env

        value.val
    end


    def validate_string(value, meth_name, loc, env)
        ASSERT.kind_of value,     VC::Top
        ASSERT.kind_of meth_name, ::String

        VC.validate_type value, VCA::String, meth_name, loc, env

        value.val
    end


    def validate_number(value, meth_name, loc, env)
        ASSERT.kind_of value,     VC::Top
        ASSERT.kind_of meth_name, ::String

        VC.validate_type value, VCAN::Abstract, meth_name, loc, env

        value.val
    end


    def validate_int(value, meth_name, loc, env)
        ASSERT.kind_of value,     VC::Top
        ASSERT.kind_of meth_name, ::String

        VC.validate_type value, VCAN::Int, meth_name, loc, env

        value.val
    end


    # Direct Product type

    def validate_pair(pair, meth_name, loc, env)
        ASSERT.kind_of pair,      VC::Top
        ASSERT.kind_of meth_name, ::String

        VC.validate_type pair, VCP::Tuple, meth_name, loc, env

        vals = pair.values
        unless vals.size == 2
            raise X::TypeError.new(
                loc,
                env,
                "%s: Expected arity of the tuple is 2, but %s",
                meth_name,
                pair.to_s
            )
        end

        vals
    end


    # Disjoint Union type

    def validate_option(value, meth_name, loc, env)
        ASSERT.kind_of value,     VC::Top
        ASSERT.kind_of meth_name, ::String

        VC.validate_type value, VCU::Option::Abstract, meth_name, loc, env

        nil
    end


    # Morph type

    def validate_morph(value, meth_name, loc, env)
        ASSERT.kind_of value,     VC::Top
        ASSERT.kind_of meth_name, ::String

        VC.validate_type value, VCM::Abstract, meth_name, loc, env

        nil
    end


    # Top type

    def validate_type(actual_value, expected_type, meth_name, loc, env)
        ASSERT.kind_of actual_value,      VC::Top
        ASSERT.subclass_of expected_type, VC::Top
        ASSERT.kind_of meth_name,         ::String

        unless actual_value.kind_of? expected_type
            raise X::TypeError.new(
                loc,
                env,
                "%s: Expected a %s, but %s : %s",
                meth_name,
                expected_type.type_sym.to_s,
                actual_value.to_s,
                actual_value.type_sym.to_s
            )
        end

        actual_value
    end

end # Umu::Value::Core

end # Umu::Value

end # Umu
