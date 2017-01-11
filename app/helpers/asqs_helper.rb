# Asq helpers
module AsqsHelper
  include ActsAsTaggableOn::TagsHelper

  # Turn a result hash from a DB query into a pretty HTML table.
  def tableize(result_json, results_to_show = 10)
    j_count = 0
    table_string = '<div class="asq-results"><table class="table ' \
                   'table-condensed" style="margin-bottom:0px;">'
    heading_string = '<thead><tr>'
    body_string = ''

    @parser = JSON::Stream::Parser.new do
      end_document do
        return "#{table_string}</tr><thead>#{heading_string}</thead>" \
               "<tbody>#{body_string}</tbody></table></div>"
      end

      start_object do
        if j_count >= results_to_show
          return "#{table_string}</tr><thead>#{heading_string}</thead>" \
                 "<tbody>#{body_string}</tbody></table></div>"
        else
          body_string += '<tr>'
        end
      end

      end_object do
        j_count += 1
        body_string += '</tr>'
      end

      key   { |k| heading_string += "<td>#{k}</td>" if j_count == 0 }
      value { |v| body_string += "<td>#{v}</td>" }
    end

    @parser << result_json
  rescue
    return "Unable to parse '" + truncate(result_json, length: 200) + "'"
  end

  # Color code asq refresh times based on how long they took
  def color_code_times(time)
    return 'N/A' if time.nil? || time == 0

    bootstrap_color = if time < 5
                        'success'
                      elsif time > 15
                        'danger'
                      else
                        'info'
                      end
    "<span class=\"text-#{bootstrap_color}\">#{time.round(2)} seconds</span>"
  end
end
