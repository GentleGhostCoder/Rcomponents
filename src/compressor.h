//
// Created by sgeist on 26.07.23.
//

#ifndef RCOMPONENTS_SRC_COMPRESSOR_H_
#define RCOMPONENTS_SRC_COMPRESSOR_H_

// Decompressor.h
#include <Rcpp.h>
#include <zlib.h>

SEXP new_decompressor();
Rcpp::RawVector decompress_data(SEXP ptr, const Rcpp::RawVector& compressed_data);

#endif //RCOMPONENTS_SRC_COMPRESSOR_H_
