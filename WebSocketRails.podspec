Pod::Spec.new do |s|
  s.name               = "WebSocketRails"
  s.version            = "1.0.0"
  s.summary            = "WebSocketRails client for iOS."
  s.description        = <<-DESC
                         Port of JavaScript client provided by https://github.com/websocket-rails/websocket-rails
                         Built on top of SocketRocket.
                         There is a sample WebSocketRails server located here https://github.com/patternoia/WebSocketRailsEcho
                         One can use it to test various WebSocketRocket event types.
                         DESC
  s.homepage           = "https://github.com/patternoia/WebSocketRails-iOS"
  s.license            = { :type => "MIT", :file => "LICENSE" }
  s.author             = "patternoia"
  s.social_media_url   = "http://github.com/patternoia"
  s.platform           = :ios, "7.0"
  s.source             = { :git => "https://github.com/monsieurje/WebSocketRails-iOS", :tag => "1.0.0" }
  s.source_files       = "WebSocketRails-iOS/*.{h,m}"
  s.library            = "libicucore"
  s.requires_arc       = true
  s.dependency         = "SocketRocket", "~> 0.3.1-beta2"
end
