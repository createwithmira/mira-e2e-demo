FROM rust:1.70

RUN apt-get update && apt-get install -y \
    pkg-config \
    libssl-dev \
    build-essential \
    curl \
    git && \
    rm -rf /var/lib/apt/lists/*

RUN sh -c "$(curl -sSfL https://release.solana.com/stable/install)"
ENV PATH="/root/.local/share/solana/install/active_release/bin:${PATH}"

# Install Solana BPF toolchain manually
RUN apt-get install -y xz-utils && \
    curl -sSfL https://github.com/solana-labs/solana/releases/latest/download/solana-release-x86_64-unknown-linux-gnu.tar.bz2 \
    | tar -xj && \
    mv solana-release*/bin/* /usr/local/bin/

RUN cargo install --git https://github.com/coral-xyz/anchor --tag v0.29.0 anchor-cli --locked

WORKDIR /app
COPY . .

RUN echo "$WALLET_JSON_BASE64" | base64 -d > /app/wallet.json

CMD ["/bin/bash", "-c", "anchor build && solana config set --keypair wallet.json && solana config set --url devnet && solana program deploy target/deploy/simple_counter.so"]
