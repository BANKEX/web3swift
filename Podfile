def import_pods
  pod 'PromiseKit', '~> 6.4'
  pod 'BigInt', '~> 3.1'
  pod 'CryptoSwift', '~> 0.12'
  pod 'Result', '~> 4.0'
  pod 'secp256k1.swift'
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
