class ApplicationController < ActionController::API

  private

  def render_error_for(resource)
    render(
      json: resource,
      status: :unprocessable_entity,
      adapter: :json_api,
      serializer: ActiveModel::Serializer::ErrorSerializer
    )
  end
end
