FROM trzeci/emscripten:sdk-tag-1.38.13-64bit AS builder

RUN git clone https://github.com/TorchCraft/TorchCraftAI.git \
	&& cd TorchCraftAI/3rdparty/openbw \
	&& git clone https://github.com/OpenBW/bwapi.git \
	&& cd ../../scripts/cherryvis \
	&& git clone https://github.com/OpenBW/openbw.git \
	&& cd openbw \
	&& git checkout 4091cad0823eedef60283f1a9dc1fb55cc1793d7 \
	&& git apply --whitespace=nowarn ../openbw_patch.diff \
	&& cd .. \
	&& ./build_js.sh

# Viewer compat with modern `zstd` packages (which dropped
# ZstdDecompressor().stream_reader) while still serving Stardust-style
# compressed partitions: read whole file, one-shot decompress, pass plain
# files through. Fails the build loudly if upstream moved.
COPY cvis-views-zstd-compat.diff /tmp/cvis-views-zstd-compat.diff
RUN cd /src/TorchCraftAI/scripts/cherryvis \
	&& git apply /tmp/cvis-views-zstd-compat.diff \
	&& rm /tmp/cvis-views-zstd-compat.diff
	
FROM python:3.10-alpine

COPY --from=builder /src/TorchCraftAI/scripts/cherryvis .

COPY requirements.txt .

RUN apk add --no-cache --virtual .build-deps gcc musl-dev \
    && pip install -r requirements.txt \
	&& apk del .build-deps \
	&& rm -rf requirements.txt
	
EXPOSE 8770

CMD ["./server.py","--host","0.0.0.0:8770"]
