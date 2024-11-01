# libboostをインストールするためのビルダーイメージ
FROM ubuntu:22.04 AS builder

RUN apt-get update && apt-get install -y software-properties-common git \
    && add-apt-repository ppa:mhier/libboost-latest \
    && apt-get update && apt-get install -y libboost1.81-all-dev

RUN cd /usr/lib && git clone https://github.com/launchdarkly/lua-server-sdk.git

FROM openresty/openresty:1.25.3.2-0-jammy

# {{ x-release-please-start-version }}
ARG VERSION=2.1.1
# {{ x-release-please-end }}

ARG CPP_SDK_VERSION=3.5.2

RUN apt-get update && apt-get install -y \
    git netbase curl libssl-dev apt-transport-https ca-certificates \
    software-properties-common \
    cmake ninja-build locales-all

RUN add-apt-repository ppa:mhier/libboost-latest && \
    apt-get update && \
    apt-get install -y boost1.81

RUN mkdir cpp-sdk-libs
RUN git clone --branch launchdarkly-cpp-server-v${CPP_SDK_VERSION} https://github.com/launchdarkly/cpp-sdks.git && \
    cd cpp-sdks && \
    mkdir build-dynamic && \
    cd build-dynamic && \
    cmake -GNinja \
        -DLD_BUILD_EXAMPLES=OFF \
        -DBUILD_TESTING=OFF \
        -DLD_BUILD_SHARED_LIBS=ON \
        -DLD_DYNAMIC_LINK_OPENSSL=ON .. && \
    cmake --build . --target launchdarkly-cpp-server && \
    cmake --install . --prefix=../../cpp-sdk-libs

RUN mkdir -p /usr/local/openresty/nginx/scripts

COPY --from=builder /usr/lib/lua-server-sdk .
COPY nginx.conf /usr/local/openresty/nginx/conf/nginx.conf
COPY shared.lua /usr/local/openresty/nginx/scripts/
COPY --from=builder /usr/lib/lua-server-sdk/examples/env-helper/get_from_env_or_default.lua /usr/local/openresty/nginx/scripts/

RUN luarocks make launchdarkly-server-sdk-"${VERSION}"-0.rockspec LD_DIR=./cpp-sdk-libs && \
    cp launchdarkly_server_sdk.so /usr/local/openresty/lualib/

# COPY --from=builder /usr/lib/x86_64-linux-gnu/libboost_*.so* /usr/lib/
COPY --from=builder /usr/lib/aarch64-linux-gnu/libboost_*.so* /usr/lib/
RUN ln -s /usr/lib/libboost_json.so.1.81.0 /usr/lib/libboost_json-mt-x64.so.1.81.0 && \
    ln -s /usr/lib/libboost_url.so.1.81.0 /usr/lib/libboost_url-mt-x64.so.1.81.0

CMD ["nginx", "-g", "daemon off;"]
