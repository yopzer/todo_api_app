class Api::V1::TagsController < ApplicationController
  def index
    tags =
      if params[:q]
        Api::V1::Tag.by_title(params[:q])
      else
        Api::V1::Tag.all
      end

    render json: tags
  end

  def create
    tag = Api::V1::Tag.new(tag_params)

    if tag.save
      render json: tag, status: :created
    else
      render_error_for(tag)
    end
  end

  def update
    tag = Api::V1::Tag.find(params[:id])

    if tag.update_attributes(tag_params)
      render json: tag
    else
      render_error_for(tag)
    end
  end

  def destroy
    tag = Api::V1::Tag.find(params[:id])

    if tag.destroy
      render json: {}
    else
      render_error_for(tag)
    end
  end

  private

  def tag_params
    ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:title])
  end
end
