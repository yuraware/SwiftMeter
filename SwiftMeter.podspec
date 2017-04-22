Pod::Spec.new do |s|
    s.name     = 'SwiftMeter'
    s.version  = '0.0.1'
    s.platform = :ios, '9.0'
    s.license  = 'MIT'
    s.summary  = 'Benchmark for swift lang'
    s.description = ''
    s.homepage = 'https://github.com/ykobets/PixelPerfect'
    s.authors  = { 'Yuri Kobets' => 'y.kobets@me.com' }
    s.source   = { :git => 'https://github.com/ykobets/SwiftMeter.git', :tag => s.version.to_s }
    s.source_files = 'Source'
    s.requires_arc = true
    s.frameworks = ['CoreImage', 'UIKit']
end