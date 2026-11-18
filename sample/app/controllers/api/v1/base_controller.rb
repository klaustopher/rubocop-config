module Api
  module V1
    class BaseController < ActionController::API
      include ActionController::HttpAuthentication::Token::ControllerMethods

      before_action :authenticate_token!

      rescue_from ActiveRecord::RecordNotFound do |error|
        render json: { error: "not_found", message: error.message }, status: :not_found
      end

      rescue_from ActionController::ParameterMissing do |error|
        render json: { error: "bad_request", message: error.message }, status: :bad_request
      end

      private

      attr_reader :current_user

      def authenticate_token!
        @current_user = authenticate_with_http_token do |token, _options|
          ApiToken.active.find_by(digest: ApiToken.digest(token))&.user
        end

        render json: { error: "unauthorized" }, status: :unauthorized unless @current_user
      end

      def paginate(scope)
        page = params.fetch(:page, 1).to_i.clamp(1, 10_000)
        per_page = params.fetch(:per_page, 25).to_i.clamp(1, 100)

        response.headers["X-Total-Count"] = scope.count.to_s
        scope.offset((page - 1) * per_page).limit(per_page)
      end
    end
  end
end
