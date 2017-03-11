module ApplicationHelper
  # Set the flash CSS based on the type of message.
  def flash_class(level)
    case level
    when :notice then 'alert alert-info'
    when :success then 'alert alert-success'
    when :error then 'alert alert-error'
    when :alert then 'alert alert-error'
    end
  end

  # Return a title on a per-page basis.
  def title
    base_title = 'Asq'
    if @title.nil?
      base_title
    else
      "#{base_title} | #{@title}"
    end
  end
end
