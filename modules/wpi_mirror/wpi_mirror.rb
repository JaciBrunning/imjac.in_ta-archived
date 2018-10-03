require 'webcore/cdn/extension'
require_relative 'cache'

class WPIMirrorModule < WebcoreApp()
  register CDNExtension

  WPI_MAVEN="http://first.wpi.edu/FRC/roborio/maven"
  SIZELIMIT=1*(1000*1000*1000)  # 1GB (conservative)

  CACHE = {
    release: WPIMirrorCache.new("#{WPI_MAVEN}/release", "/tmp/wpimirror/release", SIZELIMIT),
    development: WPIMirrorCache.new("#{WPI_MAVEN}/development", "/tmp/wpimirror/development", SIZELIMIT)
  }

  set :public_folder, "#{File.dirname(__FILE__)}/public"

  get "/?" do
    redirect '/index.html'
  end

  get "/m2/:branch/*" do |branch, artifact_path|
    branch = branch.to_sym
    pass if CACHE[branch].nil?

    result = CACHE[branch].process(artifact_path)

    response['Mirror-AssetID'] = result[:asset_id]
    response['Mirror-Upstream'] = result[:upstream]
    response['Mirror-Source'] = result[:remote]

    CACHE[branch].queue(result[:remote], result[:local]) if result[:enqueue]

    if result[:redirect] && !params.include?("no-redirect")
      redirect result[:remote]
    elsif result[:exists]
      send_file result[:local]
    else
      pass
    end
  end
end