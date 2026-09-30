# kalitools_tools_for_ubuntu
General Kali Linux security and pentesting tools for Ubuntu from Ubuntu's own repos or Kali tools individually.

## Basic tools
  nmap \
  netcat-openbsd \
  tcpdump \
  wireshark \
  traceroute \
  dnsutils \
  whois \
  curl \
  wget \
  git \
  jq \
  openssh-client \
  smbclient \
  ldap-utils \
  cifs-utils

## Web testing
  nikto \
  gobuster \
  ffuf \
  sqlmap \
  whatweb

## Passwords and hashes
  john \
  hashcat \
  hydra \
  hashid

## Metasploit

For Ubuntu, it is recommended to install Metasploit Framework using its own installation method and not add the Kali repository to Ubuntu.

```bash
curl https://raw.githubusercontent.com/rapid7/metasploit-omnibus/master/config/templates/metasploit-framework-wrappers/msfupdate.erb \
  > /tmp/msfinstall

chmod +x /tmp/msfinstall
sudo /tmp/msfinstall
```

Check:
```bash
msfconsole
```

## Network traffic analysis
  wireshark \
  tshark \
  tcpdump \
  ettercap-common \
  bettercap

If you want to use Wireshark without sudo:
```bash
sudo usermod -aG wireshark "$USER"
```
# Nmap, NSE Scripts & Vulners CVE Update Tool

## Installation

Make it executable:

```bash
chmod +x ~/nmap-update.sh
```

Run:

```bash
sudo ~/nmap-update.sh
```

After the update

You can check for example:

```bash
nmap --script-help vulners
```

and run a version/CVE check on your own network:

```bash
sudo nmap -sV --script vulners 192.168.1.0/24
```

Or for a single server:

```bash
sudo nmap -sV --script vulners 192.168.1.10
```

mincvss=7 limits the results to at least CVSS 7.0 vulnerabilities:

```bash
sudo nmap -sV --script vulners --script-args mincvss=7 192.168.1.10
```

Note: vulners.nse retrieves vulnerability information Vulners service during the scan, so the actual CVE database is not the entire local Nmap database. The script updates the NSE script and Nmap itself, but the CVE information is retrieved from the service during the scan.
