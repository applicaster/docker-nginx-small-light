require "features_helper"

RSpec.describe "Server" do
  it "returns an image" do
    response = server.get("/applicaster-logo.png")
    expect(response.status).to eq(200)
    expect(response.headers["content-length"]).to eq("21004")
  end

  it "returns resized image" do
    response = server.get("/applicaster-logo.png?command=resize&width=2&height=2")
    expect(response.status).to eq(200)
    expect(response.headers["content-length"]).to eq("339")
  end
end
