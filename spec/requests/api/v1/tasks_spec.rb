require 'rails_helper'

RSpec.describe 'Tasks', type: :request do
  describe 'GET /api/v1/tasks' do
    context 'without any tasks' do
      it 'returns empty list' do
        get "/api/v1/tasks"

        expect_json_response_with({ data: [] })
      end
    end

    context 'with tasks' do
      it 'returns task list' do
        task = Api::V1::Task.create(title: 'Test Task')
        Api::V1::Tag.create(title: 'TestTag', tasks: [task])

        get '/api/v1/tasks'

        expect_json_response_with(
          {
            data: [
              task_data(
                title:'Test Task',
                tags: [{ id: '1', type: 'tags' }]
              )
            ]
          }
        )
      end
    end
  end

  describe 'POST /api/v1/tasks' do
    context 'with valid task data' do
      it 'creates task' do
        post '/api/v1/tasks', params: {
          data: { attributes: { title: 'Test Task', tags: ['TestTag'] } }
        }

        expect_json_response_with(
          {
            data: task_data(
              title:'Test Task',
              tags: [{ id: '1', type: 'tags' }]
            )
          },
          status: :created
        )

        expect(Api::V1::Task.where(title: 'Test Task')).to exist
      end
    end

    context 'with invalid task data' do
      it 'returns error' do
        post '/api/v1/tasks', params: { data: { attributes: { title: '' } } }

        expect_json_response_with(
          {
            errors: [
              { detail: "can't be blank", source: { pointer: '/data/attributes/title'} }
            ]
          },
          status: :unprocessable_entity
        )
      end
    end
  end

  describe 'PATCH /api/v1/tasks/:id' do
    context 'with valid task data' do
      it 'updates task' do
        task = Api::V1::Task.create(title: 'Test Task')

        patch "/api/v1/tasks/#{task.id}", params: {
          data: {
            type: 'tasks',
            id: task.id.to_s,
            attributes: { title: 'Changed Task', tags: ['TestTag'] }
          }
        }

        expect_json_response_with(
          {
            data: task_data(
              title:'Changed Task',
              id: task.id.to_s,
              tags: [{ id: '1', type: 'tags' }]
            )
          }
        )

        expect(task.reload.title).to eq('Changed Task')
      end
    end

    context 'with invalid task data' do
      it 'returns error' do
        task = Api::V1::Task.create(title: 'Test Task')

        patch "/api/v1/tasks/#{task.id}", params: {
          data: {
            type: 'tasks',
            id: task.id.to_s,
            attributes: { title: '' }
          }
        }

        expect_json_response_with(
          {
            errors: [
              { detail: "can't be blank", source: { pointer: '/data/attributes/title'} }
            ]
          },
          status: :unprocessable_entity
        )

        expect(task.reload.title).to eq('Test Task')
      end
    end

    context 'without existing task' do
      it 'raises error' do
        expect {
          patch "/api/v1/tasks/1", params: {
            data: {
              type: 'tasks',
              id: '1',
              attributes: { title: 'Changed Task' }
            }
          }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'DELETE /api/v1/tasks/:id' do
    context 'with existing task' do
      it 'deletes task' do
        task = Api::V1::Task.create(title: 'Test Task')

        delete "/api/v1/tasks/#{task.id}", params: { data: { type: 'tasks', id: task.id.to_s } }

        expect_json_response_with({})
        expect{task.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without existing task' do
      it 'raises error' do
        expect {
          delete "/api/v1/tasks/1", params: {
            data: {
              type: 'tasks',
              id: '1'
            }
          }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  def task_data(title:, id: '1', tags: [])
    {
      attributes: { title: title },
      id: id,
      relationships: {
        tags: {
          data: tags
        }
      },
      type: 'tasks'
    }
  end

  def expect_json_response_with(response_data, status: :ok)
    expect(response).to have_http_status(status)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to be_json_eql(response_data.to_json)
  end
end
