#include <compressor.h>

// [[Rcpp::export]]
SEXP new_decompressor(int wbits = 15) {
  z_stream* strm = new z_stream();
  strm->zalloc = Z_NULL;
  strm->zfree = Z_NULL;
  strm->opaque = Z_NULL;
  strm->avail_in = 0;
  strm->next_in = Z_NULL;

  if (inflateInit2(strm, wbits) != Z_OK) {
    delete strm;
    Rcpp::stop("Failed to initialize decompressor");
  }

  return Rcpp::XPtr<z_stream>(strm, true);
}

// [[Rcpp::export]]
Rcpp::RawVector decompress_data(SEXP ptr, Rcpp::RawVector compressed_data) {
  Rcpp::XPtr<z_stream> strm(ptr);

  strm->avail_in = compressed_data.size();
  strm->next_in = (Bytef*)RAW(compressed_data);

  Rcpp::RawVector decompressed_data(1024); // Initial size
  strm->avail_out = decompressed_data.size();
  strm->next_out = (Bytef*)RAW(decompressed_data);

  int ret = inflate(strm, Z_NO_FLUSH);
  if (ret != Z_OK && ret != Z_STREAM_END) {
    Rcpp::Rcout << "inflate returned error code: " << ret << std::endl;
    Rcpp::Rcout << "Error message: " << strm->msg << std::endl;
    Rcpp::stop("An error occurred during decompression");
  }

  Rcpp::RawVector result(strm->next_out - (Bytef*)RAW(decompressed_data));
  std::copy(decompressed_data.begin(), decompressed_data.begin() + result.size(), result.begin());

  return result;
}
