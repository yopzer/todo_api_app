# Load the Rails application.
require_relative 'application'

# Initialize the Rails application.
Rails.application.initialize!

ActiveModel::Serializer.config.adapter = :json_api
ActiveModelSerializers.config.key_transform = :underscore
