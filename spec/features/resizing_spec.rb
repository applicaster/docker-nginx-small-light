require "features_helper"

RSpec.describe "Server" do
  describe "resizing" do
    let!(:time_stamp) { "111" }
    let!(:resize_cmd) { "command=resize&width=2&height=2" }
    let!(:image) { "resize_test_#{rand(9999)}.png" }
    let!(:logo) { "applicaster-logo.png" }
    let!(:hodor) { "hodor.png" }

    before(:each) { copy_image(logo, image) }

    it "returns an image" do
      response = server.get(image)
      expect(response.status).to eq(200)
      expect(response.headers["content-length"]).to eq("21004")
    end

    it "returns resized image" do
      response = server.get(image + "?" + resize_cmd)
      expect(response.status).to eq(200)
      expect(response.headers["content-length"]).to eq("339")
    end

    after(:each) do
      delete_image(image)
    end
  end

  describe "health" do
    it "returns health check" do
      response = server.get("/health")
      expect(response.status).to eq(200)
      expect(response.body).to eq("OK")
    end
  end

  describe "version" do
    it "returns git sha" do
      response = server.get("/version")
      expect(response.status).to eq(200)
      expect(response.body).to eq(`git rev-parse HEAD`.strip)
    end
  end

  def copy_image(source, target)
    `cp -rf spec/fixtures/originals/#{source} spec/fixtures/#{target}`
    sleep 0.1 # we need that for the http server to respond
  end

  def delete_image(target)
    `rm spec/fixtures/#{target}`
  end
end
