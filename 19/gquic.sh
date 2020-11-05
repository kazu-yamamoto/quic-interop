# VHDRQ B
set -x
# cannot do 0RTT
./client -d quic.rocks 4433 -V
./client -d quic.rocks 4433
./client -d quic.rocks 4433 -R
./client -d quic.rocks 4433 -Z
#./client -d quic.rocks 4434 -S
./client -d quic.rocks 4433 -Q
./client -d quic.rocks 4433 -M
./client -d quic.rocks 4433 -N
./client -d quic.rocks 4433 -B
./client -d quic.rocks 4433 -A
