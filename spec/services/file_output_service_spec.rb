require 'rails_helper'

# There are 72 different combinations of options that FileOutputService
# can take into consideration. This is not nearly exhaustive enough to
# cover all 72 conditions. But it's a start.

describe 'FileOutputService' do
  let(:basic_json) do
    [
      { name: 'Greg Gregorson', address: '123 Main St' }
    ].to_json
  end
  let(:single_quote_json) do
    [
      { name: 'Greg Gregorson\'s', address: '123 Main St' }
    ].to_json
  end
  let(:multiline_json) do
    [
      { name: 'Greg Gregorson', address: "123 Main St\nApt B" }
    ].to_json
  end
  let(:comma_json) do
    [
      { name: 'Greg Gregorson', address: '123 Main St, Apt B' }
    ].to_json
  end
  let(:semicolon_json) do
    [
      { name: 'Greg Gregorson', address: '123 Main St;Apt B' }
    ].to_json
  end
  let(:tab_json) do
    [
      { name: 'Greg Gregorson', address: "123 Main St\tApt B" }
    ].to_json
  end
  let(:pipe_json) do
    [
      { name: 'Greg Gregorson', address: '123 Main St|Apt B' }
    ].to_json
  end
  let(:default_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: '', line_end: '\n' }
  end
  let(:pipe_delimited_options) do
    { name: 'asqs', delimiter: '|', quoted_identifier: '', line_end: '\n' }
  end
  let(:semicolon_delimited_options) do
    { name: 'asqs', delimiter: ';', quoted_identifier: '', line_end: '\n' }
  end
  let(:tab_delimited_options) do
    { name: 'asqs', delimiter: '\t', quoted_identifier: '', line_end: '\n' }
  end
  let(:double_qi_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: '"', line_end: '\n' }
  end
  let(:single_qi_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: "'", line_end: '\n' }
  end
  let(:return_and_newline_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: '', line_end: '\r\n' }
  end
  let(:strip_invalid_comma_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: '',
      line_end: '\n', sub_character: 'remove' }
  end
  let(:replace_invalid_comma_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: '',
      line_end: '\n', sub_character: '_' }
  end
  let(:strip_single_quote_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: "'",
      line_end: '\n', sub_character: 'remove' }
  end
  let(:replace_single_quote_options) do
    { name: 'asqs', delimiter: ',', quoted_identifier: "'",
      line_end: '\n', sub_character: '_' }
  end

  describe '::to_csv' do
    context 'when using basic JSON' do
      context 'when using default file options' do
        it 'returns a comma-delimited string' do
          expected_result = "name,address\nGreg Gregorson,123 Main St\n"
          expect(
            FileOutputService.to_csv(basic_json, default_options)
          ).to eq(expected_result)
        end
      end

      context 'when using pipe-delimited options' do
        it 'returns a pipe-delimited string' do
          expected_result = "name|address\nGreg Gregorson|123 Main St\n"
          expect(
            FileOutputService.to_csv(basic_json, pipe_delimited_options)
          ).to eq(expected_result)
        end
      end

      context 'when using semicolon-delimited options' do
        it 'returns a semicolon-delimited string' do
          expected_result = "name;address\nGreg Gregorson;123 Main St\n"
          expect(
            FileOutputService.to_csv(basic_json, semicolon_delimited_options)
          ).to eq(expected_result)
        end
      end

      context 'when using tab-delimited options' do
        it 'returns a tab-delimited string' do
          expected_result = "name\taddress\nGreg Gregorson\t123 Main St\n"
          expect(
            FileOutputService.to_csv(basic_json, tab_delimited_options)
          ).to eq(expected_result)
        end
      end

      context 'when using carriage return and newline options' do
        it 'returns a string with carriage returns and newlines' do
          expected_result = "name,address\r\nGreg Gregorson,123 Main St\r\n"
          expect(
            FileOutputService.to_csv(basic_json, return_and_newline_options)
          ).to eq(expected_result)
        end
      end
    end

    context 'when using spaced JSON' do
      context 'when using default file options' do
        it 'returns a string with nothing around each value' do
          expected_result = "name,address\nGreg Gregorson,123 Main St\n"
          expect(
            FileOutputService.to_csv(basic_json, default_options)
          ).to eq(expected_result)
        end
      end

      context 'when using double-quoted identifier file options' do
        it 'returns a string with double-quotes around each value' do
          expected_result = "\"name\",\"address\"\n" \
            "\"Greg Gregorson\",\"123 Main St\"\n"
          expect(
            FileOutputService.to_csv(
              basic_json, double_qi_options
            )
          ).to eq(expected_result)
        end
      end

      context 'when using single-quoted identifier file options' do
        it 'returns a string with single-quotes around each value' do
          expected_result = "'name','address'\n" \
            "'Greg Gregorson','123 Main St'\n"
          expect(
            FileOutputService.to_csv(
              basic_json, single_qi_options
            )
          ).to eq(expected_result)
        end
      end
    end

    context 'when dealing with a quoted identifier in field values' do
      context 'when the "remove" option is specified' do
        it 'removes the invalid character' do
          expected_result = "'name','address'\n" \
            "'Greg Gregorsons','123 Main St'\n"
          expect(
            FileOutputService.to_csv(
              single_quote_json, strip_single_quote_options
            )
          ).to eq(expected_result)
        end
      end

      context 'when the "underscore" option is specified' do
        it 'replaces the invalid character' do
          expected_result = "'name','address'\n" \
            "'Greg Gregorson_s','123 Main St'\n"
          expect(
            FileOutputService.to_csv(
              single_quote_json, replace_single_quote_options
            )
          ).to eq(expected_result)
        end
      end
    end

    context 'when a delimiter is found in a field value' do
      context 'when the "remove" option is specified' do
        it 'removes the invalid character' do
          expected_result = "name,address\nGreg Gregorson,123 Main St Apt B\n"
          expect(
            FileOutputService.to_csv(comma_json, strip_invalid_comma_options)
          ).to eq(expected_result)
        end
      end

      context 'when the "replace" option is specified' do
        it 'replaces the invalid character' do
          expected_result = "name,address\nGreg Gregorson,123 Main St_ Apt B\n"
          expect(
            FileOutputService.to_csv(comma_json, replace_invalid_comma_options)
          ).to eq(expected_result)
        end
      end
    end

    context 'when errors are encountered' do
      context 'when process_file raises an Oj::ParseError exception' do
        it 'writes the error to the DJ log' do
          allow(FileOutputService).to receive(:process_file)
            .and_raise(Oj::ParseError)
          logger = double
          allow(Delayed::Worker).to receive(:logger).and_return(logger)
          expect(logger).to receive(:warn)
          FileOutputService.to_csv(basic_json, default_options)
        end
      end

      context 'when process_file raises a JSON::ParserError exception' do
        it 'writes the error to the DJ log' do
          allow(FileOutputService).to receive(:process_file)
            .and_raise(JSON::ParserError)
          logger = double
          allow(Delayed::Worker).to receive(:logger).and_return(logger)
          expect(logger).to receive(:warn)
          FileOutputService.to_csv(basic_json, default_options)
        end
      end

      context 'when no substitution option is present' do
        context 'when a quoted identifier is found in a field' do
          it 'raises a StandardError' do
            expect do
              FileOutputService.to_csv(single_quote_json, single_qi_options)
            end.to raise_error(
              StandardError, /Quoted value .* contains quote identifier./
            )
          end
        end

        context 'when a delimiter is present in a field' do
          it 'raises a StandardError' do
            expect do
              FileOutputService.to_csv(comma_json, default_options)
            end.to raise_error(
              StandardError,
              /Non-quoted value .* contains delimiter or line end./
            )
          end
        end
      end
    end
  end
end
