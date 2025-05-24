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

RUN rustup target add bpfel-unknown-unknown
RUN cargo install --git https://github.com/coral-xyz/anchor --tag v0.29.0 anchor-cli --locked

WORKDIR /app
COPY . .

CMD ["/bin/bash", "-c", "anchor build && solana config set --keypair wallet.json && solana config set --url devnet && solana program deploy target/deploy/simple_counter.so"]
