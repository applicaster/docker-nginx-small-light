require "features_helper"

RSpec.describe "Server" do
  let!(:image) { "resize_test_#{rand(9999)}.png" }
  let!(:logo) { "applicaster-logo.png" }
  let!(:hodor) { "hodor.png" }

  before(:each) { copy_image(logo, image) }

  describe "resizing" do
    let!(:time_stamp) { "111" }
    let!(:resize_cmd) { "command=resize&width=2&height=2" }

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

    describe "caching" do
      let!(:resize_cmd2) { "command=resize&width=3&height=3" }

      before(:each) do
        # make three calls that we wish to see cached
        server.get(image)
        server.get(image + "?" + time_stamp)
        server.get(image + "?" + time_stamp + "&" + resize_cmd)
        copy_image(hodor, image)
      end

      context "no timestamp" do
        context "no resize" do
          it "returns cached logo" do
            response = server.get(image)
            expect(response.headers["content-length"]).to eq("21004")
          end
        end

        context "same resize" do
          it "returns cached resized logo" do
            response = server.get(image + "?" + resize_cmd)
            expect(response.headers["content-length"]).to eq("339")
          end
        end

        context "new resize" do
          it "returns cached logo resized to new dimensions" do
            response = server.get(image + "?" + resize_cmd2)
            expect(response.headers["content-length"]).to eq("364")
          end
        end
      end

      context "old timestamp" do
        context "no resize" do
          it "returns cached logo" do
            response = server.get(image + "?" + time_stamp)
            expect(response.headers["content-length"]).to eq("21004")
          end
        end

        context "same resize" do
          it "returns cached resized logo" do
            response = server.get(image + "?" + time_stamp + "&" + resize_cmd)
            expect(response.headers["content-length"]).to eq("339")
          end
        end

        context "new resize" do
          it "returns logo resized to new dimensions" do
            response = server.get(image + "?" + time_stamp + "&" + resize_cmd2)
            expect(response.headers["content-length"]).to eq("364")
          end
        end
      end

      context "new timestamp" do
        let!(:time_stamp2) { "222" }

        context "no resize" do
          it "returns hodor" do
            response = server.get(image + "?" + time_stamp2)
            expect(response.headers["content-length"]).to eq("8210")
          end
        end

        context "same resize" do
          it "returns resized hodor" do
            response = server.get(image + "?" + time_stamp2 + "&" + resize_cmd)
            expect(response.headers["content-length"]).to eq("286")
          end
        end

        context "new resize" do
          it "returns hodor resized to new dimensions" do
            response = server.get(image + "?" + time_stamp2 + "&" + resize_cmd2)
            expect(response.headers["content-length"]).to eq("306")
          end
        end
      end
    end
  end

  describe "fill" do
    it "returns a resized to fill image" do
      response = server.get("#{image}?command=fill&height=2&width=2")
      expect(response.headers["content-length"]).to eq("411")
    end
  end

  after(:each) do
    delete_image(image)
  end

  def copy_image(source, target)
    `cp -rf spec/fixtures/originals/#{source} spec/fixtures/#{target}`
    sleep 0.1 # we need that for the http server to respond
  end

  def delete_image(target)
    `rm spec/fixtures/#{target}`
  end
end
