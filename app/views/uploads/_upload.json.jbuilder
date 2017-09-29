json.extract! upload, :id, :name, :description, :type, :uploadDate, :created_at, :updated_at
json.url upload_url(upload, format: :json)
