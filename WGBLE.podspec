Pod::Spec.new do |s|
  s.name         = "WGBLE"
  s.version      = "0.1.1"
  s.summary      = "A short description of WGBLE."

  s.description  = <<-DESC
                   A longer description of WGBLE in Markdown format.

                   * Think: Why did you write this? What is the focus? What does it do?
                   * CocoaPods will be using this to generate tags, and improve search results.
                   * Try to keep it short, snappy and to the point.
                   * Finally, don't worry about the indent, CocoaPods strips it!
                   DESC

  s.homepage     = "https://github.com/edwardair/WGBLE.git"
  s.license      = "MIT"
  s.author       = { "Eduoduo" => "550621009@qq.com" }

  s.platform     = :ios
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/edwardair/WGBLE.git", :tag => s.version }

  s.source_files = 'WGBLE/WGBLE.h'
  s.subspec 'WGBLECentralManager' do |ss|
    ss.source_files = 'WGBLE/WGBLECentralManager/*.{h,m}'
  end
  
  s.subspec 'WGBLEPeripheral' do |ss|
    ss.source_files = 'WGBLE/WGBLEPeripheral/*.{h,m}'
  end
end
