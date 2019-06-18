class LibdartAbi < Formula
  # Basic formula configurations.
  desc 'A high performance, network optimized, JSON library'
  homepage 'https://github.com/target/libdart'
  url 'https://github.com/target/libdart/archive/v0.9.0.tar.gz'
  sha256 'ed012bae80aed08485e0fbd6da7f2a9fe9b6aa74a345864659b8b12a988c0b2c'
  head 'https://github.com/target/libdart', branch: 'master'

  # List dependencies.
  depends_on 'cmake'
  depends_on 'cpp-gsl'
  depends_on 'rapidjson'

  # Install.
  def install
    mkdir 'build' do
      system 'cmake', '..', '-Dtest=OFF', '-Dbuild_abi=ON', *std_cmake_args
      system 'make', '-j', '4', 'install'
    end
  end

  # Test that basic functionality works.
  test do
    (testpath/'test.c').write <<-DRIVER
    #include <stdlib.h>
    #include <assert.h>
    #include <string.h>
    #include <dart/abi.h>

    int main() {
      dart_packet_t obj = dart_obj_init_va("sss", "hello", "world", "yes", "no", "stop", "go");
      assert(dart_is_obj(&obj));
      assert(dart_size(&obj) == 3U);

      dart_packet_t hello = dart_obj_get(&obj, "hello");
      dart_packet_t yes = dart_obj_get(&obj, "yes");
      dart_packet_t stop = dart_obj_get(&obj, "stop");
      assert(!strcmp(dart_str_get(&hello), "world"));
      assert(!strcmp(dart_str_get(&yes), "no"));
      assert(!strcmp(dart_str_get(&stop), "go"));

      char* json = dart_to_json(&obj, NULL);
      assert(strlen(json));
      free(json);

      dart_destroy(&stop);
      dart_destroy(&yes);
      dart_destroy(&hello);
      dart_destroy(&obj);
      return EXIT_SUCCESS;
    }
    DRIVER
    system ENV.cc, 'test.c', "-I#{include}", "-L#{lib}", '-ldart_abi', '-o', 'test'
    system './test'
  end
end
