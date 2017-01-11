# Usage: For the Setting 'foo', use the following:
# SET: Settings.foo = 'bar'
# GET: Settings.foo
class Settings
  # All of these methods are class methods, so we can stick all of them under
  # class << self. This is a fancy way of not having to stick "self." in front
  # of each method name.
  class << self
    # An object's method_missing method is called when Ruby doesn't recognize
    # a method called against an object. For example, calling
    # Cat.favorite_band = 'Slayer' would end up with
    # Cat.method_missing('favorite_band', 'Slayer') being called. This usually
    # results in a NoMethodError exception.

    # By re-defining method_missing(), we're able to translate something
    # like "Settings.vip_name" into an actual thing that gets and sets
    # the value for vip_name. Neat! Thanks, Ruby!
    def method_missing(method, *args)
      setting_var = method.to_s.sub('=', '')
      setting_value = args.first
      # If the method ends in an equal sign, call set_value. Otherwise,
      # call get_value.
      if method.to_s[-1] == '=' || method.to_s[-2] == '='
        set_value(setting_var, setting_value)
      else
        get_value(setting_var)
      end
    end

    # Get the value of the passed-in Setting
    def get_value(setting_var)
      # Use ActiveRecord to find the setting, and get its value. We
      # wrap this in a YAML.load method because settings used to be
      # stored in YAML format, back when we used the rails-settings-cached
      # gem. If a Seetting is empty, then YAML.load returns "false"
      # rather than an empty string. That's bad. So, we compensate
      # for it. We can probably remove the YAML.load call in the future.
      found_value = Setting.find_by(var: setting_var).value
      return '' if found_value.empty?
      YAML.load(found_value)
    rescue NoMethodError
      # If the requested Setting doesn't exist, return its default value.
      # If *that* doesn't exist, return an empty string.
      defaults[setting_var] || ''
    end

    # Set the value of a passed-in Setting
    def set_value(setting_var, setting_value)
      # Try to find the setting in the database, if it exists. If not,
      # then a new one will be created.
      setting = Setting.find_or_initialize_by(var: setting_var)
      setting.value = setting_value
      setting.save!
    end

    def defaults
      max_db_timeout = [
        (Delayed::Worker.max_run_time.to_i * 0.95),
        (Delayed::Worker.max_run_time.to_i - 60)].max
      { 'dj_workers' => 0, 'vip_name' => '',
        'hostname' => Rails.application.hostname, 'environemnt' => '',
        'result_limit' => 5000, 'tsg_prefix' => '',
        'global_rt_check' => true, 'max_db_timeout' => max_db_timeout,
        'db_statement_timeout' => max_db_timeout
      }
    end
  end
end
