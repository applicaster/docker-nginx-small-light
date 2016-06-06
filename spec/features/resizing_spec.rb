require "features_helper"

RSpec.describe "Server" do
  before(:all) do
    S3_BUCKET.files.create(
      key: "resize_test.png",
      body: File.open("spec/fixtures/applicaster-logo.png"),
    )
  end

  describe "resizing" do
    let!(:image) { "resize_test.png" }
    let!(:time_stamp) { "?111" }
    let!(:resize_cmd) { "&command=resize&width=2&height=2" }

    it "returns an image" do
      response = server.get(image)
      expect(response.status).to eq(200)
      expect(response.headers["content-length"]).to eq("21004")
    end

    it "returns resized image" do
      response = server.get(image + time_stamp + resize_cmd)
      expect(response.status).to eq(200)
      expect(response.headers["content-length"]).to eq("339")
    end

    describe "caching" do
      before do
        S3_BUCKET.files.create(key: "resize_test.png", body: File.open("spec/fixtures/hodor.png"))
      end

      let!(:new_resize) { "&command=resize&width=3&height=3" }

      context "original pic changed but using old timestamp" do
        it "returns cached resized image" do
          response = server.get(image + time_stamp + resize_cmd)
          expect(response.status).to eq(200)
          expect(response.headers["content-length"]).to eq("339")
        end

        it "returns original image resized to new dimensions" do
          response = server.get(image + time_stamp + new_resize)
          expect(response.status).to eq(200)
          expect(response.headers["content-length"]).to eq("364")
        end
      end

      context "original pic changed and using new timestamp" do
        let!(:new_time_stamp) { "?222" }

        it "returns new resized image" do
          response = server.get(image + new_time_stamp + resize_cmd)
          expect(response.status).to eq(200)
          expect(response.headers["content-length"]).to eq("286")
        end
      end
    end
  end

  after(:all) do
    S3_BUCKET.files.destroy("resize_test.png")
  end
end
