require "fog"

connection = Fog::Storage.new({
  provider: "AWS",
  aws_access_key_id: ENV["AWS_ACCESS_KEY_ID"],
  aws_secret_access_key: ENV["AWS_SECRET_ACCESS_KEY"],
})

S3_BUCKET = connection.directories.find do |bucket|
  bucket.key == ENV["UPSTREAM_BASE_URL"].split("/").last
end
