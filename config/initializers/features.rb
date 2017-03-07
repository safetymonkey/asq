require 'yaml'

def feature_settings
  settings_path = Rails.root.join('config', 'features.yml')
  YAML.load_file(settings_path)
end

Rails.configuration.feature_settings = feature_settings
