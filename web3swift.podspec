Pod::Spec.new do |s|
s.name             = "web3swift"
s.version          = "2.0.0"
s.summary          = "Web3 implementation in pure Swift for iOS, macOS, tvOS, watchOS and Linux"

s.description      = <<-DESC
Web3 implementation in pure Swift, intended for mobile developers of wallets, Dapps and Web3.0
DESC

s.homepage         = "https://github.com/bankex/web3swift"
s.license          = 'Apache License 2.0'
s.author           = { "Bankex Foundation" => "info@bankexfoundation.org" }
s.source           = { :git => 'https://github.com/bankex/web3swift.git', :tag => s.version.to_s }

s.swift_version = '4.2'
s.module_name = 'web3swift'
s.ios.deployment_target = "9.0"
s.osx.deployment_target = "10.11"
s.watchos.deployment_target = "2.0"
s.tvos.deployment_target = "9.0"
s.source_files = "web3swift/**/*.{h,swift}",
s.public_header_files = "web3swift/**/*.{h}"
s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }

s.dependency 'PromiseKit', '~> 6.4'
s.dependency 'BigInt', '~> 3.1'
s.dependency 'CryptoSwift', '~> 0.12'
s.dependency 'secp256k1.swift'
end
