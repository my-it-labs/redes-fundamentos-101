#!/usr/bin/env python3
"""
Servidor DHCP educativo mínimo (solo responde a DISCOVER con OFFER).

No forma parte de la maqueta Docker del laboratorio (ahí usa dnsmasq).
Sirve para ver capa a capa qué campos lleva un DHCP OFFER.

Requisitos en el host (Codespace o Linux):
  pip install scapy
  sudo python3 ejemplo-dhcp-scapy.py   # o CAP_NET_RAW en la interfaz

La interfaz por defecto es eth0; ajústala si capturas en otra.
"""

from scapy.all import DHCP, BOOTP, Ether, IP, UDP, sendp, sniff

# IP que vamos a ofrecer al cliente
POOL_IP = "192.168.1.100"

# IP de nuestro servidor DHCP
SERVER_IP = "192.168.1.1"


def handle_dhcp(pkt):
    """Se ejecuta por cada paquete capturado en UDP 67/68."""
    if DHCP not in pkt:
        return

    options = pkt[DHCP].options

    for option in options:
        # Las opciones DHCP suelen venir como tupla, p. ej. ('message-type', 1)
        if not isinstance(option, tuple):
            continue

        # DHCP Discover = tipo 1
        if option[0] == "message-type" and option[1] == 1:
            print("=" * 60)
            print("DHCP DISCOVER RECIBIDO")

            client_mac = pkt[Ether].src
            print(f"Cliente MAC: {client_mac}")
            print(f"IP ofrecida : {POOL_IP}")

            # Construcción del paquete DHCP OFFER
            offer = (
                # Ethernet: broadcast porque el cliente aún no tiene IP
                Ether(dst="ff:ff:ff:ff:ff:ff")
                # IP: servidor -> broadcast
                / IP(src=SERVER_IP, dst="255.255.255.255")
                # UDP: servidor 67, cliente 68
                / UDP(sport=67, dport=68)
                # BOOTP: base histórica de DHCP
                / BOOTP(
                    op=2,  # respuesta
                    yiaddr=POOL_IP,  # Your IP — la que ofrecemos
                    siaddr=SERVER_IP,  # Server IP
                    xid=pkt[BOOTP].xid,  # mismo transaction ID que el Discover
                    chaddr=pkt[BOOTP].chaddr,  # MAC del cliente
                )
                / DHCP(
                    options=[
                        ("message-type", "offer"),
                        ("server_id", SERVER_IP),
                        ("router", SERVER_IP),
                        ("name_server", "8.8.8.8"),
                        ("subnet_mask", "255.255.255.0"),
                        ("lease_time", 3600),
                        "end",
                    ]
                )
            )

            print("Enviando DHCP OFFER...")
            sendp(offer, iface="eth0", verbose=False)
            print("DHCP OFFER enviado")
            print("=" * 60)


if __name__ == "__main__":
    print("Servidor DHCP educativo iniciado")
    print("Escuchando Discover en eth0...")
    sniff(
        iface="eth0",
        filter="udp and (port 67 or port 68)",
        prn=handle_dhcp,
        store=0,
    )
