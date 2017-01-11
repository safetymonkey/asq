AsqApplication::Application.routes.draw do
  devise_for :users
  get 'activity/index'

  get 'ftp_service/test'
  get 'sftp_service/test'

  mount JasmineRails::Engine => '/specs' if defined?(JasmineRails)
  resources :schedules
  resources :databases
  resources :archived_files

  resources :asqs do
    resources :file_options
  end

  get '/tags(/:tag)', to: 'asqs#index', as: 'tags'
  get '/search(/:term)', to: 'asqs#index', as: 'search'

  get '/activity/', to: 'activity#index'
  get '/monitors/tags(/:tag)', to: 'asqs#index', as: 'tags_old'
  get '/monitors/search(/:term)', to: 'asqs#index', as: 'search_old'
  get '/asqs/partial/(:id)', to: 'asqs#show_partial'
  get '/asqs/ajax/:id/*attribute', to: 'asqs#ajax'
  get '/asqs/:id/details', to: 'asqs#details'
  get '/asqs/:id/activity_rows', to: 'asqs#activity_rows',
                                 as: 'activity_rows_by_asq'
  resources :monitors, controller: 'asqs'

  root to: 'static_pages#tag_cloud'
  # devise_for :users, controllers: { registrations: 'registrations' }
  resources :users

  get '/refresh(/:id)', to: 'refresh#index', as: 'refresh'
  get '/status', to: 'status#index', as: 'status'
  get '/status/nagios', to: 'status#nagios'
  get '/settings', to: 'settings#index', as: 'settings'
  post '/settings', to: 'settings#update', as: 'edit_settings'

  # Disabling the /settings/json route for now. Nobody really uses it, except
  # for the refresh controller, and it only uses one setting for its purposes.
  # If you want to re-enable the json route, then someone will need to have the
  # Settings class implement a get_all method.

  # get '/settings/json', to: 'settings#json', as: 'json_settings'

  get '/settings/:var', to: 'settings#single_setting'

  get 'zenoss_settings', to: 'zenoss_settings#index', as: 'zenoss_settings'
  post 'zenoss_settings', to: 'zenoss_settings#update',
                          as: 'edit_zenoss_settings'

  get 'db_test', to: 'database_tester#index'
  post 'db_test', to: 'database_tester#test'

  post 'ftp_service/test', to: 'ftp_service#test'
  post 'sftp_service/test', to: 'sftp_service#test'

  match '/release_notes', to: 'release_notes#index', via: 'get'
  match '/help',    to: 'static_pages#help', via: 'get'

  get '/cancel_refresh(/:id)', to: 'cancel_refresh#index', as: 'cancel_refresh'
end
