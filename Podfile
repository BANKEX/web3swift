def import_pods
  pod 'scrypt', '~> 1.5'
  pod "PromiseKit", "~> 6.3"
  pod 'BigInt', '~> 3.1'
  pod 'CryptoSwift', '~> 0.11'
  pod 'Result', '~> 3.0'
#  pod 'libsodium', :modular_headers => true
  pod 'secp256k1_ios', :git => 'https://github.com/shamatar/secp256k1_ios.git', :modular_headers => true
end

target 'web3swift-macOS' do
  platform :osx, '10.11'
#  use_frameworks!
  use_modular_headers!
  import_pods
  
  target 'web3swift-macOS_Tests' do
    inherit! :search_paths
  end
end

target 'web3swift-iOS' do
  platform :ios, '9.0'
#  use_frameworks!
  use_modular_headers! 
  import_pods
  
  target 'web3swift-iOS_Tests' do
    inherit! :search_paths
  end
end
