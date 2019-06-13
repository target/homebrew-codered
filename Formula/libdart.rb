class Libdart < Formula
  # Basic formula configurations.
  desc 'A high performance, network optimized, JSON library'
  homepage 'https://github.com/target/libdart'
  url 'https://github.com/target/libdart/tarball/master'
  sha256 'cff28009008af33222c5308ef083933c88dd93df0c555b26092472011f78e913'
  head 'https://github.com/target/libdart', branch: 'master'
  version '0.9.0'

  # List dependencies.
  depends_on 'cmake'
  depends_on 'cpp-gsl'
  depends_on 'rapidjson' => [:optional]

  # Install.
  def install
    mkdir 'build' do
      system 'cmake', '..', '-Dtest=OFF', *std_cmake_args
      system 'make', 'install'
    end
  end

  # Test that basic functionality works.
  test do
    (testpath/'test.cc').write <<-DRIVER
    #include <dart.h>
    #include <cassert>

    int main() {
      dart::packet::object obj {"hello", "world"};
      assert(obj.is_object());
      assert(obj.size() == 1U);
      assert(obj["hello"] == "world");

      auto pkt = dart::packet::from_json(R"({"yes":"no","stop":"go","c":2.99792})");
      assert(pkt.is_object());
      assert(pkt.size() == 3U);
      assert(pkt["yes"] == "no");
      assert(pkt["stop"] == "go");
      assert(!pkt.to_json().empty());
    }
    DRIVER
    system ENV.cxx, 'test.cc', "-I#{include}", '-std=c++14', '-o', 'test'
    system './test'
  end
end
