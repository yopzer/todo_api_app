require 'rails_helper'

RSpec.describe 'Tags', type: :request do
  describe 'GET /api/v1/tags' do
    context 'without any tags' do
      it 'returns empty list' do
        get "/api/v1/tags"

        expect_json_response_with({ data: [] })
      end
    end

    context 'with tags' do
      it 'returns tag list' do
        tag = Api::V1::Tag.create(title: 'Test Tag')

        get '/api/v1/tags'

        expect_json_response_with({ data: [tag_data(title:'Test Tag')] })
      end
    end
  end

  describe 'POST /api/v1/tags' do
    context 'with valid tag data' do
      it 'creates tag' do
        post '/api/v1/tags', params: {
          data: { attributes: { title: 'Test Tag' } }
        }

        expect_json_response_with({ data: tag_data(title: 'Test Tag') }, status: :created)
        expect(Api::V1::Tag.where(title: 'Test Tag')).to exist
      end
    end

    context 'with invalid tag data' do
      it 'returns error' do
        post '/api/v1/tags', params: {
          data: { attributes: { title: '' } }
        }

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

  describe 'PATCH /api/v1/tags/:id' do
    context 'with valid tag data' do
      it 'updates tag' do
        tag = Api::V1::Tag.create(title: 'Test Tag')

        patch "/api/v1/tags/#{tag.id}", params: {
          data: {
            type: 'tags',
            id: tag.id.to_s,
            attributes: { title: 'Changed Tag' }
          }
        }

        expect_json_response_with({ data: tag_data(title: 'Changed Tag', id: tag.id.to_s) })
        expect(tag.reload.title).to eq('Changed Tag')
      end
    end

    context 'with invalid tag data' do
      it 'returns error' do
        tag = Api::V1::Tag.create(title: 'Test Tag')

        patch "/api/v1/tags/#{tag.id}", params: {
          data: {
            type: 'tags',
            id: tag.id.to_s,
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

        expect(tag.reload.title).to eq('Test Tag')
      end
    end

    context 'without existing tag' do
      it 'raises error' do
        expect {
          patch "/api/v1/tags/1", params: {
            data: {
              type: 'tags',
              id: '1',
              attributes: { title: 'Changed Tag' }
            }
          }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe 'DELETE /api/v1/tags/:id' do
    context 'with existing tag' do
      it 'deletes tag' do
        tag = Api::V1::Tag.create(title: 'Test Tag')

        delete "/api/v1/tags/#{tag.id}", params: { data: { type: 'tags', id: tag.id.to_s } }

        expect_json_response_with({})
        expect{tag.reload}.to raise_error(ActiveRecord::RecordNotFound)
      end
    end

    context 'without existing tag' do
      it 'raises error' do
        expect {
          delete "/api/v1/tags/1", params: { data: { type: 'tags', id: '1' } }
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  def tag_data(title:, id: '1')
    { attributes: { title: title }, id: id, type: 'tags' }
  end

  def expect_json_response_with(response_data, status: :ok)
    expect(response).to have_http_status(status)
    expect(response.content_type).to eq('application/json')
    expect(response.body).to be_json_eql(response_data.to_json)
  end
end
