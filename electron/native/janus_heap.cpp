#include <napi.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>

class JanusHeapAddon : public Napi::Addon<JanusHeapAddon> {
 public:
  JanusHeapAddon(Napi::Env env, Napi::Object exports) {
    DefineAddon(exports, {
      InstanceMethod("mapHeap", &JanusHeapAddon::MapHeap),
      InstanceMethod("readBuffer", &JanusHeapAddon::ReadBuffer),
      InstanceMethod("writeBuffer", &JanusHeapAddon::WriteBuffer)
    });
  }

 private:
  void* heap_ptr = nullptr;
  size_t heap_size = 0;

  Napi::Value MapHeap(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    std::string shm_name = info[0].As<Napi::String>().Utf8Value();
    size_t size = info[1].As<Napi::Number>().Uint32Value(); // Size in bytes

    int fd = shm_open(shm_name.c_str(), O_RDWR, 0);
    if (fd == -1) {
      Napi::Error::New(env, "Failed to open shared memory").ThrowAsJavaScriptException();
      return env.Null();
    }

    void* ptr = mmap(nullptr, size, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0);
    close(fd);

    if (ptr == MAP_FAILED) {
      Napi::Error::New(env, "Failed to map shared memory").ThrowAsJavaScriptException();
      return env.Null();
    }

    heap_ptr = ptr;
    heap_size = size;

    return Napi::Boolean::New(env, true);
  }

  Napi::Value ReadBuffer(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    uint32_t offset = info[0].As<Napi::Number>().Uint32Value();
    uint32_t length = info[1].As<Napi::Number>().Uint32Value();

    if (!heap_ptr || offset + length > heap_size) {
      Napi::Error::New(env, "Invalid heap access").ThrowAsJavaScriptException();
      return env.Null();
    }

    return Napi::Buffer<uint8_t>::Copy(env, (uint8_t*)heap_ptr + offset, length);
  }

  Napi::Value WriteBuffer(const Napi::CallbackInfo& info) {
    Napi::Env env = info.Env();
    uint32_t offset = info[0].As<Napi::Number>().Uint32Value();
    Napi::Buffer<uint8_t> buffer = info[1].As<Napi::Buffer<uint8_t>>();

    if (!heap_ptr || offset + buffer.Length() > heap_size) {
      Napi::Error::New(env, "Invalid heap access").ThrowAsJavaScriptException();
      return env.Null();
    }

    memcpy((uint8_t*)heap_ptr + offset, buffer.Data(), buffer.Length());
    return env.Null();
  }
};

NODE_API_ADDON(JanusHeapAddon)
