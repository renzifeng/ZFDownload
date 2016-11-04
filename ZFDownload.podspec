Pod::Spec.new do |s|
    s.name         = 'ZFDownload'
    s.version      = '1.0.2'
    s.summary      = 'Download manager based on ASIHTTPRequest'
    s.homepage     = 'https://github.com/renzifeng/ZFDownload'
    s.license      = 'MIT'
    s.authors      = { 'renzifeng' => 'zifeng1300@gmail.com' }
    s.platform     = :ios, '6.0'
    s.source       = { :git => 'https://github.com/renzifeng/ZFDownload.git', :tag => s.version.to_s }
    s.source_files = 'ZFDownload/**/*.{h,m}'
    s.framework    = 'UIKit'
    s.dependency 'ASIHTTPRequest'
    s.requires_arc = true
end