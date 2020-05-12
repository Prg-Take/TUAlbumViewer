#
#  Be sure to run `pod spec lint TUAlbumViewer.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|

  spec.name             = "TUAlbumViewer"
  spec.version          = "1.0.0"
  spec.summary          = "For myself."
  spec.swift_version    = "5.0"

  spec.description      = <<-DESC
                            Simple album viewer.
                            DESC

  spec.homepage         = "https://github.com/Prg-Take/TUAlbumViewer"

  spec.license          = "MIT"

  spec.author           = { "Prg-Take" => "mac.kamimori.bowler@gmail.com" }

  spec.platform         = :ios, "13.0"

  spec.source           = { :git => "https://github.com/Prg-Take/TUAlbumViewer.git", :tag => "ver#{spec.version}" }

  spec.source_files     = "TUAlbumViewer/**/*.swift"

  spec.requires_arc     = true

end
