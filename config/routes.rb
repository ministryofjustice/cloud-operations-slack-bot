Rails.application.routes.draw do
  get '/', to: 'slack#index'
  post '/slack/events', to: 'slack#events'
end
