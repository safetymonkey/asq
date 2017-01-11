require 'json'
require 'csv'

# This class is a bag of static methods, no need to initialize
class FileOutputService
  # This method expects a json of Asq results, which are in the format
  # [{row hash}, {row hash} ...]. It then takes the first hash and uses it to
  # get the column headers, and then throws the rows into the csv.

  class << self
    def to_csv(json, file_options)
      line_end = extract_line_end(file_options)
      process_file(json, file_options).join(line_end).to_s + line_end

    rescue Oj::ParseError
      log_parsing_error json
    rescue JSON::ParserError
      log_parsing_error json
    end

    private

    def process_file(json, file_options)
      parsed_json = JSON.parse(json)
      return ['No results found.'] if parsed_json.blank?

      delimiter = extract_delimiter(file_options)
      qi = extract_quoted_identifier(file_options)
      line_end = extract_line_end(file_options)
      @sub_char = extract_sub_character(file_options)
      header = parsed_json[0].keys

      file_contents = []
      file_contents << convert_array_to_string(header, delimiter, qi)
      parsed_json.each do |hash|
        row = check_value_for_disallowed_characters(
          process_row(header, hash), delimiter, qi, line_end
        )
        file_contents << convert_array_to_string(row, delimiter, qi)
      end

      file_contents
    end

    def process_row(header, hash)
      # add the hash keys in the same order as the header:
      row = []
      header.each do |key|
        row << hash[key]
      end

      row
    end

    def extract_delimiter(file_options)
      if file_options.nil? || file_options[:delimiter].blank?
        ','
      else
        file_options[:delimiter].gsub(/\\t/, "\t")
      end
    end

    def extract_quoted_identifier(file_options)
      if file_options.nil? || file_options[:quoted_identifier].blank?
        ''
      else
        file_options[:quoted_identifier]
      end
    end

    def extract_line_end(file_options)
      if file_options.nil? || file_options[:line_end] == ''
        "\n"
      else
        file_options[:line_end].gsub(/\\n/, "\n").gsub(/\\r/, "\r")
      end
    end

    def extract_sub_character(file_options)
      return if file_options.nil?
      return nil if file_options[:sub_character].blank?
      return '' if file_options[:sub_character] == 'remove'
      file_options[:sub_character]
    end

    # throw exception if row would create mangled csv
    def check_value_for_disallowed_characters(row, delimiter, qi, line_end)
      row.map! do |val|
        if qi.blank?
          check_non_quoted_value(val, delimiter, line_end)
        else
          check_quoted_value(val, qi)
        end
      end
      row
    end

    def convert_array_to_string(row, delimiter, quoted_identifier)
      result = row.join("#{quoted_identifier}#{delimiter}#{quoted_identifier}")
      quoted_identifier.to_s + result + quoted_identifier.to_s
    end

    def check_non_quoted_value(val, delimiter, line_end)
      return val unless val.to_s.include?(delimiter) ||
                        val.to_s.include?(line_end)
      raise "Non-quoted value '#{val}'" \
            ' contains delimiter or line end.' unless @sub_char
      val.gsub(/#{delimiter}|#{line_end}/, @sub_char)
    end

    def check_quoted_value(val, qi)
      return val unless val.to_s.include?(qi)
      raise "Quoted value '#{val}' contains quote identifier." unless @sub_char
      val.gsub(/#{qi}/, @sub_char)
    end

    def log_parsing_error(json)
      Delayed::Worker.logger.warn(
        "Object to be turned to CSV was not of type: JSON. DATA: #{json}"
      )
    end
  end
end
