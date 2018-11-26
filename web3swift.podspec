Pod::Spec.new do |spec|
    spec.name         = 'web3swift'
    spec.version      = '2.0.7'
    spec.ios.deployment_target = "8.0"
    spec.osx.deployment_target = "10.10"
    spec.tvos.deployment_target = "9.0"
    spec.watchos.deployment_target = "2.0"
    spec.license      = { :type => 'Apache License 2.0', :file => 'LICENSE.md' }
    spec.summary      = 'Web3 implementation in pure Swift for iOS, macOS, tvOS, watchOS and Linux'
    spec.homepage     = 'https://github.com/bankex/web3swift'
    spec.author       = 'Bankex Foundation'
    spec.source       = { :git => 'https://github.com/bankex/web3swift.git', :tag => 'v' + String(spec.version) }
    spec.source_files = 'Sources/**/*.swift'
    spec.dependency 'PromiseKit', '~> 6.4'
    spec.dependency 'BigInt', '~> 3.1'
    spec.dependency 'CryptoSwift', '~> 0.12'
    spec.dependency 'secp256k1.swift'
end
