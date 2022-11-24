FROM emscripten/emsdk as build-stage

RUN emcc -s USE_ZLIB=1 -s USE_LIBPNG=1 -s USE_FREETYPE=1 /emsdk/upstream/emscripten/test/freetype_test.c
RUN wget https://poppler.freedesktop.org/poppler-21.04.0.tar.xz && tar -xvf poppler-21.04.0.tar.xz
RUN apt update && apt install -y pkg-config
RUN cd poppler-21.04.0 && mkdir build && cd build && emcmake cmake .. -DCMAKE_BUILD_TYPE=Release || emcmake cmake .. -DCMAKE_BUILD_TYPE=Release  -DFONT_CONFIGURATION=generic -DENABLE_LIBOPENJPEG=unmaintained -DENABLE_CMS=none -DENABLE_DCTDECODER=unmaintained  -DCMAKE_EXE_LINKER_FLAGS="-s NODERAWFS -O1 -sALLOW_MEMORY_GROWTH"
RUN cd poppler-21.04.0/build/utils && emmake make pdftotext
FROM scratch
COPY --from=build-stage /src/poppler-21.04.0/build/utils/pdftotext* /