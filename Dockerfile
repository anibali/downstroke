FROM ubuntu:14.04

# Install required packages
RUN apt-get update \
 && apt-get install -y build-essential cmake git curl unzip \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# Install LuaJIT
RUN git clone https://github.com/torch/luajit-rocks.git /tmp/luajit-rocks \
 && cd /tmp/luajit-rocks \
 && mkdir build \
 && cd build \
 && cmake .. -DCMAKE_INSTALL_PREFIX=/usr/local \
 && make install \
 && rm -rf /tmp/luajit-rocks \

# Export environment variables manually
ENV LUA_PATH='/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua' \
    LUA_CPATH='/root/.luarocks/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so' \
    LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH \
    DYLD_LIBRARY_PATH=/usr/local/lib:$DYLD_LIBRARY_PATH

# Install busted for running tests
RUN luarocks install busted

# Make working directory for this project
RUN mkdir -p /app
WORKDIR /app

# Copy project files into image
COPY test/*.lua /app/test/
COPY src /app/src/
