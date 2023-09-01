#include <Rcpp.h>
#include <zlib.h>

using namespace Rcpp;

struct Decompressor {
  z_stream strm{};
  std::vector<uint8_t> buffer;
};

// Create a new decompressor object
// [[Rcpp::export]]
SEXP create_decompressor(int wbits = 0) {
  auto* decompressor = new Decompressor();
  decompressor->strm.zalloc = Z_NULL;
  decompressor->strm.zfree = Z_NULL;
  decompressor->strm.opaque = Z_NULL;
  decompressor->strm.avail_in = 0;
  decompressor->strm.next_in = Z_NULL;
  if (inflateInit2(&decompressor->strm, wbits) != Z_OK) {
    delete decompressor;
    stop("Failed to initialize decompressor");
  }
  return XPtr<Decompressor>(decompressor, true);
}

// Decompress a chunk using the decompressor object
// [[Rcpp::export]]
RawVector decompress_chunk(SEXP decompressorPtr, const RawVector& input_chunk) {
  XPtr<Decompressor> decompressor(decompressorPtr);
  if (!decompressor) {
    stop("Invalid decompressor object");
  }

  decompressor->buffer.insert(decompressor->buffer.end(), input_chunk.begin(), input_chunk.end());
  decompressor->strm.avail_in = decompressor->buffer.size();
  decompressor->strm.next_in = decompressor->buffer.data();

  size_t available_out = 2 * decompressor->buffer.size();
  std::vector<uint8_t> out(available_out);
  decompressor->strm.avail_out = available_out;
  decompressor->strm.next_out = out.data();

  int ret = inflate(&decompressor->strm, Z_SYNC_FLUSH);
  if (ret == Z_STREAM_END) {
    inflateReset(&decompressor->strm);
  } else if (ret != Z_OK) {
    Rcpp::Rcerr << "zlib error: " << (decompressor->strm.msg ? decompressor->strm.msg : "Unknown error") << std::endl;
    stop("Decompression failed");
  }

  auto diff = static_cast<std::vector<uint8_t>::difference_type>(decompressor->buffer.size() - decompressor->strm.avail_in);
  decompressor->buffer.erase(decompressor->buffer.begin(), decompressor->buffer.begin() + diff);

  auto actual_out_diff = static_cast<std::vector<uint8_t>::difference_type>(available_out - decompressor->strm.avail_out);
  return {out.begin(), out.begin() + actual_out_diff};
}

// Validate if a file is a valid gzip file
// [[Rcpp::export]]
bool validate_gzip_file(const std::string& file_path) {
  FILE* file = fopen(file_path.c_str(), "rb");
  if (!file) {
    Rcpp::Rcerr << "Failed to open file: " << file_path << std::endl;
    return false;
  }

  z_stream strm;
  strm.zalloc = Z_NULL;
  strm.zfree = Z_NULL;
  strm.opaque = Z_NULL;
  strm.avail_in = 0;
  strm.next_in = Z_NULL;
  if (inflateInit2(&strm, 15+32) != Z_OK) {
    fclose(file);
    return false;
  }

  const size_t chunk_size = 1024;
  Bytef in[chunk_size];
  Bytef out[chunk_size];
  int ret;
  bool success = true;  // Flag to indicate success or failure

  do {
    strm.avail_in = fread(in, 1, chunk_size, file);
    if (ferror(file)) {
      Rcpp::Rcerr << "File read error" << std::endl;
      success = false;
      break;
    }
    strm.next_in = in;

    do {
      strm.avail_out = chunk_size;
      strm.next_out = out;
      ret = inflate(&strm, Z_NO_FLUSH);

      if (ret == Z_STREAM_ERROR) {
        Rcpp::Rcerr << "Stream error during decompression" << std::endl;
        success = false;
        break;
      } else if (ret == Z_MEM_ERROR) {
        Rcpp::Rcerr << "Memory error during decompression" << std::endl;
        success = false;
        break;
      } else if (ret == Z_DATA_ERROR) {
        Rcpp::Rcerr << "Data error during decompression" << std::endl;
        success = false;
        break;
      }

    } while (strm.avail_out == 0);

    if (!success) {
      break;
    }

  } while (ret != Z_STREAM_END);

  inflateEnd(&strm);
  fclose(file);

  return success;
}
