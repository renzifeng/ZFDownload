Pod::Spec.new do |s|
    s.name         = 'ZFDownload'
    s.version      = '0.0.1'
    s.summary      = 'Download manager based on NSURLSession'
    s.homepage     = 'https://github.com/renzifeng/ZFDownload'
    s.license      = 'MIT'
    s.authors      = { 'renzifeng' => 'zifeng1300@gmail.com' }
    s.platform     = :ios, '8.0'
    s.source       = { :git => 'https://github.com/renzifeng/ZFDownload.git', :tag => s.version.to_s }
    s.source_files = 'ZFDownload/**/*.{h,m}'
    s.framework    = 'UIKit'
    s.requires_arc = true
end