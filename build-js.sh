#!/bin/bash -x

ROOT_DIR=$PWD
BUILD_DIR=$ROOT_DIR/build

##
configure_ffmpeg() {
  cd $BUILD_DIR/FFmpeg
  make clean
  emconfigure ./configure \
    --cc=emcc \
	--enable-cross-compile \
	--target-os=none \
	--arch=x86 \
	--disable-runtime-cpudetect \
	--disable-asm \
	--disable-fast-unaligned \
	--disable-pthreads \
	--disable-w32threads \
	--disable-os2threads \
	--disable-debug \
	--disable-stripping \
	\
	--disable-all \
	--enable-ffmpeg \
	--enable-avcodec \
	--enable-avformat \
	--enable-avutil \
	--enable-swresample \
	--enable-swscale \
	--enable-avfilter \
	--disable-network \
	--disable-d3d11va \
	--disable-dxva2 \
	--disable-vaapi \
	--disable-vda \
	--disable-vdpau \
	--enable-decoder=h264 \
	--enable-protocol=file \
	--disable-bzlib \
	--disable-iconv \
	--disable-libxcb \
	--disable-lzma \
	--disable-sdl \
	--disable-securetransport \
	--disable-xlib \
	--disable-zlib
}

make_ffmpeg() {
  cd $BUILD_DIR/FFmpeg
  NPROC=$(grep -c ^processor /proc/cpuinfo)
  emmake make -j${NPROC}
  cp ffmpeg ffmpeg.bc
}

# --pre-js javascript/prepend.js \
# --closure 1 \
# -s USE_SDL=2 \
# -s WASM={0,1} -s SINGLE_FILE=1 merges JavaScript and WebAssembly code in the single output file

build_ffmpegjs() {
  cd $ROOT_DIR
  emcc $BUILD_DIR/FFmpeg/ffmpeg.bc \
    -o dist/ffmpeg-h264.js \
    -s MODULARIZE=0 \
    -s WASM=0 \
    -O3 --memory-init-file 0 \
    -s NO_FILESYSTEM=1 \
    -s NO_EXIT_RUNTIME=1 \
    -s EXPORTED_FUNCTIONS='["_avcodec_register_all","_avcodec_find_decoder_by_name","_avcodec_alloc_context3","_avcodec_open2", "_av_init_packet", "_av_frame_alloc", "_av_packet_from_data", "_avcodec_decode_video2", "_avcodec_flush_buffers"]' \
    -s EXTRA_EXPORTED_RUNTIME_METHODS='["ccall", "getValue", "setValue", "writeArrayToMemory"]' \
    -s TOTAL_MEMORY=67108864
}

main() {
  configure_ffmpeg
  make_ffmpeg
  build_ffmpegjs
}

main "$@"