module Umu

module Assertion

module Exception

class Abstract < ::StandardError; end

class Fail	< Abstract; end
class Error	< Abstract; end

end	# Umu::Assertion::Exception



module_function

	def kind_of(actual, expected, msg_fmt = nil, *msg_args)
		unless expected.kind_of?(::Class)
			raise Exception::Error
		end
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless actual.kind_of?(expected)
			Assertion.__print_box__(
				'A is kind of E',
				{
					:message		=> [msg_fmt, msg_args],
					:expected_type	=> expected.to_s
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		actual
	end


	def opt_kind_of(actual, expected, msg_fmt = nil, *msg_args)
		unless expected.kind_of?(::Class)
			raise Exception::Error
		end
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless (! actual) || actual.kind_of?(expected)
			Assertion.__print_box__(
				'A is kind of E, or nil',
				{
					:message		=> [msg_fmt, msg_args],
					:expected_type	=> expected.to_s
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		actual
	end


	def tuple_of(actual, expected, msg_fmt = nil, *msg_args)
		unless expected.kind_of?(::Array)
			raise Exception::Error
		end
		unless expected.length >= 2
			raise Exception::Error
		end
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless actual.kind_of?(::Array)
			Assertion.__print_box__(
				'A is kind of Array (tuple-of)',
				{
					:message		=> [msg_fmt, msg_args],
					:expected_type	=> 'Array'
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		unless actual.length == expected.length
			Assertion.__print_box__(
				format("Length of A is %d (tuple-of)", expected.length),
				{
					:message		=> [msg_fmt, msg_args],
					:expected_type	=> format(
						"[%s] (Array)",
						expected.map { |c| c.to_s }.join(', ')
					)
				}, {
					:actual_type	=> format(
						"[%s] (Array)",
						actual.map { |v| v.class.to_s }.join(', ')
					),
					:actual_value	=> format(
						"[\n  %s\n]",
						actual.map { |v| v.to_s }.join(",\n  ")
					)
				}
			)
			raise Exception::Fail
		end

		(0 .. (actual.length - 1)).each do |i|
			unless actual[i].kind_of?(expected[i])
				Assertion.__print_box__(
					format(
						"the #%d of A is kind of %s (tuple-of)",
						i + 1, expected[i]
					),
					{
						:message		=> [msg_fmt, msg_args],
						:expected_type	=> format(
							"[%s] (Array)",
							expected.map { |c| c.to_s }.join(', ')
						)
					}, {
						:actual_type	=> format(
							"[%s] (Array)",
							actual.map { |v| v.class.to_s }.join(', ')
						),
						:actual_value	=> format(
							"[\n  %s\n]",
							actual.map { |v| v.to_s }.join(",\n  ")
						)
					}
				)
				raise Exception::Fail
			end
		end

		actual
	end


	def instance_of(actual, expected, msg_fmt = nil, *msg_args)
		unless expected.kind_of?(::Class)
			raise Exception::Error
		end
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless actual.instance_of?(expected)
			Assertion.__print_box__(
				'A is instance of E',
				{
					:message		=> [msg_fmt, msg_args],
					:expected_type	=> expected.to_s
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		actual
	end


	def subclass_of(actual, expected, msg_fmt = nil, *msg_args)
		unless expected.kind_of?(::Class)
			raise Exception::Error
		end
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless actual.kind_of?(::Class)
			Assertion.__print_box__(
				'A is kind of Class (subclass-of)',
				{
					:message		=> [msg_fmt, msg_args],
					:expected_type	=> 'Class or Module'
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		unless actual <= expected
			Assertion.__print_box__(
				'A is subclass of E',
				{
					:message		=> [msg_fmt, msg_args],
					:expected_type	=> expected.to_s
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		actual
	end


	def nil(actual = nil, msg_fmt = nil, *msg_args)
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless actual.equal?(nil)
			Assertion.__print_box__(
				'A is nil',
				{
					:message		=> [msg_fmt, msg_args]
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		nil
	end


	def bool(actual, msg_fmt = nil, *msg_args)
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless actual == true || actual == false
			Assertion.__print_box__(
				'A is true or false',
				{
					:message		=> [msg_fmt, msg_args]
				}, {
					:actual_type	=> actual.class.to_s,
					:actual_value	=> actual.to_s
				}
			)
			raise Exception::Fail
		end

		actual
	end


	def assert(cond, msg_fmt = nil, *msg_args)
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		unless cond
			Assertion.__print_box__(
				nil,
				{ :message => [msg_fmt, msg_args] }
			)
			raise Exception::Fail
		end

		nil
	end


	def abort(msg_fmt = nil, *msg_args)
		unless (! msg_fmt) || msg_fmt.kind_of?(::String)
			raise Exception::Error
		end

		Assertion.__print_box__(
			nil,
			{ :message => [msg_fmt, msg_args] }
		)
		raise Exception::Fail

		nil
	end



	DISPLAY_WIDTH	= 80
	LINE_LENGTH		= DISPLAY_WIDTH - 2

	TOP_LINE		= '+' + ('=' * (LINE_LENGTH - 1))
	SEPARATE_LINE	= '|' + ('-' * (LINE_LENGTH - 1))
	BOTTOM_LINE		= '+' + ('=' * (LINE_LENGTH - 1))


	def __print_box__(title, rows, opt_rows = {})
		if title && (! title.kind_of?(::String))
			raise Exception::Error
		end
		unless rows.kind_of?(::Hash)
			raise Exception::Error
		end
		unless opt_rows.kind_of?(::Hash)
			raise Exception::Error
		end

		message			= nil
		expected_type	= nil
		actual_type		= nil
		actual_value	= nil
		for key, val in rows.merge(opt_rows)
			unless key.kind_of?(::Symbol)
				raise Exception::Error
			end

			case key
			when :message
				unless val.kind_of?(::Array)
					raise Exception::Error
				end
				unless val.length == 2
					raise Exception::Error
				end
				msg_fmt, msg_args = val

				unless (! msg_fmt) || msg_fmt.kind_of?(::String)
					raise Exception::Error
				end
				unless (! msg_args) || msg_args.kind_of?(::Array)
					raise Exception::Error
				end

				message	= if msg_fmt
								format(msg_fmt, *msg_args)
							else
								nil
							end
			when :expected_type
				unless val.kind_of?(::String)
					raise Exception::Error
				end

				expected_type = val
			when :actual_type
				unless val.kind_of?(::String)
					raise Exception::Error
				end

				actual_type = val
			when :actual_value
				unless val.kind_of?(::String)
					raise Exception::Error
				end

				actual_value = val
			else
				raise Exception::Error
			end
		end
		rows_is_empty		= [message, expected_type].all?		{ |x| ! x }
		opt_rows_is_empty	= [actual_type, actual_value].all?	{ |x| ! x }
		box_is_empty		= rows_is_empty && opt_rows_is_empty

		formated_title =
			if title
				format " ASSERTION FAIL!! : %s. ", title
			else
				' ASSERTION FAIL!! '
			end
		len = (LINE_LENGTH / 2).to_i - (formated_title.length / 2).to_i
		top_line = [
			TOP_LINE[0, len], formated_title, TOP_LINE[(len * -1), len]
		].join


		STDERR.puts ''

		STDERR.puts top_line

		if box_is_empty
			return
		end

		if msg_fmt
			STDERR.puts "|[MESSAGE]"
			Assertion.__print_line__ format(msg_fmt, *msg_args)
		end

		if expected_type
			STDERR.puts "|[EXPECTED(E) TYPE]"
			Assertion.__print_line__ expected_type
		end

		if (! rows_is_empty) && (! opt_rows_is_empty)
			STDERR.puts SEPARATE_LINE
		end

		unless opt_rows_is_empty
			if actual_type
				STDERR.puts "|[ACTUAL(A) TYPE]"
				Assertion.__print_line__ actual_type
			end

			if actual_value
				STDERR.puts "|[ACTUAL(A) VALUE]"
				Assertion.__print_line__ actual_value
			end
		end
		STDERR.puts BOTTOM_LINE

		nil
	end


	def __print_line__(str)
		unless str.kind_of?(::String)
			raise Exception::Error
		end

		str.each_line do |line|
			STDERR.puts '|  ' + line
		end

		nil
	end
end	# Umu::Assertion

end # Umu
