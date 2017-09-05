# name: discourse-dev-login
# about: Allows logging in as any user with a simple link. DO NOT INSTALL IN PRODUCTION
# version: 1.0
# authors: David Taylor
# url: https://github.com/davidtaylorhq/discourse-dev-login

enabled_site_setting :dev_login_enabled

PLUGIN_NAME ||= 'discourse-dev-login'.freeze

register_asset "stylesheets/dev-login.scss"

if Rails.env.development?
  after_initialize do
    module ::DiscourseDevLogin
      class Engine < ::Rails::Engine
        engine_name PLUGIN_NAME
        isolate_namespace DiscourseDevLogin
      end
    end

    class DiscourseDevLogin::DevLoginController < ::ApplicationController
      skip_before_filter :preload_json, :check_xhr, :redirect_to_login_if_required
      def on_request
        params.require(:user)
        user = User.find_by_username_or_email(params[:user])
        raise Discourse::NotFound if user.blank?

        log_on_user(user)

        redirect_to '/'
      end

      def list_users
        usernames = User.all.limit(50).pluck(:username)

        render json: { users: usernames }
      end
    end

    DiscourseDevLogin::Engine.routes.draw do
      get '/' => 'dev_login#on_request'
      get '/users' => 'dev_login#list_users'
    end

    ::Discourse::Application.routes.append do
      mount ::DiscourseDevLogin::Engine, at: '/dev-login'
    end

  end
end