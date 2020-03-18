Pod::Spec.new do |s|
  s.name         = "ARVideoKit"
  s.version      = "1.5.52"
  s.summary      = "Capture & record ARKit videos 📹, photos 🌄, Live Photos 🎇, and GIFs 🎆."
  s.description  = "Enabling developers to capture videos 📹, photos 🌄, Live Photos 🎇, and GIFs 🎆 with augmented reality components."
  s.homepage     = "https://github.com/AFathi/ARVideoKit"
  s.screenshots  = "http://www.ahmedbekhit.com/SK_PREV.gif", "http://www.ahmedbekhit.com/SCN_PREVIEW.gif"
  s.swift_version = '5.0'


  s.license      = { :type => "Apache 2.0", :file => "LICENSE" }


  s.author             = { "Ahmed Fathi Bekhit" => "me@ahmedbekhit.com" }
  s.social_media_url   = "http://ahmedbekhit.com"

  s.platform     = :ios, "9.3"

  # ARVideoKit for Swift 5.0
  # https://github.com/HongXiuTanXiang/ARVideoKit.git
  s.source       = { :git => "https://github.com/HongXiuTanXiang/ARVideoKit.git", :tag => "1.5.52" }
  s.source_files  = "ARVideoKit", "ARVideoKit/**/*.{h,m,swift}"
  s.resources = "ARVideoKit/Assets/*.scnassets"
end
