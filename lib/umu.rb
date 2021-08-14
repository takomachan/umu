# frozen_string_literal: true

require_relative "umu/version"
require_relative "umu/commander"

if $0 == __FILE__
	exit Umu::Commander.main(ARGV)
end
