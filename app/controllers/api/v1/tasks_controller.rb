class Api::V1::TasksController < ApplicationController
  def index
    tasks = Api::V1::Task.preload(:tags)

    render json: tasks
  end

  def create
    task = Api::V1::Task.new(task_params)

    if task.save
      render json: task, status: :created
    else
      render_error_for(task)
    end
  end

  def update
    task = Api::V1::Task.find(params[:id])

    if task.update_attributes(task_params)
      render json: task
    else
      render_error_for(task)
    end
  end

  def destroy
    task = Api::V1::Task.find(params[:id])

    if task.destroy
      render json: {}
    else
      render_error_for(task)
    end
  end

  private

  def task_params
    data = ActiveModelSerializers::Deserialization.jsonapi_parse(params, only: [:title, :tags])

    if data[:tags]
      data[:tags] = data[:tags].map do |tag_title|
        # Consider wrapping tag creation and create/update in transaction
        Api::V1::Tag.where(title: tag_title).first_or_create!
      end
    end

    data
  end
end
